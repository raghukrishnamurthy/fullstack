# build-infrastructure-onboarding-targets

Purpose:

- derive direct onboarding targets for the infrastructure onboarding phase
- read `inventory_yaml` and emit the target lists consumed by later grains
- keep target-list construction out of `resolve*`

Grain inputs:

- `inventory_yaml`

Exported outputs:

- `claim_targets_json`
- `reset_targets_json`

Current target rules:

- `fi_pair` domains become one FI claim target using the first member management IP
- standalone rack servers with `mgmt_ip` become direct claim targets
- standalone rack servers also become reset targets
- child devices without direct management endpoints are not included

Destroy behavior:

- `teardown.yaml` is a no-op
- exports `destroy_status` and `destroy_results_json`
