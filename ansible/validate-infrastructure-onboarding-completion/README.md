# validate-infrastructure-onboarding-completion

Validation and completion grain for the `infrastructure-onboard-devices` phase.

## Intent

- consume the built discovery/onboarding model
- interpret preflight readiness, onboarding action execution, and live-validation evidence
- publish the final phase completion contract that higher-level blueprints can depend on

## Required inputs

- `discovery_model_json`

## Optional inputs

- `wait_for_completion`
- `validation_poll_interval`
- `validation_timeout_seconds`

## Outputs

- `phase_ready`
- `phase_status`
- `phase_readiness_json`

## Current behavior

- treats the shared model grain as the source of preflight readiness and action history
- reports `ready_for_execution` when preflight checks pass but onboarding has not been executed or verified complete
- reports `onboarding_submitted` when apply-mode claim actions succeeded but final live completion has not been proven yet
- reports `completed` only when the current discovery model shows no missing or not-ready devices under live validation
- can optionally poll Intersight for asynchronous onboarding settlement using the credential refs embedded in the discovery model when those refs resolve at runtime
