# claim-to-saas

Standalone Jarvis grain for claiming target contexts into Intersight SaaS.

## Intent

- consume a claim-target contract rather than raw inventory or factory credentials
- submit claim-ready targets to Intersight SaaS
- deduplicate logical targets by normalized claim key before submission
- export a stable aggregate result contract for a later normalize-results grain

## Required inputs

- `claim_targets_json`
- `platform_yaml`

## Optional inputs

- `deployment_yaml`
- `organization`
- `placement_yaml`
- `debug_enabled`
- `helper_timeout_seconds`

## Expected claim target fields

- `endpoint`
- `normalized_claim_key`
- one of:
  - `claim_serial_number` and `claim_security_token`
  - or `claim_username` and either:
    - `claim_password`
    - `claim_password_ref`
- `claim_submission_required`
- optional:
  - `device_type`
  - `location`
  - `canonical_endpoint`
  - `deployment_name`

## Current behavior

 - uses the `platform_yaml` Intersight endpoint and direct or env-backed API credentials
- scopes claims to the direct `organization` input when one is supplied
- otherwise falls back to the placement organization
 - refreshes endpoint claim readiness inline from per-target `claim_username` plus either direct `claim_password` or env-backed `claim_password_ref` when serial/token data is not already present
- skips duplicate logical targets after the first canonical endpoint
- records already-claimed targets without resubmission when `claim_submission_required` is false

## Outputs

- `batch_status`
- `successful_targets`
- `failed_targets`
- `conflict_targets`
- `skipped_targets`
- `changed_targets`
- `results_json`

## Example

- standalone target example:
  [standalone_saas_claim_targets.json](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/examples/ai-pod-sjc01-prod/standalone_saas_claim_targets.json)
