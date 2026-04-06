#!/bin/zsh
set -euo pipefail

# Run the network strict example end to end and verify a few high-value
# output-contract expectations from the persisted phase artifacts.

example_dir="${1:-$(pwd)/examples/ai-pod-sjc01-prod}"
tmp_model_vars_file="/tmp/jarvis_example_network_checked_model_vars.yaml"
tmp_model_wrapper_playbook="/tmp/jarvis_example_network_checked_model_playbook.yaml"
tmp_model_file="/tmp/jarvis_example_network_checked_discovery_model.json"
tmp_summary_file="/tmp/jarvis_example_network_checked_discovery_summary.json"
tmp_network_vars_file="/tmp/jarvis_example_network_checked_vars.yaml"
tmp_network_wrapper_playbook="/tmp/jarvis_example_network_checked_playbook.yaml"
tmp_phase_readiness_file="/tmp/jarvis_example_network_phase_readiness.json"
tmp_phase_summary_file="/tmp/jarvis_example_network_phase_summary.json"
tmp_phase_plan_file="/tmp/jarvis_example_network_phase_plan.json"

cat > "${tmp_model_vars_file}" <<EOF
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

cat > "${tmp_model_wrapper_playbook}" <<EOF
---
- import_playbook: $(pwd)/ansible/build-infrastructure-domain-model/playbook.yaml

- name: Persist network strict example discovery outputs
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
  "${tmp_model_wrapper_playbook}" \
  -i localhost, \
  -c local \
  -e "@${tmp_model_vars_file}" \
  > /tmp/jarvis_example_network_checked_model.log

cat > "${tmp_network_vars_file}" <<EOF
discovery_model_json: |
$(sed 's/^/  /' "${tmp_model_file}")
discovery_summary_json: |
$(sed 's/^/  /' "${tmp_summary_file}")
execution_intent: validate_only
EOF

cat > "${tmp_network_wrapper_playbook}" <<EOF
---
- import_playbook: $(pwd)/ansible/infrastructure-network-provisioning/playbook.yaml

- name: Persist strict network phase outputs
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Write phase readiness output
      ansible.builtin.copy:
        dest: "${tmp_phase_readiness_file}"
        content: "{{ phase_readiness | to_json }}"
        mode: "0600"

    - name: Write phase summary output
      ansible.builtin.copy:
        dest: "${tmp_phase_summary_file}"
        content: "{{ {'phase_status': phase_status, 'shared_object_count': (network_foundation_plan.shared_network_foundation_objects | length), 'fabric_interconnect_count': network_foundation_plan.applicability.fabric_interconnect_count, 'domain_count': network_foundation_plan.applicability.domain_count} | to_json }}"
        mode: "0600"

    - name: Write phase plan output
      ansible.builtin.copy:
        dest: "${tmp_phase_plan_file}"
        content: "{{ network_foundation_plan | to_json }}"
        mode: "0600"
EOF

ANSIBLE_LOCAL_TEMP=/tmp/jarvis-ansible-local \
ANSIBLE_REMOTE_TEMP=/tmp/jarvis-ansible-remote \
ansible-playbook \
  "${tmp_network_wrapper_playbook}" \
  -i localhost, \
  -c local \
  -e "@${tmp_network_vars_file}" \
  > /tmp/jarvis_example_network_checked_ansible.log

python3 - <<'PY'
"""Validate the persisted strict-mode network phase outputs for the AI Pod example."""

import json
from pathlib import Path

phase_readiness = json.loads(Path("/tmp/jarvis_example_network_phase_readiness.json").read_text())
phase_summary = json.loads(Path("/tmp/jarvis_example_network_phase_summary.json").read_text())
phase_plan = json.loads(Path("/tmp/jarvis_example_network_phase_plan.json").read_text())

assert phase_readiness["phase"] == "infrastructure-network-provisioning"
assert phase_readiness["status"] == "planned_only"
assert phase_readiness["ready"] is False
assert phase_readiness["summary"]["fabric_interconnect_count"] == 2
assert phase_readiness["summary"]["domain_count"] == 1

assert phase_summary["phase_status"] == "planned_only"
assert phase_summary["shared_object_count"] == 7
assert phase_summary["fabric_interconnect_count"] == 2
assert phase_summary["domain_count"] == 1

assert phase_plan["infrastructure_domain"]["deployment_id"] == "ai-pod-sjc01-prod"
assert phase_plan["applicability"]["fi_managed_foundation_applicable"] is True
assert phase_plan["phase_execution"]["implementation_state"] == "planned_only"
assert phase_plan["next_phase_hint"]["next_phase"] == "infrastructure-resource-provisioning"

print("Network strict checked example passed")
PY
