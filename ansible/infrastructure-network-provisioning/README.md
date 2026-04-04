# infrastructure-network-provisioning

First working infrastructure network phase grain.

## Intent

- consume discovery outputs from the shared infrastructure-domain model grain
- determine whether FI-managed shared network foundation applies to the current infrastructure-domain
- build a concrete reusable shared-network foundation plan for later implementation
- export an explicit phase readiness contract without pretending shared network mutation is already implemented

## Required inputs

- `discovery_model_json`
- `discovery_summary_json`

## Optional inputs

- `execution_intent`

## Outputs

- `phase_ready`
- `phase_status`
- `phase_readiness_json`
- `network_foundation_plan_json`
- `network_foundation_summary_json`

## Current behavior

- if the infrastructure-domain has no fabric interconnect-managed foundation, the phase returns `not_applicable`
- if FI-managed foundation is present, the phase returns a planned shared-network foundation contract and marks the phase `planned_only`
- this first working slice does not mutate Intersight network objects yet

## Shared network examples in scope

- switch control policy
- system QoS policy
- NTP policy
- shared network connectivity policy
- shared port policy
- switch cluster profile and switch profiles

## Relationship to the stack

- this grain is the current implementation anchor behind the `infrastructure-network-provisioning` phase concept
- later `solution-network-provisioning` should consume the reusable shared-network foundation rather than redefining it
