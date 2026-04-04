#!/bin/zsh
set -euo pipefail

example_dir="${1:-$(pwd)/examples/ai-pod-sjc01-prod}"
tmp_vars_file="/tmp/jarvis_example_live_vars.yaml"
required_env_vars=(
  INTERSIGHT_API_KEY_ID
  INTERSIGHT_API_PRIVATE_KEY
)

for required_env_var in "${required_env_vars[@]}"; do
  if [[ -z "${(P)required_env_var:-}" ]]; then
    echo "Missing required environment variable: ${required_env_var}" >&2
    echo "Live example runs require env-backed Intersight credentials." >&2
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

ANSIBLE_LOCAL_TEMP=/tmp/jarvis-ansible-local \
ANSIBLE_REMOTE_TEMP=/tmp/jarvis-ansible-remote \
ansible-playbook \
  ansible/resolve-intersight-deployment-model/playbook.yaml \
  -i localhost, \
  -c local \
  -e "@${tmp_vars_file}"
