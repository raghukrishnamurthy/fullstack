#!/bin/zsh
set -euo pipefail

# Exercise rack standalone pre-claim permutations in strict mode and verify
# the guarded claim hook models password-normalization readiness correctly.

example_dir="${1:-$(pwd)/examples/ai-pod-sjc01-prod}"
tmp_wrapper_playbook="/tmp/jarvis_rack_preclaim_matrix_playbook.yaml"
tmp_model_file="/tmp/jarvis_rack_preclaim_matrix_model.json"

cat > "${tmp_wrapper_playbook}" <<EOF
---
- import_playbook: $(pwd)/ansible/resolve-deployment-model/playbook.yaml

- name: Persist rack preclaim matrix outputs
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Write discovery model output
      ansible.builtin.copy:
        dest: "${tmp_model_file}"
        content: "{{ discovery_model | to_json }}"
        mode: "0600"
EOF

run_case() {
  local case_name="$1"
  local credentials_payload="$2"
  local tmp_vars_file="/tmp/jarvis_rack_preclaim_${case_name}_vars.yaml"

  cat > "${tmp_vars_file}" <<EOF
deployment_yaml: |
$(sed 's/^/  /' "${example_dir}/deployment.yaml")
platform_yaml: |
$(sed 's/^/  /' "${example_dir}/platform.yaml")
placement_yaml: |
$(sed 's/^/  /' "${example_dir}/placement.yaml")
site_yaml: |
$(sed 's/^/  /' "${example_dir}/site.yaml")
credential_candidates_yaml: |
$(printf "%s\n" "${credentials_payload}" | sed 's/^/  /')
overrides_yaml: |
  overrides:
    onboarding:
      intersight_validation:
        enabled: false
inventory_yaml: |
$(sed 's/^/  /' "${example_dir}/inventory.yaml")
solution_yaml: |
$(sed 's/^/  /' "${example_dir}/solution.yaml")
validation_mode: strict
execution_intent: apply
EOF

  ANSIBLE_LOCAL_TEMP=/tmp/jarvis-ansible-local \
  ANSIBLE_REMOTE_TEMP=/tmp/jarvis-ansible-remote \
  ansible-playbook \
    "${tmp_wrapper_playbook}" \
    -i localhost, \
    -c local \
    -e "@${tmp_vars_file}" \
    > "/tmp/jarvis_rack_preclaim_${case_name}.log"

  python3 - "${case_name}" <<'PY'
"""Validate a single rack pre-claim permutation from the persisted model output."""

import json
import sys
from pathlib import Path

case_name = sys.argv[1]
model = json.loads(Path("/tmp/jarvis_rack_preclaim_matrix_model.json").read_text())

results = model["derived"]["onboarding_action_execution"]["claim_execution_results"]
rack_results = [
    result
    for result in results
    if result.get("target_category") == "server"
    and result.get("form_factor") == "rack"
    and result.get("management_type") == "standalone"
]

assert rack_results, f"{case_name}: expected rack guarded claim results"

expectations = {
    "both": {
        "status": "preclaim_ready_not_implemented",
        "next_step": "run_password_normalization_then_claim",
        "ready": True,
    },
    "manufacturing_only": {
        "status": "preclaim_credentials_missing",
        "next_step": "supply_rack_credentials_for_password_normalization",
        "ready": False,
    },
    "target_only": {
        "status": "preclaim_credentials_missing",
        "next_step": "supply_rack_credentials_for_password_normalization",
        "ready": False,
    },
    "none": {
        "status": "preclaim_credentials_missing",
        "next_step": "supply_rack_credentials_for_password_normalization",
        "ready": False,
    },
}

expected = expectations[case_name]

for rack_result in rack_results:
    payload = rack_result["claim_target_payload"]
    preclaim = payload["preclaim_normalization"]
    plan = rack_result["preclaim_action_plan"]

    assert rack_result["status"] == expected["status"], (
        f"{case_name}: unexpected status {rack_result['status']}"
    )
    assert preclaim["required"] is True, f"{case_name}: preclaim should be required"
    assert preclaim["ready"] is expected["ready"], (
        f"{case_name}: unexpected preclaim readiness {preclaim['ready']}"
    )
    assert preclaim["next_step"] == expected["next_step"], (
        f"{case_name}: unexpected next step {preclaim['next_step']}"
    )
    assert plan["action_type"] == "password_normalization_then_claim", (
        f"{case_name}: unexpected action type {plan['action_type']}"
    )
    assert plan["ready"] is expected["ready"], (
        f"{case_name}: unexpected action-plan readiness {plan['ready']}"
    )

print(f"Rack preclaim case passed: {case_name}")
PY
}

run_case "both" "$(cat <<'EOF'
credential_candidates:
  - credential_role: manufacturing
    target_category: server
    target_form_factor: rack
    target_management_type: standalone
    username: admin
    password_ref: env://RACKSERVER_MANUFACTURING_PASSWORD
  - credential_role: target
    target_category: server
    target_form_factor: rack
    target_management_type: standalone
    username: admin
    password_ref: env://RACKSERVER_DESIRED_PASSWORD
EOF
)"

run_case "manufacturing_only" "$(cat <<'EOF'
credential_candidates:
  - credential_role: manufacturing
    target_category: server
    target_form_factor: rack
    target_management_type: standalone
    username: admin
    password_ref: env://RACKSERVER_MANUFACTURING_PASSWORD
EOF
)"

run_case "target_only" "$(cat <<'EOF'
credential_candidates:
  - credential_role: target
    target_category: server
    target_form_factor: rack
    target_management_type: standalone
    username: admin
    password_ref: env://RACKSERVER_DESIRED_PASSWORD
EOF
)"

run_case "none" "$(cat <<'EOF'
credential_candidates: []
EOF
)"

echo "Rack preclaim matrix passed"
