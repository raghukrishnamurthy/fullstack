# run-intersight-claim-chain

Thin direct-Ansible orchestration playbook for the reusable Intersight claim grains.

## Intent

- provide a non-blueprint execution path that still uses the same reusable grains
- keep `deployment_yaml` and wider input parsing at the orchestration layer
- feed narrow contracts into:
  - `ensure-intersight-context`
  - `resolve-claim-target-credentials`
  - `claim-to-saas`
  - `claim-to-appliance`
  - `normalize-claim-results`

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
- routes to SaaS when the platform endpoint contains `intersight.com`
- routes to appliance otherwise
- normalizes results into the same final contract the blueprint uses
