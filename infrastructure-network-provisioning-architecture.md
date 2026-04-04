# Infrastructure Network Provisioning Architecture

Purpose:

- Define the infrastructure phase that establishes shared FI and fabric/network foundation for an `infrastructure-domain`
- Keep shared infrastructure-network provisioning separate from later solution-specific logical network provisioning
- Treat Cisco Intersight as the operational source of truth for current switch, profile, and policy state before and after changes

Phase boundary:

- this phase provisions shared FI and fabric/network foundation
- it may drive discovery that depends on FI-managed infrastructure when applicable
- it should validate that the resulting shared network-side infrastructure is stable and ready for later infrastructure-resource provisioning
- it should not own later solution-specific VLAN attachment, network intent mapping, or other logical network consumption concerns

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

- this phase should consume the effective infrastructure model assembled from baselines, inventory-context-derived facts, model defaults, and default policies
- FI model-specific defaults and policy composition should be derived by the model-building side rather than embedded ad hoc in the deployment phase
- shared port, switch, and fabric policy expectations belong here when they are solution-agnostic

Planned internal behavior:

1. re-read current Intersight network-side state
   - discover relevant FI, domain, switch profile, and related fabric resources
   - confirm whether the infrastructure-domain has the expected shared network foundation already present

2. compose or resolve shared network foundation resources
   - shared port policy expectations
   - shared switch or domain profile expectations
   - shared network connectivity and common policy attachments
   - other solution-agnostic fabric-side policies required for the infrastructure-domain

3. apply changes only when required
   - remain idempotent
   - avoid mutating later solution-specific logical network constructs

4. validate stability before and after changes
   - verify switch or profile objects exist before attachment or deployment operations
   - wait for profiles or equivalent network-side resources to reach a stable state before further mutation
   - validate resulting profile or deploy state after changes complete

5. build phase validation summary
   - summarize whether shared FI and fabric/network foundation is ready for the next infrastructure phase

What belongs here:

- FI-managed shared network foundation
- common switch or domain profile realization
- shared fabric-side policy composition and validation
- stability checks around profile attachment and deployment

What does not belong here:

- solution-specific VLAN intent
- VLAN group composition for a particular solution
- later logical network attachment for a consuming solution subset
- any network configuration whose meaning depends on a single solution deployment rather than the reusable infrastructure-domain

Phase output model:

Primary phase result:

- `phase_readiness`

Supporting outputs may include:

- network foundation validation summary
- shared fabric object summary
- profile stability or deployment summary
- policy realization details for troubleshooting

Readiness meaning:

This phase should be considered ready when:

- shared FI and fabric/network resources required by the infrastructure-domain are present or reconciled
- common network-side policies are realized in the expected reusable form
- profile or deploy state is stable after any required changes
- the resulting shared network foundation is ready for downstream infrastructure-resource provisioning

Behavior expectations:

- idempotent execution is required
- the phase may complete quickly when the expected shared network foundation is already present
- the phase should re-read current Intersight state before and after changes
- later solution-network phases should build on this foundation rather than redefining it

Relationship to later phases:

- `infrastructure-resource-provisioning` consumes the shared network foundation established here
- later `solution-network-provisioning` should focus on logical network consumption and attachment for a selected solution subset, not on rebuilding shared fabric foundation
