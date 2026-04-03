# normalize-claim-results

Standalone Jarvis grain for merging claim outputs from multiple claim grains into one stable result contract.

## Intent

- consume native result arrays from appliance and SaaS claim grains
- preserve per-target result detail
- export one stable normalized summary for downstream blueprint steps

## Required inputs

- `appliance_claim_results_json`
- `saas_claim_results_json`

## Current behavior

- combines both result arrays into one ordered `results` list
- counts:
  - successful
  - failed
  - conflict
  - skipped
  - changed
- marks `batch_status` as `failed` when any normalized result has `status: failed`; otherwise `successful`

## Outputs

- `normalized_claim_results_json`
- `normalized_claim_batch_status`
- `normalized_claim_successful_count`
- `normalized_claim_failed_count`
- `normalized_claim_conflict_count`
- `normalized_claim_skipped_count`
- `normalized_claim_changed_count`
