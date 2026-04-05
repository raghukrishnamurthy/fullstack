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
  - current appliance defaults are 600 seconds timeout with 30 second polling to better accommodate fresh Assist claim and control-plane convergence
- appliance direct claims perform a post-submit follow-up enrichment pass so the final aggregate preserves workflow and DeviceClaim evidence
- SaaS direct claims build normalized results through the shared direct-claim result helper without recursive include-var shadowing
- emits both:
  - `results_json`
  - normalized claim outputs matching the previous normalize grain contract

## Appliance storage behavior

- appliance storage claim first checks `/asset/Targets` and short-circuits when the target already exists
- when the storage target is absent, the grain waits for the referenced Assist target to appear and reach `Status: Connected`
- if storage submission returns appliance `messageId: aurora_target_assist_not_setup`, the grain treats that response as retryable for appliance storage only
- retry behavior for `aurora_target_assist_not_setup` is bounded by the same Assist wait budget
- after a successful appliance storage submission, the grain verifies that the storage target appears in `/asset/Targets`
- appliance storage results now preserve:
  - `target_moid`
  - `target_status`
  - `target_workflow_moid`
- if the storage target never appears after submission, the grain fails clearly instead of reporting a false success

## SaaS direct-claim behavior

- SaaS direct claims resolve the claimed `asset.DeviceRegistration` after submission and include `registration_found` and `registration_moid` in normalized results
- normalized SaaS direct-claim results use distinct internal fact names before calling the shared direct-claim result builder
- this avoids recursive templating of `direct_claim_status`, `direct_claim_reason`, and `direct_claim_message`

## Validation summary

- appliance storage claim validation now expects a real appliance-side target object, not just a local submitted result
- successful appliance storage validation should show:
  - populated `target_moid`
  - populated `target_workflow_moid`
  - `target_status` such as `ClaimInProgress`
  - aggregate `appliance_result_count: 1` for the storage claim run
- the latest validated appliance storage run created:
  - target MOID `69d2c0346f7261301ff9d546`
  - workflow MOID `69d2c034696f6e301f295c72`
  - `target_status: ClaimInProgress`
- the latest validated SaaS direct-claim run completed successfully with:
  - `successful_claim_result_count: 5`
  - `blocking_claim_result_count: 0`
  - all five direct targets producing `registration_found: true`
- the latest validated onboarding completion run exported:
  - `phase_ready: "true"`
  - `phase_status: "completed"`
  - `missing_device_count: "0"`
  - `not_ready_device_count: "0"`
  - `present_direct_target_count: "5"`

## Recommended validation checks

- for appliance storage claims, confirm the normalized result contains `target_moid`, `target_status`, and `target_workflow_moid`
- for appliance storage claims, confirm the final result reflects a real `/asset/Targets` object rather than an empty `api_response`
- for SaaS direct claims, confirm each normalized result contains `registration_found: true` and a non-empty `registration_moid`
- for end-to-end readiness validation, confirm:
  - `phase_ready` is `true`
  - `phase_status` is `completed`
  - `blocking_claim_result_count` is `0`
  - `missing_device_count` is `0`
  - `not_ready_device_count` is `0`

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
