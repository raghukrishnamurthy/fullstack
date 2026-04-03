#!/bin/zsh
set -euo pipefail

# Run the live example end to end and verify a few high-value
# live-validation fields from the persisted JSON artifacts.

example_dir="${1:-$(pwd)/examples/ai-pod-sjc01-prod}"
tmp_vars_file="/tmp/jarvis_example_live_checked_vars.yaml"
tmp_wrapper_playbook="/tmp/jarvis_example_live_checked_playbook.yaml"
tmp_model_file="/tmp/jarvis_example_live_discovery_model.json"
tmp_summary_file="/tmp/jarvis_example_live_discovery_summary.json"
required_env_vars=(
  INTERSIGHT_API_KEY_ID
  INTERSIGHT_API_PRIVATE_KEY
)

for required_env_var in "${required_env_vars[@]}"; do
  if [[ -z "${(P)required_env_var:-}" ]]; then
    echo "Missing required environment variable: ${required_env_var}" >&2
    echo "Live checked example runs require env-backed Intersight credentials." >&2
    exit 2
  fi
done

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
validation_mode: live
execution_intent: validate_only
EOF

cat > "${tmp_wrapper_playbook}" <<EOF
---
- import_playbook: $(pwd)/ansible/resolve-deployment-model/playbook.yaml

- name: Persist live example outputs
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
  > /tmp/jarvis_example_live_checked_ansible.log

python3 - <<'PY'
"""Validate the persisted live-mode discovery outputs for the AI Pod example."""

import json
from pathlib import Path

model = json.loads(Path("/tmp/jarvis_example_live_discovery_model.json").read_text())
summary = json.loads(Path("/tmp/jarvis_example_live_discovery_summary.json").read_text())

# Keep these assertions focused on the live-validation contract rather than
# trying to exhaustively validate Intersight behavior from the script.
assert model["solution"]["profile"] == "ai_pod"
assert model["derived"]["intersight_live_validation_enabled"] is True
assert summary["inventory_summary"]["live_validation_enabled"] is True
assert "placement_validation" in model["derived"]
assert "onboarding_readiness" in model["derived"]

print("Live checked example passed")
PY
