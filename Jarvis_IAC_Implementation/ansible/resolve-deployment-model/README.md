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
- `validation_mode: strict` validates only the local input contract
- `validation_mode: live` resolves `env://` Intersight credential refs and queries Intersight for declared serials
- live mode also queries the requested Intersight organization and resource group and reports placement reuse/create/conflict outcomes

Destroy behavior:

- `teardown.yaml` is a no-op
- Exports `destroy_status` and `destroy_results_json`
