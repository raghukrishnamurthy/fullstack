# Infrastructure Network Provisioning Planning

## Purpose

Consolidate the current planning decisions for
`infrastructure-network-provisioning` into one working design reference.

This document is planning-oriented.

It does not finalize implementation details, but it does capture the current
intended shape of:

- phase scope
- current provider scope
- supported models
- customer-facing inputs
- built-in profile model
- object ownership expectations
- validation boundaries
- Torque-friendly execution shape
- deferred cross-phase backlog items

## Phase Identity

Phase name:

- `infrastructure-network-provisioning`

The phase name stays broad on purpose.

Reason:

- today the implementation target is Cisco Intersight Managed Mode for
  FI-attached UCS domains
- tomorrow the same architectural phase could support another provider such as
  Nexus

Current provider target family:

- `intersight_imm_domain`

## Current Provider Scope

The first implementation is for:

- Cisco Intersight Managed Mode
- FI-attached UCS domains
- Domain Profile oriented provisioning

Not currently in scope:

- Unified Edge
- Direct-only server policy targets
- non-Intersight providers in the first implementation

## High-Level Goal

Create a catalog-driven, Torque-friendly Ansible model for provisioning shared
FI and domain-level network foundation.

The automation should:

- consume onboarding/discovery context
- resolve a model-aware shared baseline
- create and manage shared domain-profile and related policy objects
- deploy when needed
- validate resulting shared infrastructure state

## Architectural Boundary

This phase owns shared physical/domain network foundation.

It includes:

- physical FI port management
- port-policy realization
- shared switch and domain policy realization
- domain-profile and switch-profile creation
- policy attachment
- deploy-needed checks
- deployment
- validation of primary managed objects

It does not own:

- solution/application VLAN intent
- VSAN intent
- tenant or workload logical network consumption
- Unified Edge or Direct target families

## Relationship To Onboarding

This phase is a continuation of onboarding.

