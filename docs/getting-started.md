# Getting Started

Use this path when you want to understand or safely exercise the current repo without guessing where to begin.

## Read First

1. [README.md](/Users/rkrishn2/Documents/Jarvis_IAC/README.md)
   Repo entry point, structure, and current scope.
2. [docs/README.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/README.md)
   Index for implementation guides and reference material.
3. [docs/catalog-ui.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/catalog-ui.md)
   Current user-facing launch contract.
4. [docs/wiring-table.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/wiring-table.md)
   Grain wiring and output flow.
5. [docs/blueprint-test-inputs.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/blueprint-test-inputs.md)
   Reusable first-run inputs.

## Run First

- Start with [blueprints/infrastructure-onboard-devices.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/infrastructure-onboard-devices.yaml) for the active onboarding phase.
- The current phase blueprints use JSON-string launch context on the public surface, even when downstream grains still consume YAML-shaped internal contracts.
- Use [examples/ai-pod-sjc01-prod/infrastructure-onboard-devices-torque-inputs.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/examples/ai-pod-sjc01-prod/infrastructure-onboard-devices-torque-inputs.yaml) as the current sample launch input set.

## Modes

- `validation_mode: strict`
  Validates the contract only. Use this first.
- `validation_mode: live`
  Queries live Intersight state. Use when credentials and runtime connectivity are available.
- `execution_intent: validate_only`
  Non-mutating path. Preferred first run.
- `execution_intent: apply`
  Performs the real onboarding/claim path for currently supported targets.

## Local Checks

- `./scripts/run_example_strict.sh`
  Safe contract validation run.
- `./scripts/run_example_strict_checked.sh`
  Strict run plus lightweight assertions.
- `./scripts/run_example_live.sh`
  Live validation run.
- `./scripts/run_example_live_checked.sh`
  Live validation plus lightweight assertions.
- `./scripts/check_docs.sh`
  Verifies the key docs structure and catches stale path references after repo reorganization.
- `./scripts/check_blueprints.sh`
  Parses the published blueprints and verifies that referenced repo-local grain and asset paths exist.
- `./scripts/check_repo.sh`
  Runs the lightweight docs and blueprint checks together.

## Secrets

- Control-plane Intersight credentials stay as launch inputs.
- Device-side secrets prefer the encrypted bundle path:
  - `encrypted_device_secret_bundle_path`
  - `device_secret_bundle_key`
- See [docs/secret-handling-runbook.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/secret-handling-runbook.md) for the full pattern.
