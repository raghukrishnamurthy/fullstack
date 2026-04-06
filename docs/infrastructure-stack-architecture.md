# Deploy Infrastructure Stack Architecture

Purpose:

- Define the higher-level infrastructure stack that converts bare-metal resources into devices validated and ready for solution consumption
- Keep focused operational blueprints narrow while the infrastructure stack owns broader sequencing and phase readiness
- Treat Cisco Intersight as the durable source of truth between phases instead of relying on large runtime handoff payloads

Core design decisions:

- the stack identity is an `infrastructure-domain`
- each phase is expected to be idempotent
- each phase should re-read deployed state from Intersight before applying additional work
- the stack should favor pre-validation and quick completion when a phase is already satisfied
- phase-to-phase contracts should be minimal; later phases should rely on Intersight state plus shared inventory context
- top-level stacks and lowest-level user-facing operational workflows should get blueprint surfaces first, while middle orchestration layers remain grains until a stronger user-facing boundary is needed
- current discovery and model-building behavior can continue to live in `build-infrastructure-domain-model` for now, with a planned future rename toward `build-infrastructure-domain-model` when the stack naming is implemented
- separate validation/completeness grains are a preferred pattern when a phase must publish reusable post-validation, pre-validation, or cross-check results for other phases and stacks

Current implementation scope:

- this stack is currently implemented as an Intersight-focused orchestration model
- Intersight is the assumed management plane and durable source of truth between phases
- the broader phase model may still apply to non-Intersight stacks later, but those implementations would likely require different internal automation and different phase contracts

Boundary:

- infrastructure provisioning converts bare-metal into usable compute infrastructure
- usable compute infrastructure means devices are validated and ready for solution consumption
- solution provisioning later converts usable compute infrastructure into usable application infrastructure

Shared stack inputs:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`
- `site_yaml`
- `solution_yaml`
- `baseline_input_source`
- `baseline_directory`
- `overrides_yaml`
- `validation_mode`
- `execution_intent`

Input model notes:

- `inventory_yaml` is the shared scope and schema anchor for the infrastructure-domain
- `platform_yaml`, `placement_yaml`, `deployment_yaml`, and optional `site_yaml` provide additional context for where configuration applies
- the effective infrastructure model is assembled from:
  - baselines
  - inventory-context-derived facts
  - model-specific defaults
  - default policies
- later stack phases may accept additional phase-specific logical inputs alongside the shared inventory context

Planned infrastructure phases:

1. `infrastructure-onboard-devices`
   - see [infrastructure-onboard-devices-architecture.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/infrastructure-onboard-devices-architecture.md) for the current phase boundary draft
   - discover candidate devices
   - run standalone rack password reset when needed
   - claim devices into Intersight
   - validate that devices are manageable and ready for later infrastructure phases

2. `infrastructure-network-provisioning`
   - see [infrastructure-network-provisioning-architecture.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/infrastructure-network-provisioning-architecture.md) for the current phase boundary draft
   - establish shared FI and fabric/network foundation for the infrastructure-domain
   - drive discovery that depends on FI-managed infrastructure when applicable
   - validate that network-side infrastructure is ready for broader resource provisioning

3. `infrastructure-resource-provisioning`
   - see [infrastructure-resource-provisioning-architecture.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/infrastructure-resource-provisioning-architecture.md) for the current phase boundary draft
   - provision shared resource-layer infrastructure for the infrastructure-domain
   - include chassis-oriented provisioning and shared management-plane resource setup
   - include only solution-agnostic server-side settings such as common DNS, NTP, and shared management defaults
   - avoid consuming solution-specific subsets or policies that should remain in solution provisioning phases

Readiness model:

- the stack should publish one overall `infrastructure_stack_readiness` result
- per-phase readiness can be included as detailed diagnostics when useful
- the main readiness meaning is:
  - deployed resources validated against the inventory context and effective infrastructure model
  - devices logically ready for downstream solution provisioning

Phase behavior expectations:

- each phase should validate deployed resources against current Intersight state
- each phase may conclude quickly when the expected state is already present
- explicit skip controls may be added later, but idempotent execution is the default design

Relationship to later solution stacks:

- the infrastructure stack prepares a reusable shared foundation
- one or more solutions may later consume a subset of that prepared foundation
- solution phases should decide how to map or select subsets from that shared infrastructure foundation

Planned stack hierarchy:

- `deploy-infrastructure-stack`
  - orchestrates the infrastructure phases above
- `deploy-solution-stack`
  - later consumes a subset of the prepared infrastructure foundation
- `deploy-full-stack`
  - later ties the infrastructure and solution stacks together
