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
        "normalization_execution_status": "normalization_probe_not_run",
        "normalization_probe_attempted": False,
    },
    "manufacturing_only": {
        "status": "preclaim_credentials_missing",
        "next_step": "supply_rack_credentials_for_password_normalization",
        "ready": False,
        "normalization_execution_status": "normalization_credentials_missing",
        "normalization_probe_attempted": False,
    },
    "target_only": {
        "status": "hook_ready_not_implemented",
        "next_step": "proceed_to_claim_preparation",
        "ready": True,
        "normalization_execution_status": "not_applicable",
        "normalization_probe_attempted": False,
    },
    "none": {
        "status": "preclaim_credentials_missing",
        "next_step": "supply_rack_credentials_for_password_normalization",
        "ready": False,
        "normalization_execution_status": "normalization_credentials_missing",
        "normalization_probe_attempted": False,
    },
}

expected = expectations[case_name]

for rack_result in rack_results:
    payload = rack_result["claim_target_payload"]
    preclaim = payload["preclaim_normalization"]
    plan = rack_result["preclaim_action_plan"]
    normalization_payload = rack_result["password_normalization_payload"]
    normalization_execution = rack_result["password_normalization_execution"]

    assert rack_result["status"] == expected["status"], (
        f"{case_name}: unexpected status {rack_result['status']}"
    )
    expected_preclaim_required = case_name != "target_only"
    assert preclaim["required"] is expected_preclaim_required, (
        f"{case_name}: unexpected preclaim required flag {preclaim['required']}"
    )
    assert preclaim["ready"] is expected["ready"], (
        f"{case_name}: unexpected preclaim readiness {preclaim['ready']}"
    )
    assert preclaim["next_step"] == expected["next_step"], (
        f"{case_name}: unexpected next step {preclaim['next_step']}"
    )
    expected_action_type = (
        "direct_claim_preparation"
        if case_name == "target_only"
        else "password_normalization_then_claim"
    )
    assert plan["action_type"] == expected_action_type, (
        f"{case_name}: unexpected action type {plan['action_type']}"
    )
    assert plan["ready"] is expected["ready"], (
        f"{case_name}: unexpected action-plan readiness {plan['ready']}"
    )
    if case_name == "target_only":
        assert normalization_payload == {}, (
            f"{case_name}: normalization payload should be empty for already-normalized racks"
        )
    else:
        assert normalization_payload["normalization_workflow"] == "rack_password_normalization", (
            f"{case_name}: unexpected normalization workflow {normalization_payload.get('normalization_workflow')}"
        )
        assert normalization_payload["endpoint"] == rack_result["endpoint"], (
            f"{case_name}: normalization endpoint mismatch"
        )
        assert normalization_payload["ready"] is expected["ready"], (
            f"{case_name}: unexpected normalization readiness {normalization_payload['ready']}"
        )

    assert normalization_execution["requested"] is expected_preclaim_required, (
        f"{case_name}: unexpected normalization execution request flag {normalization_execution['requested']}"
    )
    assert normalization_execution["executed"] is False, (
        f"{case_name}: normalization execution should remain non-mutating"
    )
    assert normalization_execution["status"] == expected["normalization_execution_status"], (
        f"{case_name}: unexpected normalization execution status {normalization_execution['status']}"
    )
    if case_name == "target_only":
        assert normalization_execution["payload"] == {}, (
            f"{case_name}: normalization execution payload should be empty when not applicable"
        )
    else:
        assert normalization_execution["payload"]["target_id"] == rack_result["target_id"], (
            f"{case_name}: normalization execution target mismatch"
        )
        assert normalization_execution["payload"]["ready"] is expected["ready"], (
            f"{case_name}: unexpected normalization execution readiness {normalization_execution['payload']['ready']}"
        )
        assert normalization_execution["payload"]["probe"]["attempted"] is expected["normalization_probe_attempted"], (
            f"{case_name}: unexpected normalization probe attempt flag {normalization_execution['payload']['probe']['attempted']}"
        )

    if case_name != "target_only":
        if case_name in {"both", "manufacturing_only"}:
            assert normalization_payload["manufacturing_credential"]["username"] == "admin", (
                f"{case_name}: missing manufacturing username"
            )
        else:
            assert normalization_payload["manufacturing_credential"]["username"] == "", (
                f"{case_name}: unexpected manufacturing username"
            )

        if case_name == "both":
            assert normalization_payload["target_credential"]["username"] == "admin", (
                f"{case_name}: missing target username"
            )
        else:
            assert normalization_payload["target_credential"]["username"] == "", (
                f"{case_name}: unexpected target username"
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
