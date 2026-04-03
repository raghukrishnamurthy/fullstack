#!/bin/zsh
set -euo pipefail

# Run the reusable blueprint claim chain in one backend mode and verify the
# exported context, claim, and normalized-result contracts.
#
# Usage:
#   ./scripts/run_blueprint_claim_chain_checked.sh saas [example_dir]
#   ./scripts/run_blueprint_claim_chain_checked.sh appliance [example_dir]

mode="${1:-saas}"
runtime_python="$(python3 -c 'import sys; print(sys.executable)')"

case "${mode}" in
  saas)
    api_key_env_var="SAAS_INTERSIGHT_API_KEY_ID"
    api_private_key_env_var="SAAS_INTERSIGHT_API_PRIVATE_KEY"
    ;;
  appliance)
    api_key_env_var="APPLIANCE_INTERSIGHT_API_KEY_ID"
    api_private_key_env_var="APPLIANCE_INTERSIGHT_API_PRIVATE_KEY"
    ;;
esac

case "${mode}" in
  saas)
    example_dir="${2:-$(pwd)/examples/ai-pod-sjc01-prod}"
    ;;
  appliance)
    example_dir="${2:-$(pwd)/examples/ai-pod-pva-sjc01-prod}"
    ;;
  *)
    echo "Usage: $0 <saas|appliance> [example_dir]" >&2
    exit 2
    ;;
esac

tmp_vars_file="/tmp/jarvis_blueprint_claim_chain_${mode}_vars.yaml"
tmp_wrapper_playbook="/tmp/jarvis_blueprint_claim_chain_${mode}_wrapper.yaml"
tmp_normalize_playbook="/tmp/jarvis_blueprint_claim_chain_${mode}_normalize.yaml"
tmp_normalize_vars_file="/tmp/jarvis_blueprint_claim_chain_${mode}_normalize_vars.yaml"
tmp_context_file="/tmp/jarvis_blueprint_claim_chain_${mode}_context.json"
tmp_claim_file="/tmp/jarvis_blueprint_claim_chain_${mode}_claim.json"
tmp_normalized_file="/tmp/jarvis_blueprint_claim_chain_${mode}_normalized.json"

required_env_vars=(
  "${api_key_env_var}"
  "${api_private_key_env_var}"
  RACKSERVER_DESIRED_PASSWORD
)

for required_env_var in "${required_env_vars[@]}"; do
  if [[ -z "${(P)required_env_var:-}" ]]; then
    echo "Missing required environment variable: ${required_env_var}" >&2
    echo "Blueprint claim-chain checks require env-backed claim credentials." >&2
    exit 2
  fi
done

if [[ "${mode}" == "saas" ]]; then
  cat > "${tmp_vars_file}" <<EOF
deployment_yaml: |
$(sed 's/^/  /' "${example_dir}/deployment.yaml")
platform_yaml: |
  platform:
    intersight:
      endpoint: https://intersight.com/api/v1
      credentials:
        api_key_id_ref: env://${api_key_env_var}
        api_private_key_ref: env://${api_private_key_env_var}
placement_yaml: |
$(sed 's/^/  /' "${example_dir}/placement.yaml")
organization: ai-prod
claim_targets_json: |
  [
    {
      "target_id": "rack-server-01",
      "target_category": "server",
      "device_type": "imc",
      "form_factor": "rack",
      "management_type": "standalone",
      "serial": "WZP270500PQ",
      "endpoint": "10.29.135.106",
      "canonical_endpoint": "10.29.135.106",
      "normalized_claim_key": "WZP270500PQ",
      "claim_username": "admin",
      "claim_password_ref": "env://RACKSERVER_DESIRED_PASSWORD",
      "claim_submission_required": true
    }
  ]
EOF

  cat > "${tmp_wrapper_playbook}" <<EOF
---
- import_playbook: $(pwd)/ansible/ensure-intersight-context/playbook.yaml
- import_playbook: $(pwd)/ansible/claim-to-saas/playbook.yaml

- name: Persist SaaS blueprint claim-chain outputs
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Write context output
      ansible.builtin.copy:
        dest: "${tmp_context_file}"
        content: "{{ context_result_json }}"
        mode: "0600"

    - name: Write claim output
      ansible.builtin.copy:
        dest: "${tmp_claim_file}"
        content: "{{ results_json }}"
        mode: "0600"
EOF
else
  cat > "${tmp_vars_file}" <<EOF
deployment_yaml: |
$(sed 's/^/  /' "${example_dir}/deployment.yaml")
platform_yaml: |
  platform:
    intersight:
      endpoint: https://ucs-hci-appliance-2.cisco.com
      validate_certs: false
      credentials:
        api_key_id_ref: env://${api_key_env_var}
        api_private_key_ref: env://${api_private_key_env_var}
