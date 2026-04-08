**Purpose**
`infrastructure domain validator` is the readiness gate between:

- `infrastructure-network-provisioning`
- `infrastructure-resource-provisioning`

It validates that the FI-managed infrastructure domain has converged far enough
in Intersight for resource-layer provisioning to begin.

**Core Rule**
- use the same onboarding inventory as the expected model
- use live Intersight data as the source of truth

The validator must not depend on prior-phase outputs for correctness.
Previous-phase outputs may help with troubleshooting later, but they are not the
primary contract.

**Current Ask**
- basic onboarding inputs
  - `deployment_yaml`
  - `platform_yaml`
  - `placement_yaml`
  - `inventory_yaml`
  - optional `site_yaml`
- wait / poll behavior because domain-profile downstream discovery can take a
  long time to settle

**V1 Validation Scope**
For the first implementation, inspect these discovered object families:

- Fabric Interconnects
- Chassis
- Blades
- FI-managed rack servers
- Standalone rack servers

The first readiness-blocking slice is intentionally narrower:

- Fabric Interconnects
- Chassis count / presence
- Blades

Rack families are still observed and exported in validator details, but they do
not block `phase_ready` in the initial wiring pass.

**V1 Readiness Rules**
Use the same lifecycle/readiness semantics proven in `intersightztp`
`devicesreadiness` where applicable:

- Fabric Interconnect
  - endpoint: `/network/Elements`
  - ready when: `Operability == online`
- Chassis
  - endpoint: `/equipment/Chasses`
  - ready when: present
  - v1 compares discovered chassis count against expected inventory-domain
    chassis count
- Blade
  - endpoint: `/compute/PhysicalSummaries`
  - ready when: `Lifecycle == Active`
  - live validation in the current AI Pod environment confirms FI-managed
    blades appear as `ManagementMode == Intersight`
- FI-managed rack
  - endpoint: `/compute/PhysicalSummaries`
  - observed in v1
  - exact blocking readiness rule is deferred until more live IMM rack samples
    are validated
- Standalone rack
  - endpoint: `/compute/PhysicalSummaries`
  - observed in v1
  - current live sample shape confirms `ManagementMode == IntersightStandalone`
    with presence by serial, but standalone racks are not readiness-blocking in
    the first validator slice

**Current Verified Behavior**
The current validator implementation has been exercised live against the AI Pod
inventory and now correctly:

- matches expected FI serials from `/network/Elements`
- matches expected blade serials from `/compute/PhysicalSummaries`
- compares discovered chassis count from `/equipment/Chasses`

The current proof path still treats rack families as advisory:

- standalone racks can be exported as missing without blocking readiness
- FI-managed rack readiness remains deferred until more live samples are
  validated

**Matching Model**
Physical matching:

- FI by serial from inventory
- blade by serial from inventory
- FI-managed rack by serial from inventory
- standalone rack by serial from inventory
- chassis by discovered count because chassis is not currently modeled as a
  first-class inventory object

Logical matching:

- keep the construct for later expansion
- do not make blade-to-chassis placement validation a required v1 check
- keep rack logical validation out of the blocking path for the first slice

**Readiness Output**
Keep the top-level contract simple:

- `phase_ready`
- `phase_status`
- `phase_readiness_json`

Supporting detail outputs should still be exported for debugging:

- `validation_summary_json`
- `inventory_validation_json`
- `tac_handoff_json`

The detail payloads should distinguish:

- blocking families used for readiness gating
- advisory families that are observed but do not yet block

The current validator implementation exports these scope markers explicitly in
`inventory_validation_json` and `tac_handoff_json`.

**Polling Model**
This is a validation phase with wait behavior.

Suggested v1 inputs:

- `wait_for_readiness`
- `readiness_poll_interval`
- `readiness_max_attempts`

The validator should:

- do one pass when waiting is disabled
- poll until ready or attempt limit when waiting is enabled

This is important because FI-domain discovery and inventory completion may take
up to one to two hours in real environments.

**V1 Boundaries**
In scope:

- readiness gating for the next infrastructure resource phase
- lifecycle-aware validation of FI, chassis count, and blades
- observed reporting for rack families
- physical inventory matching

Not in scope yet:

- blade-to-chassis topology validation
- recovery or mutation of domain configuration
- teardown or undeploy actions
- full resource-layer provisioning

**Design Direction**
This phase should feel similar to the onboarding validator:

- validator-style blueprint
- no remote mutation
- no-op destroy behavior
- clear readiness contract that later phases can depend on

**Implementation Guardrails**
- avoid recursive self-reference in Ansible facts
- do not build a fact by reading the same fact name before it is initialized in
  the current task chain
- prefer staged intermediate facts such as `current_*` and then assign the final
  summary object once per pass
- prefer explicit string prefix/suffix construction for `$filter` clauses over
  regex backreference tricks when building Intersight serial filters
- keep the recursive wait behavior at the task-include level, not by mutating a
  task-local summary object in place across the same task evaluation

The next architected phase after this validator remains:

- `infrastructure-resource-provisioning`
