# resolve-deployment-model

Purpose:

- Normalize launch-form inputs into a deterministic discovery model
- Validate device inventory and topology relationships
- Optionally validate declared serials against Cisco Intersight using the `cisco.intersight` collection
- Derive infrastructure classification from inventory facts
- Export a stable JSON document for downstream grains

Grain inputs:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `site_yaml`
- `baseline_input_source`
- `baseline_directory`
- `overrides_yaml`
- `inventory_yaml`
- `solution_yaml`
- `validation_mode`

Exported outputs:

- `discovery_model_json`
- `discovery_summary_json`

Execution notes:

- Runs on `localhost`
- Uses `connection: local`
- Uses `hosts: "{{ group | default('localhost') }}"`
- Uses `any_errors_fatal: true`
- Accepts wrapped `deployment`, `platform`, `placement`, `inventory`, and `solution` payloads as YAML strings and parses them with `from_yaml`
- Accepts optional wrapped `site` payload for site-scoped operational settings
- Accepts optional baseline-resolution hints for higher orchestration or direct Ansible execution
- Always resolves a built-in baseline from `solution.profile`
- Accepts only one customer baseline source at a time: `baseline_input_source` or `baseline_directory`
- When `baseline_input_source` is provided, fetches YAML content from the given HTTP(S) URL
- When `baseline_directory` is provided, loads `baseline.yaml` from that directory and exposes the parsed payload in the discovery model
- Applies precedence in this order: built-in baseline, customer baseline, then deployment overrides
- Merges `overrides_yaml` recursively onto the effective baseline payload
- `validation_mode: strict` validates only the local input contract
- `validation_mode: live` resolves `env://` Intersight credential refs and queries Intersight for declared serials
- live mode also queries the requested Intersight organization and resource group and reports placement reuse/create/conflict outcomes

Execution flow:

1. `tasks/validate_contract.yaml`
2. `tasks/validate_inventory_and_site.yaml`
3. `tasks/load_baseline.yaml`
4. `tasks/live_intersight_validation.yaml`
5. `tasks/build_discovery_outputs.yaml`

Destroy behavior:

- `teardown.yaml` is a no-op
- Exports `destroy_status` and `destroy_results_json`
