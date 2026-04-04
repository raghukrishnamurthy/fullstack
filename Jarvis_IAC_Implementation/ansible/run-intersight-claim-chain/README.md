# run-intersight-claim-chain

Thin direct-Ansible orchestration playbook for the reusable Intersight claim grains.

## Intent

- provide a non-blueprint execution path that still uses the same reusable grains
- keep `deployment_yaml` and wider input parsing at the orchestration layer
- feed narrow contracts into:
  - `ensure-intersight-context`
  - `resolve-claim-target-credentials`
  - `claim-intersight-devices`

## Required inputs

- `platform_yaml`
- `claim_targets_json`

## Optional inputs

- `deployment_yaml`
- `placement_yaml`
- `organization`
- `credential_candidates_yaml`

## Behavior

- ensures Intersight context first
- maps shared credential candidates onto claim targets when needed
- passes one normalized target contract into the unified claim grain
- the unified claim grain routes to SaaS when the platform endpoint contains `intersight.com`
- the unified claim grain routes to appliance otherwise
- the unified claim grain exports the same final normalized contract the focused blueprint uses

## Examples

- orchestration target example for SaaS:
  [claim_targets.json](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/examples/ai-pod-sjc01-prod/claim_targets.json)
- orchestration target example for appliance:
  [claim_targets.json](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/examples/ai-pod-pva-sjc01-prod/claim_targets.json)
