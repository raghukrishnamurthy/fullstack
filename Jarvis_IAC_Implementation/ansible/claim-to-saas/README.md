# claim-to-saas

Standalone Jarvis grain for claiming already prepared targets into Intersight SaaS.

## Intent

- consume a prepared-target contract rather than raw inventory or factory credentials
- submit claim-ready targets to Intersight SaaS
- deduplicate logical targets by normalized claim key before submission
- export a stable aggregate result contract for a later normalize-results grain

## Required inputs

- `prepared_targets_json`
- `platform_yaml`

## Optional inputs

- `deployment_yaml`
- `placement_yaml`
- `debug_enabled`
- `helper_timeout_seconds`

## Expected prepared target fields

- `endpoint`
- `normalized_claim_key`
- `claim_submission_required`
- `claim_serial_number`
- `claim_security_token`
- optional:
  - `device_type`
  - `location`

## Current behavior

- uses the `platform_yaml` Intersight endpoint and env-backed API credentials
- scopes claims to the placement organization when one is supplied
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
