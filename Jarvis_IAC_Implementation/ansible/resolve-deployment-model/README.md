# resolve-deployment-model

Purpose:

- Normalize launch-form inputs into a deterministic discovery model
- Validate device inventory and topology relationships
- Optionally validate declared serials against Cisco Intersight using the `cisco.intersight` collection
- Derive infrastructure classification from inventory facts
- Derive a read-only onboarding readiness decision before claim/onboarding actions
- Export a stable JSON document for downstream grains

Grain inputs:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `site_yaml`
- `credential_candidates_yaml`
- `baseline_input_source`
- `baseline_directory`
- `overrides_yaml`
- `inventory_yaml`
- `solution_yaml`
- `validation_mode`
- `execution_intent`

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
- Accepts optional direct credential-candidate input for future claim preparation
- Rack-server claim preparation can distinguish typed candidates such as `manufacturing` and `target`
- Accepts optional baseline-resolution hints for higher orchestration or direct Ansible execution
- Always resolves a built-in baseline from `solution.profile`
- Accepts only one customer baseline source at a time: `baseline_input_source` or `baseline_directory`
- When `baseline_input_source` is provided, fetches YAML content from the given HTTP(S) URL
- When `baseline_directory` is provided, loads `baseline.yaml` from that directory and exposes the parsed payload in the discovery model
- Applies precedence in this order: built-in baseline, customer baseline, then deployment overrides
- Merges `overrides_yaml` recursively onto the effective baseline payload
- Uses the effective baseline payload for early onboarding expectation checks
- Produces a read-only onboarding readiness result from baseline, placement, and live-validation state
- Treats onboarding readiness as target-specific rather than universal; future storage targets may only support reachability readiness instead of claim readiness
- Exposes target readiness profiles so downstream workflows can distinguish claim-capable targets from reachability-only targets
- Future storage-target handling should shift from temporary reachability-only modeling to an Assist-mediated claim flow:
  validate Assist reachability first, then claim storage through the Assist-target path
- `validation_mode: strict` validates only the local input contract
- `validation_mode: live` resolves `env://` Intersight credential refs and queries Intersight for declared serials
- live mode also queries the requested Intersight organization and resource group and reports placement reuse/create/conflict outcomes
- `execution_intent` defaults to `validate_only`; future onboarding actions should only run when readiness is true and the intent is explicitly non-default
- target credential rotation candidates are currently modeled as direct input; vault-backed resolution is intentionally deferred

Execution flow:

1. `tasks/validate_contract.yaml`
2. `tasks/validate_inventory_and_site.yaml`
3. `tasks/load_baseline.yaml`
4. `tasks/validate_baseline_expectations.yaml`
5. `tasks/live_intersight_validation.yaml`
6. `tasks/evaluate_onboarding_readiness.yaml`
7. `tasks/execute_onboarding_actions.yaml`
8. `tasks/build_discovery_outputs.yaml`

Destroy behavior:

- `teardown.yaml` is a no-op
- Exports `destroy_status` and `destroy_results_json`
