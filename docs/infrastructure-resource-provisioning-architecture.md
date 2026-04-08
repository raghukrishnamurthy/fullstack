# Infrastructure Resource Provisioning Architecture

## Purpose

Define the first architecture shape for
`infrastructure-resource-provisioning`.

This phase starts after:

1. onboarding
2. `infrastructure-network-provisioning`
3. `infrastructure domain validator`

Its purpose is to provision shared infrastructure resources that are consumed
later by solution-specific workflows.

## Why This Phase Exists

Shared FI/domain foundation is not enough for resource consumption.

Before solution layers begin server-side work, the infrastructure side still
needs a place to manage:

- chassis profile resources
- later CIMC or server-adjacent resources
- later shared logical network plumbing such as VLANs and VSANs

This keeps solution phases from mutating shared domain resources directly.

## Core Rules

- onboarding inventory remains the expected model
- Intersight is the live source of truth
- this phase provisions shared consumable infrastructure resources
- solution phases should prefer consuming these resources instead of creating
  shared domain resources themselves
- complex blueprint inputs should remain JSON-first
- implementation should stay Torque-ready, but local Ansible validation is the
  first execution target

## Initial Stage Breakdown

### Stage 1: Chassis Profiles

First implementation slice:

- create shared chassis Power and Thermal policies
- create or reconcile one shared chassis profile template from the selected variant
- derive one chassis profile per discovered chassis from that template
- deploy only the derived profiles that actually show pending-change semantics

Current v1 policy set:

- `chassis_power_policy`
- `chassis_thermal_policy`

Current v1 model:

- one shared Power policy per selected variant
- one shared Thermal policy per selected variant
- one shared chassis profile template definition per selected variant
- derive and assign per-chassis profiles from that template for all discovered chassis by default
- no per-chassis overrides in v1

### Stage 2: CIMC / Server-Side Resources

Later work:

- server-adjacent policies that are more naturally associated with server
  profiles or direct endpoint behavior
- blade/CIMC-specific policy handling

This stage is intentionally deferred.

### Stage 3: Shared Logical Network Resources

Later work:

- VLANs
- VSANs
- related domain-level logical network plumbing and shared policies

This stage is intentionally kept outside solution-owned mutation so that
parallel solutions do not contend on repeated domain-profile changes.

## Inputs

Expected outer inputs should remain consistent with earlier phases:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`
- `site_yaml`
- `solution_yaml`

Later, this phase may also need additional JSON-first selectors such as:

- `chassis_profile_variant`
- `resource_profile_selections_json`

## Source Of Truth Model

- onboarding inventory identifies expected infrastructure scope
- live Intersight discovery identifies actual chassis and other resource
  targets
- policy realization should be based on the discovered live target set
- if inventory expects chassis but live chassis endpoints are empty, the phase
  should report a readiness gap instead of creating placeholder targets

This phase should not depend on previous phase outputs for correctness.
Previous outputs may be useful as hints, but not as required truth.

## Catalog Shape

Current chassis-resource catalog layers are:

- `catalog/chassis_profile_profiles/<profile>.yaml`
- `catalog/chassis_profile_policies/<profile>/<policy>.yaml`
- `catalog/chassis_profile_policies/supported.yaml`

The current shared bundle model is:

- `default`
- `recommended`

where each bundle includes:

- `chassis_power_policy`
- `chassis_thermal_policy`

## Template And Async Model

Current v1 chassis realization uses the profile-template pattern:

- shared Power and Thermal policies are attached to one shared
  `chassis.ProfileTemplate`
- one derived `chassis.Profile` is maintained per discovered chassis
- assignment remains target-specific on the derived profile
- deploy is driven by derived profile state, not by unconditional replay

Internal convergence for chassis profiles uses profile-state signals:

- `ConfigContext.ConfigState`
- `ConfigContext.InconsistencyReason`

Current deploy-needed states are treated as:

- `Pending-changes`
- `Assigned`
- `Inconsistent`
- `Out-of-sync`

`Associated` is treated as the clean success state.

Workflow information is supplemental only. It may be captured when present,
but profile object state remains the primary internal validator contract.

## Current Recommended Defaults

### Chassis Power Policy

Current default baseline:

- `power_redundancy: Grid`
- `power_save_mode: Enabled`
- `dynamic_power_rebalancing: Enabled`
- `extended_power_capacity: Enabled`
- `power_allocation: 0`

Current recommended-for-testing baseline:

- `power_redundancy: N+1`
- `power_save_mode: Enabled`
- `dynamic_power_rebalancing: Enabled`
- `extended_power_capacity: Enabled`
- `power_allocation: 0`

### Chassis Thermal Policy

Current default and recommended baseline:

- `fan_control_mode: Balanced`

## Ownership Boundaries

`infrastructure-network-provisioning` owns:

- FI/domain network foundation
- switch/domain profile realization
- FI-side shared network/domain policies

`infrastructure domain validator` owns:

- readiness validation of discovered infrastructure before this phase begins

`infrastructure-resource-provisioning` owns:

- shared consumable chassis resources first
- later server-adjacent and shared logical network resources

solution phases should own:

- server-side attachment and consumption
- not repeated creation of shared domain-wide resources

## Future Expansion Candidates

Chassis-profile later candidates:

- `chassis_imc_access_policy`
- `chassis_snmp_policy`

Server-side later candidates should be inventoried separately from chassis
profile policy work.

## Implementation Guardrails

- avoid recursive self-reference in Ansible facts
- build current-pass facts first, then final summary objects
- keep discovery and realization separated
- prefer shared template and shared policy reuse over per-chassis object sprawl in v1
- add per-chassis overrides only when a real requirement appears

## Initial Success Criteria

- selected chassis profile variant resolves cleanly from catalog
- shared chassis Power and Thermal policies are realized correctly
- the shared chassis profile template is realized correctly
- all discovered chassis in scope receive the intended derived profile/policies
- reruns are no-op when derived profiles are already clean
- template or policy changes only deploy derived profiles that need reconciliation
- outputs are suitable for later server-side resource work
