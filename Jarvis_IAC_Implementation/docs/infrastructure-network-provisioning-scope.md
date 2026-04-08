# Infrastructure Network Provisioning Scope

## Purpose

Define the scope of the `infrastructure-network-provisioning` phase before
finalizing schema, grain boundaries, or implementation details.

This document uses the high-level Jarvis architecture as the primary frame and
captures the current target provider, scope limits, and future extensibility.

## Phase Name

The phase name remains:

- `infrastructure-network-provisioning`

This name should stay broad.

Reason:

- today the implementation target is Cisco Intersight Managed Mode for
  FI-attached UCS domains
- tomorrow the same phase could support another infrastructure network
  provider such as Nexus

The phase name should describe the architectural responsibility, not only the
first provider implementation.

## Current Provider Scope

The current provider scope is:

- `intersight_imm_domain`

Meaning:

- Cisco Intersight Managed Mode
- Fabric Interconnect attached UCS domains
- Domain Profile oriented provisioning

This phase is not currently planned for:

- Unified Edge
- Direct server-only policy targets
- non-Intersight providers in the first implementation

## Architectural Responsibility

`infrastructure-network-provisioning` is the shared infrastructure phase that
realizes reusable FI and fabric/domain foundation for an
`infrastructure-domain`.

It is the continuation of onboarding/discovery and uses the normalized
infrastructure context already gathered by earlier phases.

This phase should:

- consume onboarding/discovery context
- resolve the effective shared-fabric baseline from built-in catalogs, optional
  customer baseline overrides, and launch-time overrides
- use Intersight as the operational source of truth
- create or reconcile shared domain-profile and fabric-side objects
- deploy the resulting domain configuration when required
- validate that the shared infrastructure foundation is stable and ready for
  downstream phases

## In Scope

For the current `intersight_imm_domain` provider, this phase includes:

- FI model-aware provisioning behavior
- domain profile realization
- switch profile realization
- port policy realization
- physical FI port management
- unified-port related configuration decisions
- breakout related configuration decisions
- server port realization
- uplink port realization
- uplink port-channel realization
- shared domain-level policy realization when reusable across later solutions
- shared switch and fabric policy realization
- policy attachment to switch/domain profile objects
- deploy-needed checks
- profile deployment
- validation of primary managed objects created or reconciled by automation
- tagging of high-level managed objects to show automation ownership

## Explicitly Out Of Scope

This phase does not own:

- solution-specific VLAN intent
- application-specific network intent
- tenant or workload-specific network constructs
- later logical network consumption and attachment
- Unified Edge profile targets
- Direct server-only policy targets
- non-IMM target-family semantics in the first implementation

Also out of scope for the main provisioning flow:

- deep validation of all child objects created as a side effect of deployment

That secondary validation may still belong to the overall effort, but it may be
implemented as a separate blueprint or separate validation grains.

## Relationship To Onboarding

This phase is a continuation of onboarding.

It should carry forward the existing broad orchestration context, especially:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`
- optional `site_yaml`
- optional baseline and override inputs

It should not require the customer to re-enter raw inventory facts already
resolved by onboarding unless a value is truly phase-specific.

## Customer-Facing Input Intent

The customer-facing surface for this phase should remain small.

The blueprint is expected to ask for:

- naming prefix
- platform and placement context
- onboarding or discovery-derived domain context
- per-domain port mapping profile selection
- per-domain domain policy profile selection
- a small number of phase-specific required refinements when needed
- optional customer baseline source for shared-fabric policy/profile overrides

The blueprint should avoid exposing low-level implementation details unless
those values are truly required to make a valid provisioning decision.

## Source Of Truth Rules

For the first implementation:

- Intersight is the source of truth for live FI/domain identity and state
- Cisco documentation and OpenAPI references are the product and API truth
- local repos are references for patterns, not authoritative behavior

This means:

- live object discovery and validation should be based on Intersight
- FI model identity should come from Intersight when available
- existing object reconciliation should depend on Intersight state
- local catalogs define intent, not live truth

## Ownership Model

This phase is responsible for objects it creates or reconciles as part of the
shared domain foundation.

Those objects should carry:

- deterministic names
- automation ownership tags
- enough metadata to identify deployment, catalog/profile selection, and
  managed-by relationship

The intent is to make it clear which objects are automation-managed and safe to
reconcile in later runs.

For v1, tagging is not yet implemented. It remains in scope architecturally,
but is deferred as a separate cross-phase construct so it can be applied
consistently across onboarding, `infrastructure-network-provisioning`, and
later phases rather than being introduced ad hoc in only one phase.

## Validation Model Boundary

Primary validation belongs in this phase when it checks:

- requested inputs and catalogs are valid
- managed objects exist
- managed objects are attached correctly
- managed objects are deployed when required
- managed objects have reached an acceptable operational state

Secondary validation may be separated when it checks:

- downstream or child objects created indirectly by profile deployment
- deeper deployment-result validation that is not required to complete the main
  provisioning phase safely

## Future Extensibility

This phase should be designed so the architectural contract survives a provider
change.

Examples of future provider families:

- `intersight_imm_domain`
- `nexus`

The provider-specific realization may differ, but the architectural phase can
remain stable if we keep these layers separate:

- phase scope
- provider target family
- baseline/catalog abstraction model
- provider realization logic

## Summary

`infrastructure-network-provisioning` is the shared infrastructure phase that
provisions reusable network and fabric/domain foundation.

For the current implementation, it means:

- Cisco Intersight Managed Mode
- FI-attached UCS domain targets
- domain profile and physical FI/domain policy realization
- deploy and validate shared infrastructure foundation

It does not mean:

- solution/application logical networking
- Unified Edge
- Direct-only server policy targets
- provider-specific scope baked permanently into the phase name
