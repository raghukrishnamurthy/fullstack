#!/bin/zsh
set -euo pipefail

example_dir="${1:-$(pwd)/examples/ai-pod-sjc01-prod}"
tmp_model_vars_file="/tmp/jarvis_example_network_model_vars.yaml"
tmp_model_wrapper_playbook="/tmp/jarvis_example_network_model_playbook.yaml"
tmp_model_file="/tmp/jarvis_example_network_discovery_model.json"
tmp_summary_file="/tmp/jarvis_example_network_discovery_summary.json"
tmp_network_vars_file="/tmp/jarvis_example_network_strict_vars.yaml"

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
  > /tmp/jarvis_example_network_model.log

cat > "${tmp_network_vars_file}" <<EOF
discovery_model_json: |
$(sed 's/^/  /' "${tmp_model_file}")
discovery_summary_json: |
$(sed 's/^/  /' "${tmp_summary_file}")
execution_intent: validate_only
EOF

ANSIBLE_LOCAL_TEMP=/tmp/jarvis-ansible-local \
ANSIBLE_REMOTE_TEMP=/tmp/jarvis-ansible-remote \
ansible-playbook \
  ansible/infrastructure-network-provisioning/playbook.yaml \
  -i localhost, \
  -c local \
  -e "@${tmp_network_vars_file}"
