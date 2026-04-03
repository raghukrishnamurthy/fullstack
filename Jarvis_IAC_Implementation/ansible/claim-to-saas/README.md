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
- `credential_candidates_yaml`
- `desired_credentials_json`

## Expected claim target fields

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
- scopes claims to the direct `organization` input when one is supplied
- otherwise falls back to the placement organization
- can refresh endpoint claim readiness inline from `credential_candidates_yaml` or `desired_credentials_json`
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