It should carry forward broad wrapped context such as:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`
- optional `site_yaml`
- optional solution/baseline/override context when useful

It should not require the user to re-enter raw infrastructure facts already
resolved by onboarding unless they are truly phase-specific refinements.

## Deferred Cross-Phase Backlog

The following concern is intentionally deferred from the first implementation
of this phase so it can be solved once and applied consistently across
multiple phases:

- shared tagging contract across onboarding, infrastructure-network-provisioning,
  and later phases

Current intent:

- onboarding should eventually tag claimed/direct-connected targets with a
  shared deployment identity such as `cisco_ztp.DeploymentName`
- infrastructure-network-provisioning should eventually tag the objects it
  creates using the same shared tagging model

Current decision:

- keep tagging in scope architecturally
- do not add ad hoc phase-specific tagging in v1
- document tagging as a separate shared construct to be implemented later

## Source Of Truth

For this phase:

- Intersight is the source of truth for live object state
- Cisco product docs and OpenAPI references are the behavioral truth
- local repos and CVDs are implementation/design references

References may guide profile contents and workflow shape, but should not be
treated as authoritative product behavior.

## Supported FI Models

The planning intent is to support all initial target FI models in the model
layer:

- `UCS-FI-6454`
- `UCS-FI-6536`
- `UCS-FI-6652`
- `UCS-FI-6664`

The resolver should use recommended settings based on recommended port mappings
for the discovered model and selected port-mapping profile.

## Built-In Port Mapping Profiles

Built-in v1 customer-facing choices:

- `ethernet`
- `ethernet_fc`

Planned but not exposed in the first cut:

- `ethernet_breakout`
- `ethernet_fc_breakout`

Planning rule:

- implement the model cleanly so these future profiles can be added without a
  major refactor
- keep the initial exposed surface smaller than the internal model capability

## Built-In Policy Profiles

Built-in v1 customer-facing choices:

- `default`
- `recommended`

For the first iteration, `default` and `recommended` should differ mainly by
policy values, not by policy membership.

This keeps the model simple.

## Initial Policy Set

Initial shared physical/domain policy set:

- `port_policy`
- `switch_control_policy`
- `system_qos_policy`
- `ntp_policy`
- `network_connectivity_policy`

Near-term expansion candidate:

- `flow_control_policy`

Deferred for now:

- `multicast_policy`

Reason for deferral:

- it may be needed later
- but we want the first slice focused on clearly physical/shared domain
  concerns and keep the initial design smaller

Out of scope for this phase:

- `vlan_policy`
- `vsan_policy`

These are treated as solution/application concerns for the current planning
boundary.

## Policy Profile Meaning

For the current model:

- policy profiles select value sets for the in-scope physical/shared policies
- they do not control creation of the profile container objects themselves

The framework always creates:

- domain profile container
- switch profile A
- switch profile B
- attachments and deploy flow

Policy profiles only influence the policy set values.

## Naming Model

The customer provides:

- `<name-prefix>`

Automation generates deterministic names by appending fixed suffixes.

Examples:

- `<name-prefix>-Port-Policy`
- `<name-prefix>-Switch-Control`
- `<name-prefix>-System-QoS`
- `<name-prefix>-NTP`
- `<name-prefix>-Network-Connectivity`
- `<name-prefix>-Domain-Profile`
- `<name-prefix>-A`
- `<name-prefix>-B`

No separate naming profile is needed in the first iteration.

## Customer-Facing Input Model

The goal is to keep the customer-facing input surface small.

Likely inputs:

- `name_prefix`
- platform/Intersight context
- placement context
- onboarding/discovery-derived domain context
- global `policy_profile`
- global `port_mapping_profile`
- optional per-domain `policy_profile`
- optional per-domain `port_mapping_profile`
- a small number of required phase refinements when needed
  - for example `uplink_port_channel_id`

## Global Versus Per-Domain Selection

The actual support model is per FI pair/domain.

Global selection may exist as a convenience artifact, similar to global
credential defaults.

Meaning:

- global values provide a default
- per-domain values are the real granular selection and override the global
  choice when specified

This applies especially to:

- `policy_profile`
- `port_mapping_profile`

## Built-In Versus Customer Baseline Model

The broader architecture should remain clean enough to support future customer
baseline sources.

However, the first iteration should stay simpler:

- built-in profiles only
- no customer baseline merge logic yet
- no customer policy-override YAML yet

Still, implementation should be structured so that later additions are easier:

- keep a resolver layer
- keep selection separate from resolved model output
- avoid hard-coding assumptions that prevent future baseline or override
  support

## Future Customer Override Direction

Not planned for the first iteration, but likely future shape:

- customer supplies a single YAML or JSON document
- the document carries sparse policy overrides only
- those overrides are normalized into the shared model and merged in memory

This future direction should influence implementation cleanliness, but should
not expand the v1 feature set.

## Object Ownership Model

Automation should create and manage:

- shared domain-profile related objects
- selected shared policies
- policy attachments

Managed high-level objects should carry tags that indicate automation ownership.

Tag details are not finalized yet, but the intent is to identify:

- managed by automation
- deployment or prefix identity
- domain identity where needed
- current provider family

## Validation Model

Validation is required for the objects created or managed by the framework.

Primary validation belongs in this phase:

- model/input contract validation
- managed object existence validation
- attachment validation
- deployment-state validation
- resulting shared-foundation readiness validation

Secondary validation may be separated:

- validation of child or downstream objects created indirectly by profile
  deployment
- deeper deployment-result validation that may belong in another blueprint or
  another grain chain

## Recommended Port Mapping Rule

The planning intent is:

- use recommended settings derived from recommended port mappings per FI model

This means:

- discovered FI model determines capabilities and recommended ranges
- selected port-mapping profile determines the style
- the resolver composes the resulting recommended port layout

## Torque-Friendly Delivery Goal

The outcome of planning should be a Torque-like sequence of Ansible task groups
that can later be converted into grains and a blueprint.

High-level planned sequence:

1. resolve effective infrastructure-network provisioning model
2. discover or refresh live Intersight FI/domain state
3. validate selected model against discovered capabilities
4. create or reconcile shared policies
5. create or reconcile domain profile and switch profiles
6. attach policies
7. perform deploy-needed checks and deploy
8. validate realized state
9. export stable outputs

## What Is Still Pending

The main planning items still to be finalized are:

- exact v1 schema fields
- exact per-domain input contract
- exact value differences between `default` and `recommended`
- exact contents of `ethernet` and `ethernet_fc`
- exact FI model matrix details used by the resolver
- exact tag keys
- exact blocking versus advisory validations
- whether `flow_control_policy` enters the first implementation

## Summary

The current planning model is:

- broad architectural phase name:
  - `infrastructure-network-provisioning`
- first provider target:
  - `intersight_imm_domain`
- supported model family:
  - `6454`, `6536`, `6652`, `6664`
- built-in v1 user-facing choices:
  - `policy_profile`: `default`, `recommended`
  - `port_mapping_profile`: `ethernet`, `ethernet_fc`
- initial policy set:
  - `port_policy`
  - `switch_control_policy`
  - `system_qos_policy`
  - `ntp_policy`
  - `network_connectivity_policy`
- prefix-driven naming
- per-domain selection with optional global defaults
- built-in only for the first iteration
- clean resolver-oriented implementation so future baseline and override support
  can be added later
