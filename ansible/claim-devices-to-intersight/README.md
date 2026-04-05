# claim-devices-to-intersight

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
- `storage_assist_wait_timeout_seconds`
- `storage_assist_wait_interval_seconds`

## Current behavior

- determines backend mode from `platform_yaml.intersight.endpoint`
- assumes organization/context and other endpoint prerequisites are already prepared
- uses a shared task-library layer for context resolution, credential resolution, result shaping, follow-up enrichment, and aggregate output construction
- appliance claim accepts any target that supplies an explicit appliance `platform_type`, endpoint, and claim credential
- Assist claim is backend-specific:
  - PVA/appliance uses FQDN + username + password with `PlatformType: IntersightAssist`
  - SaaS uses Assist login plus Device Connector `DeviceIdentifiers` and `SecurityTokens`
- storage claim is inventory-driven and currently supports `platform: pure`
  - both backends resolve the referenced Assist by name and create the storage `asset.Target` through that Assist path
  - storage only introduces an Assist dependency when a storage target is actually present in `claim_targets_json`
  - appliance storage short-circuits when the storage target already exists, otherwise it waits for the referenced Assist to appear and reach `Connected`
  - appliance Assist wait behavior is controlled by `storage_assist_wait_timeout_seconds` and `storage_assist_wait_interval_seconds`
- appliance direct claims perform a post-submit follow-up enrichment pass so the final aggregate preserves workflow and DeviceClaim evidence
- emits both:
  - `results_json`
  - normalized claim outputs matching the previous normalize grain contract

## Internal implementation

- `tasks/lib_resolve_claim_context.yaml`
- `tasks/lib_resolve_claim_credentials.yaml`
- `tasks/lib_build_direct_claim_result.yaml`
- `tasks/lib_build_static_direct_claim_result.yaml`
- `tasks/lib_build_storage_claim_result.yaml`
- `tasks/lib_build_static_storage_claim_result.yaml`
- `tasks/lib_build_appliance_followup_claim_result.yaml`
- `tasks/lib_build_claim_aggregate_outputs.yaml`
- `tasks/lib_collect_claim_result.yaml`
- `tasks/saas_process_claim_target.yaml`
- `tasks/appliance_process_claim_target.yaml`
- `tasks/saas_process_storage_target.yaml`
- `tasks/appliance_process_storage_target.yaml`
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

## Notes

- This grain intentionally keeps the public blueprint contract stable while allowing backend-specific claim mechanics to evolve internally.
- Today, the public onboarding and claim wrappers still pass FI, rack, and manufacturing passwords through direct blueprint inputs that are mapped to environment variables such as `env://FI_TARGET_PASSWORD` and `env://RACK_TARGET_PASSWORD`.
- Current examples and test runs often use shared FI and rack passwords for convenience; per-device credential values and refs should also be considered supported by the claim target contract and credential-resolution path, even though that is not the primary test shape today.
- Secret-manager-native references such as `vault://...` are expected to be revisited in a later hardening pass; the current implementation keeps the credential contract explicit so the phased claim flow can be validated end to end first.
- Validation timing can still exceed claim submission timing, especially on appliance backends where inventory convergence lags behind `appliance.DeviceClaim` submission.
- Customers can omit Assist and storage entirely; Assist dependency handling only applies when a storage target references an Assist in the current claim run.
