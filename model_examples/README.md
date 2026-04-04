# Concrete Model Example

This directory is a concrete example of the v2 infrastructure automation model.

It reflects the current agreed structure:

- deployment = infrastructure boundary
- inventory = physical infrastructure facts and topology
- solution profile = primary integrated deployment profile
- extension = optional higher-layer addition
- delivery scope = automation boundary
- automation-owned logic lives in `baselines/` and `catalog/`
- customer-provided deployment data lives in `inputs/`

Current scope focus:

- onboarding
- network infrastructure provisioning
- server infrastructure provisioning
- OS provisioning

Future scope:

- application provisioning

Directory summary:

- `baselines/`
  automation-owned reusable baseline definitions
- `catalog/`
  automation-owned selectable logic and policy-selection data
- `inputs/`
  customer-provided infrastructure, platform, pools, and solution data

Input model notes:

- input files use one top-level wrapper per domain
- deployments use a single `solution:` object
- infrastructure shape is derived from inventory facts rather than a required `infrastructure_pattern`
- workflow-supporting service endpoints such as Assist belong under `platform.intersight.assists`
- pools are organized by pool type and usage, such as `pools.ip.mgmt` and `pools.ip.os`
- Intersight placement such as organization and resource group lives in `placement.yaml`

Concrete deployment examples:

- `inputs/deployments/sjc01-infra-converged-prod/`
  converged infrastructure example aligned to the v2 input model
- `inputs/deployments/sjc01-infra-standalone-prod/`
  standalone infrastructure example aligned to the v2 input model
- `inputs/deployments/ai-pod-sjc01-prod/`
  AI Pod-oriented example using real-life inventory details for an FI pair, blades, and standalone rack servers
