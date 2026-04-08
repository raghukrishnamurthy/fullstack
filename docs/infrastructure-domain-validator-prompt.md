**Purpose**
Working implementation prompt for `infrastructure domain validator`.

```text
Implement and refine the `infrastructure domain validator` phase for Cisco Intersight IMM.

Goal:
Validate that the FI-managed infrastructure domain has converged enough in Intersight before `infrastructure-resource-provisioning` begins.

Core rules:
- Use the same onboarding inventory as the expected model
- Use live Intersight data as the source of truth
- Do not depend on previous phase outputs for correctness
- This is a validator phase, not a provisioning phase
- Support wait/poll lifecycle behavior because downstream discovery may take 1-2 hours

Current v1 validation scope:
Inspect these discovered object families:
- Fabric Interconnects
- Chassis
- Blades
- FI-managed racks
- Standalone racks

Current v1 readiness-blocking scope:
- Fabric Interconnects
- Chassis count / presence
- Blades

Current advisory-only scope:
- FI-managed racks
- Standalone racks

Readiness rules:
- FI:
  - query `/network/Elements`
  - match by serial from inventory
  - ready when `Operability == online`
- Chassis:
  - query `/equipment/Chasses`
  - compare discovered count against expected chassis count from inventory domains
- Blades:
  - query `/compute/PhysicalSummaries`
  - match by serial from inventory
  - ready when `Lifecycle == Active`
- Standalone racks:
  - observed in v1
  - current live sample shows `ManagementMode == IntersightStandalone`
  - not readiness-blocking yet
- FI-managed racks:
  - observed in v1
  - blocking rule deferred until more live samples are validated

Outputs:
- phase_ready
- phase_status
- phase_readiness_json
- validation_summary_json
- inventory_validation_json
- tac_handoff_json

Output expectations:
- distinguish `blocking_scope` and `advisory_scope`
- report missing and not-ready devices separately
- keep top-level readiness simple
- include enough supporting detail for TAC/debug handoff

Behavior:
1. Parse onboarding-style wrapped inputs
2. Resolve Intersight credentials
3. Query live FI, chassis, and compute inventory
4. Match expected inventory against live results
5. Compute blocking readiness
6. Poll until ready or attempt limit when waiting is enabled
7. Export simple readiness plus supporting detail

Implementation guardrails:
- avoid recursive self-reference in Ansible facts
- build current-pass facts first, then assign final summary objects
- keep recursive polling in included-task flow, not a pre-expanded loop
- prefer explicit serial prefix/suffix construction for Intersight `$filter` values
- do not overreach into blade-to-chassis topology validation in v1
- do not mutate remote state in this phase

Success criteria:
- FI and blade presence are matched correctly from live Intersight data
- chassis count validation works
- readiness reflects blocking scope only
- advisory families are still exported for later use
- the phase can cleanly gate `infrastructure-resource-provisioning`
```
