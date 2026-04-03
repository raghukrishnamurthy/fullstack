#!/bin/zsh
set -euo pipefail

# Run the strict example end to end and verify a few high-value
# output-contract expectations from the persisted JSON artifacts.

example_dir="${1:-$(pwd)/examples/ai-pod-sjc01-prod}"
tmp_vars_file="/tmp/jarvis_example_strict_checked_vars.yaml"
tmp_wrapper_playbook="/tmp/jarvis_example_strict_checked_playbook.yaml"
tmp_model_file="/tmp/jarvis_example_discovery_model.json"
tmp_summary_file="/tmp/jarvis_example_discovery_summary.json"

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
$(sed 's/^/  /' "${example_dir}/credential_candidates.yaml")
inventory_yaml: |
$(sed 's/^/  /' "${example_dir}/inventory.yaml")
solution_yaml: |
$(sed 's/^/  /' "${example_dir}/solution.yaml")
validation_mode: strict
execution_intent: validate_only
EOF

cat > "${tmp_wrapper_playbook}" <<EOF
---
- import_playbook: $(pwd)/ansible/resolve-intersight-deployment-model/playbook.yaml

- name: Persist strict example outputs
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Write discovery model output
      ansible.builtin.copy:
        dest: "${tmp_model_file}"
        content: "{{ discovery_model | to_json }}"
        mode: "0600"

    - name: Write discovery summary output
      ansible.builtin.copy:
        dest: "${tmp_summary_file}"
        content: "{{ discovery_summary | to_json }}"
        mode: "0600"
EOF

ANSIBLE_LOCAL_TEMP=/tmp/jarvis-ansible-local \
ANSIBLE_REMOTE_TEMP=/tmp/jarvis-ansible-remote \
ansible-playbook \
  "${tmp_wrapper_playbook}" \
  -i localhost, \
  -c local \
  -e "@${tmp_vars_file}" \
  > /tmp/jarvis_example_strict_checked_ansible.log

python3 - <<'PY'
"""Validate the persisted strict-mode discovery outputs for the AI Pod example."""

import json
from pathlib import Path

model = json.loads(Path("/tmp/jarvis_example_discovery_model.json").read_text())
summary = json.loads(Path("/tmp/jarvis_example_discovery_summary.json").read_text())

# Keep these assertions small and stable so they act as a regression check
# for the contract, not as a full behavioral test suite.
assert model["solution"]["profile"] == "ai_pod"
assert model["solution"]["delivery_scope"] == "onboarding"
assert model["derived"]["device_count"] == 10
assert model["derived"]["fabric_interconnect_count"] == 2
assert model["derived"]["server_count"] == 8
assert model["derived"]["domain_count"] == 1
assert model["derived"]["onboarding_readiness"]["status"] == "needs_live_validation"
assert model["derived"]["onboarding_readiness"]["ready"] is False
assert len(model["platform"]["credential_candidates"]) == 2
assert summary["baseline_expectations"]["error_count"] == 0
assert summary["onboarding_readiness"]["claim_candidate_count"] == 9

print("Strict checked example passed")
PY
