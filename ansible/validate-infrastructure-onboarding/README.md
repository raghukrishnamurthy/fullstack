# validate-infrastructure-onboarding

Validation and completion grain for the `infrastructure-onboard-devices` phase.

## Intent

- validate onboarding completion for the `infrastructure-onboard-devices` phase
- compare direct onboarding intent from inventory with live Intersight truth
- publish the final phase completion contract that higher-level blueprints can depend on

## Required inputs

- either:
  - `inventory_json` plus API/platform context
- or:
  - `discovery_model_json`

## Optional inputs

- `claim_execution_results_json`
- `wait_for_completion`
- `validation_poll_interval`
- `validation_timeout_seconds`

## Outputs

- `phase_ready`
- `phase_status`
- `phase_readiness_json`

## Current behavior

- validates direct onboarding targets only
- current direct onboarding targets are:
  - declared `fi_pair` Fabric Interconnect domains
  - standalone rack servers with management endpoints
- does not require child devices such as FI-managed chassis or blades to appear before onboarding completes
- does not treat organization or resource-group policy checks as end-validation blockers
- reports `onboarding_submitted` when apply-mode claim actions succeeded but final live completion has not been proven yet
- reports `completed` only when the expected direct onboarding targets are present and ready in Intersight
- can poll Intersight for asynchronous onboarding settlement when `wait_for_completion` is enabled
- polling exits after the first successful completion pass instead of continuing through the remaining loop window
- `phase_readiness_json.summary.present_direct_target_count` is exported as a numeric total of direct racks plus settled FI pairs
