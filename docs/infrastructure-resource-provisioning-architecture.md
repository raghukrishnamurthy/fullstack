# Infrastructure Resource Provisioning Architecture

Purpose:

- Define the infrastructure phase that provisions shared resource-layer infrastructure for an `infrastructure-domain`
- Establish reusable chassis-oriented and shared management-plane resource configuration after onboarding and shared network foundation are ready
- Keep solution-specific subset consumption and later logical server usage out of this phase

Phase boundary:

- this phase provisions shared resource-layer infrastructure for the infrastructure-domain
- it includes chassis-oriented provisioning and shared management-plane resource setup
- it may include shared server-side management defaults such as DNS, NTP, syslog, SNMP, IMC access, or other solution-agnostic settings
- it should not own solution-specific server consumption, role assignment, or policies that depend on which subset of resources a later solution uses

Input model:

This phase is expected to use shared YAML-shaped stack context.

Required shared inputs:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`

Common optional inputs:

- `site_yaml`
- `solution_yaml`
- `baseline_input_source`
- `baseline_directory`
- `overrides_yaml`
- `validation_mode`
- `execution_intent`

Configuration model:

- this phase should consume the effective infrastructure model already assembled from baselines, inventory-context-derived facts, model defaults, and default policies
- the effective model should distinguish between:
  - shared resource foundation expectations that belong here
  - later solution-specific resource mapping or policies that should remain in solution provisioning phases

Planned internal behavior:

1. re-read current resource-layer state from Intersight
   - discover relevant chassis, blades, standalone servers, management-plane resource objects, and shared policy state
   - confirm whether the infrastructure-domain already has the expected reusable resource foundation

2. compose or resolve shared resource foundation configuration
   - chassis-oriented provisioning
   - shared management-plane resource setup
   - shared server-side defaults that are solution-agnostic
   - other reusable infrastructure-domain resource expectations derived from the effective infrastructure model

3. apply changes only when required
   - remain idempotent
   - avoid assigning or consuming resources in ways that are specific to a later solution deployment

4. validate resulting resource-layer readiness
   - confirm reusable resource objects are present and stable
   - confirm shared management-plane defaults are in the expected state
   - confirm the infrastructure-domain is ready for later solution-side resource consumption

5. build phase validation summary
   - summarize whether reusable resource-layer infrastructure is ready for later solution provisioning

What belongs here:

- chassis-oriented provisioning for the reusable infrastructure-domain
- shared management-plane resource configuration
- shared server-side defaults such as common DNS, NTP, syslog, SNMP, IMC access, and similar solution-agnostic settings
- concrete reusable chassis-profile and management-policy realization that later solution phases can depend on
- reusable resource-layer validation that later solution phases can depend on

What does not belong here:

- selecting which subset of resources a particular solution will consume
- solution-specific IPMI or user policies tied to a chosen subset
- solution-specific operating-system, application, or logical workload preparation
- any resource assignment whose meaning depends on one later solution deployment rather than the reusable infrastructure-domain

Phase output model:

Primary phase result:

- `phase_readiness`

Supporting outputs may include:

- resource foundation validation summary
- shared chassis and server resource summary
- management-plane default summary
- troubleshooting detail for reusable resource realization

Readiness meaning:

This phase should be considered ready when:

- shared resource-layer objects required by the infrastructure-domain are present or reconciled
- reusable chassis and server-side management defaults are realized in the expected form
- the resulting infrastructure-domain is validated as ready for downstream solution-side resource consumption

Behavior expectations:

- idempotent execution is required
- the phase may complete quickly when the expected resource foundation is already present
- the phase should re-read current Intersight state before and after changes
- later solution phases should consume this reusable resource foundation rather than redefining it

Relationship to later phases:

- later solution phases consume subsets of the reusable resource foundation established here
- `solution-network-provisioning` and later `solution-compute-provisioning` should treat this phase as the point where shared infrastructure resources are ready to be mapped to a specific solution