placement_yaml: |
$(sed 's/^/  /' "${example_dir}/placement.yaml")
organization: ai-prod
claim_targets_json: |
  [
    {
      "target_id": "rack-server-01",
      "target_category": "server",
      "form_factor": "rack",
      "management_type": "standalone",
      "serial": "WZP270500PQ",
      "endpoint": "10.29.135.106",
      "canonical_endpoint": "10.29.135.106",
      "normalized_claim_key": "WZP270500PQ",
      "platform_type": "IMCRack",
      "claim_username": "admin",
      "claim_password_ref": "env://RACKSERVER_DESIRED_PASSWORD",
      "claim_submission_required": true
    }
  ]
EOF

  cat > "${tmp_wrapper_playbook}" <<EOF
---
- import_playbook: $(pwd)/ansible/ensure-intersight-context/playbook.yaml
- import_playbook: $(pwd)/ansible/claim-to-appliance/playbook.yaml

- name: Persist appliance blueprint claim-chain outputs
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Write context output
      ansible.builtin.copy:
        dest: "${tmp_context_file}"
        content: "{{ context_result_json }}"
        mode: "0600"

    - name: Write claim output
      ansible.builtin.copy:
        dest: "${tmp_claim_file}"
        content: "{{ results_json }}"
        mode: "0600"
EOF
fi

cat > "${tmp_normalize_playbook}" <<EOF
---
- import_playbook: $(pwd)/ansible/normalize-claim-results/playbook.yaml

- name: Persist normalized blueprint claim-chain outputs
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Write normalized output
      ansible.builtin.copy:
        dest: "${tmp_normalized_file}"
        content: "{{ normalized_claim_results_json }}"
        mode: "0600"
EOF

ANSIBLE_LOCAL_TEMP=/tmp/jarvis-ansible-local \
ANSIBLE_REMOTE_TEMP=/tmp/jarvis-ansible-remote \
ansible-playbook \
  "${tmp_wrapper_playbook}" \
  -i localhost, \
  -c local \
  -e "ansible_python_interpreter=${runtime_python}" \
  -e "@${tmp_vars_file}" \
  > "/tmp/jarvis_blueprint_claim_chain_${mode}.log"

if [[ "${mode}" == "saas" ]]; then
  cat > "${tmp_normalize_vars_file}" <<EOF
appliance_claim_results_json: |
  []
saas_claim_results_json: |
$(sed 's/^/  /' "${tmp_claim_file}")
EOF
else
  cat > "${tmp_normalize_vars_file}" <<EOF
appliance_claim_results_json: |
$(sed 's/^/  /' "${tmp_claim_file}")
saas_claim_results_json: |
  []
EOF
fi

ANSIBLE_LOCAL_TEMP=/tmp/jarvis-ansible-local \
ANSIBLE_REMOTE_TEMP=/tmp/jarvis-ansible-remote \
ansible-playbook \
  "${tmp_normalize_playbook}" \
  -i localhost, \
  -c local \
  -e "ansible_python_interpreter=${runtime_python}" \
  -e "@${tmp_normalize_vars_file}" \
  > "/tmp/jarvis_blueprint_claim_chain_${mode}_normalize.log"

python3 - "${mode}" "${tmp_context_file}" "${tmp_claim_file}" "${tmp_normalized_file}" <<'PY'
import json
import sys
from pathlib import Path

mode = sys.argv[1]
context = json.loads(Path(sys.argv[2]).read_text())
claim_results = json.loads(Path(sys.argv[3]).read_text())
normalized = json.loads(Path(sys.argv[4]).read_text())

assert context["organization"] == "ai-prod"
assert context["org_status"] == "ready"
assert isinstance(claim_results, list)
assert len(claim_results) == 1
assert normalized["summary"]["total_results"] == 1

result = claim_results[0]
normalized_result = normalized["results"][0]

assert result["endpoint"] == "10.29.135.106"
assert normalized_result["endpoint"] == "10.29.135.106"

if mode == "saas":
    assert result["status"] in {"submitted", "already_claimed"}
    assert normalized["summary"]["saas_result_count"] == 1
    assert normalized["summary"]["appliance_result_count"] == 0
else:
    assert result["status"] in {"submitted", "already_claimed", "failed", "conflict"}
    assert normalized["summary"]["appliance_result_count"] == 1
    assert normalized["summary"]["saas_result_count"] == 0

print(f"Blueprint claim-chain checked example passed for {mode}")
PY
