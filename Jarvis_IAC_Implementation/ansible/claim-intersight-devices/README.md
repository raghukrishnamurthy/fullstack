# claim-intersight-devices

Unified Jarvis grain for claiming prepared targets into either Intersight SaaS or an appliance.

## Intent

- consume one prepared claim-target contract
- route internally to the SaaS or appliance implementation based on the Intersight endpoint
- keep the public blueprint and direct wrapper topology simpler
- export one stable aggregate and normalized output contract

## Required inputs

- `claim_targets_json`
- `platform_yaml`
- `organization`

## Optional inputs

- `deployment_yaml`
- `debug_enabled`
- `helper_timeout_seconds`

## Current behavior

- determines backend mode from `platform_yaml.intersight.endpoint`
- assumes organization/context and other endpoint prerequisites are already prepared
- keeps the SaaS and appliance task logic, helper script, and custom module inside this grain
- emits both:
  - `results_json`
  - normalized claim outputs matching the previous normalize grain contract

## Internal implementation

- `tasks/saas_process_claim_target.yaml`
- `tasks/appliance_process_claim_target.yaml`
- `tasks/appliance_followup_claim_target.yaml`
- `tools/run_claim_readiness.py`
- `library/intersight_scoped_claim.py`

## Outputs

- `batch_status`
- `successful_targets`
- `failed_targets`
- `conflict_targets`
- `skipped_targets`
- `changed_targets`
- `results_json`
- `normalized_claim_results_json`
- `normalized_claim_batch_status`
- `normalized_claim_successful_count`
- `normalized_claim_failed_count`
- `normalized_claim_conflict_count`
- `normalized_claim_skipped_count`
- `normalized_claim_changed_count`
