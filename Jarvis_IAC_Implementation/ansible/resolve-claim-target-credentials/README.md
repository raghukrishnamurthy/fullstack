# resolve-claim-target-credentials

Standalone Jarvis grain for mapping a credential-candidate pool onto claim targets.

## Intent

- keep blueprint and orchestration inputs convenient by allowing a shared credential map
- produce per-target claim credential fields for standalone claim grains
- avoid credential inference inside `claim-devices-to-intersight`

## Required inputs

- `claim_targets_json`
- `credential_candidates_yaml`

## Behavior

- fills internal defaults when missing:
  - `canonical_endpoint`
  - `normalized_claim_key`
  - `claim_submission_required`
- passes through targets that already include:
  - `claim_username`
  - `claim_password_ref`
  - or `claim_password`
- otherwise selects a `credential_role: target` candidate by:
  - `target_category`
  - optional `target_form_factor`
  - optional `target_management_type`
- writes matched values back onto each target as:
  - `claim_username`
  - `claim_password_ref`
  - and `claim_password` when the selected candidate includes a direct password value

## Outputs

- `resolved_claim_targets_json`
