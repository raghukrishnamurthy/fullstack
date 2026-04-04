# claim-to-appliance

Standalone Jarvis grain for claiming claim-target contexts into an Intersight appliance or PVA.

## Intent

- consume a claim-target contract rather than raw inventory or broader discovery outputs
- submit claim-eligible targets to `/appliance/DeviceClaims`
- perform one aggregate workflow and `DeviceClaims` follow-up pass after all submissions
- export a stable aggregate result contract for a later normalize-results grain

## Required inputs

- `claim_targets_json`
- `platform_yaml`
- `organization`

## Optional inputs

- `deployment_yaml`
- `debug_enabled`

## Expected claim target fields

- `endpoint`
- one of:
  - `platform_type`
  - or enough shape to derive it:
    - `target_category`
    - `form_factor`
    - `management_type`
- one of:
  - `claim_username` and either:
    - `claim_password`
    - `claim_password_ref`
  - or `selected_target_credential.username` and either:
    - `selected_target_credential.password`
    - `selected_target_credential.password_ref`
- optional:
  - `canonical_endpoint`
  - `normalized_claim_key`
  - `claim_submission_required`
  - `serial`
  - `target_id`

## Current behavior

- uses the appliance endpoint and direct or env-backed API credentials from `platform_yaml`
- assumes the target organization/context already exists
- scopes claim execution and result reporting to the required direct `organization` input
- does not create or reconcile organizations or resource groups
- records already-claimed targets without resubmission when `claim_submission_required` is false
- enriches submitted targets after a single aggregate follow-up wait

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
  [standalone_appliance_claim_targets.json](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/examples/ai-pod-pva-sjc01-prod/standalone_appliance_claim_targets.json)
