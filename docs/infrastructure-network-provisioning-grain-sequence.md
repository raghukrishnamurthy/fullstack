# Infrastructure Network Provisioning Grain Sequence

## Purpose

Define a Torque-friendly sequence of Ansible task groups for
`infrastructure-network-provisioning` that can later be converted into grains
and a blueprint.

This sequence uses `/Users/rkrishn2/Documents/domain_profile` as an
implementation reference for workflow shape, not as authoritative behavior.

## Design Goal

Keep the workflow:

- resolver-driven
- Intersight as source of truth
- easy to validate
- easy to split into grains
- clean enough for later customer baseline and override support

## Recommended Grain Chain

### 1. `resolve_infrastructure_network_model`

Purpose:

- consume onboarding/discovery context
- apply global and per-domain selections
- resolve named policy profile and port-mapping profile
- derive recommended per-domain model using the FI model matrix
- build deterministic managed object names

Inputs:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`
- `solution_yaml`
- `site_yaml`
- `name_prefix`
- `policy_profile`
- `port_mapping_profile`
- `domain_profile_selections_json`

Outputs:

- `infrastructure_network_model_json`
- `infrastructure_network_summary_json`

Notes:

- this is the main resolver grain
- in later versions this is where customer baseline and override support can be
  added cleanly

### 2. `discover_infrastructure_network_state`

Purpose:

- refresh live Intersight state for the target FI domains
- resolve actual FI model and current object state
- locate existing shared policies and profile objects when present

Inputs:

- `infrastructure_network_model_json`
- Intersight credentials/context from platform/placement

Outputs:

- `infrastructure_network_live_state_json`
- `infrastructure_network_discovery_summary_json`

Notes:

- Intersight is the source of truth here
- discovery should focus on primary managed objects, not every possible child
  object in v1

### 3. `validate_infrastructure_network_model`

Purpose:

- validate that the selected model is compatible with discovered live state
- validate domain identities, FI models, and profile compatibility
- validate selected policy profile and port-mapping profile against model
  constraints

Inputs:

- `infrastructure_network_model_json`
- `infrastructure_network_live_state_json`

Outputs:

- `infrastructure_network_validation_json`
- `phase_ready`
- `phase_status`
- `phase_readiness_json`

Notes:

- this is the main blocking validation point before mutation

### 4. `realize_infrastructure_network_policies`

Purpose:

- create or reconcile shared policies for each target domain

Initial policy scope:

- `port_policy`
- `switch_control_policy`
- `system_qos_policy`
- `ntp_policy`
- `network_connectivity_policy`

Future candidate:

- `flow_control_policy`

Inputs:

- `infrastructure_network_model_json`
- `infrastructure_network_live_state_json`

Outputs:

- `realized_policy_state_json`
- `policy_realization_summary_json`

Notes:

- this grain should own policy create/update logic
- use deterministic names derived from `<name-prefix>`

### 5. `realize_infrastructure_domain_profiles`

Purpose:

- create or reconcile the domain profile container and switch profiles

Inputs:

- `infrastructure_network_model_json`
- `infrastructure_network_live_state_json`
- `realized_policy_state_json`

Outputs:

- `domain_profile_state_json`
- `domain_profile_summary_json`

Notes:

- this is object realization, not policy selection
- domain profile and switch profiles are framework-owned objects

### 6. `attach_infrastructure_network_policies`

Purpose:

- attach realized shared policies to the domain/switch profiles

Inputs:

- `infrastructure_network_model_json`
- `realized_policy_state_json`
- `domain_profile_state_json`

Outputs:

- `policy_attachment_state_json`
- `policy_attachment_summary_json`

Notes:

- keep attachment logic separate from policy creation to simplify validation and
  retries

### 7. `deploy_infrastructure_domain_profiles`

Purpose:

- perform deploy-needed checks
- deploy the resulting domain profile when required
- wait for terminal deployment state

Inputs:

- `infrastructure_network_model_json`
- `domain_profile_state_json`
- `policy_attachment_state_json`

Outputs:

- `deploy_state_json`
- `deploy_summary_json`

Notes:

- use Intersight state, not only task results, to decide whether deployment is
  needed
- this grain should own pending-change / deploy-needed behavior

### 8. `validate_infrastructure_network_realization`

Purpose:

- validate that primary managed objects exist in Intersight
- validate naming and attachment expectations
- validate deployment reached an acceptable operational state

Inputs:

- `infrastructure_network_model_json`
- `realized_policy_state_json`
- `domain_profile_state_json`
- `policy_attachment_state_json`
- `deploy_state_json`

Outputs:

- `validation_summary_json`
- `managed_object_inventory_json`
- `phase_ready`
- `phase_status`
- `phase_readiness_json`

Notes:

- this is primary validation of framework-managed objects
- deeper child-object validation may be split into another blueprint or grain
  set later

### 9. `summarize_infrastructure_network_provisioning`

Purpose:

- build stable exported outputs for Torque and downstream phases

Inputs:

- all relevant prior summary/state outputs

Outputs:

- `phase_ready`
- `phase_status`
- `phase_readiness_json`
- `infrastructure_network_model_json`
- `infrastructure_network_summary_json`
- `managed_object_inventory_json`
- `validation_summary_json`
- `deploy_summary_json`
- `tac_handoff_json`

## Compression Option

The above is the clean logical split.

For a smaller first implementation, these may be compressed into fewer grains:

1. `resolve_infrastructure_network_model`
2. `discover_and_validate_infrastructure_network`
3. `realize_infrastructure_network_policies`
4. `realize_and_deploy_infrastructure_domain_profiles`
5. `validate_and_summarize_infrastructure_network`

This reduced split may be more practical at the beginning while preserving the
same logical boundaries.

## Suggested v1 Blueprint Shape

The blueprint can chain the reduced v1 split:

1. `resolve_infrastructure_network_model`
2. `discover_and_validate_infrastructure_network`
3. `realize_infrastructure_network_policies`
4. `realize_and_deploy_infrastructure_domain_profiles`
5. `validate_and_summarize_infrastructure_network`

## Reference Mapping To `domain_profile`

Reference ideas borrowed from `/Users/rkrishn2/Documents/domain_profile`:

- separate model resolution from realization
- create policies before domain-profile object realization
- attach policies before deploy
- validate deployment after attach/deploy
- export stable JSON outputs for downstream use

The resulting Jarvis flow is broader in phase naming and cleaner in abstraction
boundaries, but the staged workflow shape is still useful as a reference.
