# prepare-device-connector

Purpose:

- expose device connector preparation as an explicit onboarding grain
- reuse the existing connector prepare implementation without changing claim behavior
- return prepared claim targets for the next grain in the phase

Grain inputs:

- `claim_targets_json`
- `platform_yaml`
- `validation_mode`

Exported outputs:

- `connector_prep_results_json`
- `prepared_claim_targets_json`

Execution notes:

- runs on `localhost`
- uses `connection: local`
- expects claim targets that already include resolved credentials
- reuses the shared task implementation currently housed under `build-infrastructure-domain-model`

Destroy behavior:

- `teardown.yaml` is a no-op
- exports `destroy_status` and `destroy_results_json`
