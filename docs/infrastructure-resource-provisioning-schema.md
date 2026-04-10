# Infrastructure Resource Provisioning Schema

## Purpose

Define the current input and output contract for
`infrastructure-resource-provisioning`.

This first cut is intentionally narrow:

- chassis profile provisioning only

## Input Contract

Top-level wrapped inputs should remain consistent with earlier phases:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`
- `solution_yaml`
- `site_yaml`

Phase-specific inputs:

- `name_prefix`
- `chassis_profile`
- `resource_profile_selections_json`
- `execution_intent`
- `lifecycle_action`

## Current Supported Values

### `chassis_profile`

Current built-in bundle ids:

- `default`
- `recommended`

These are names only.

## `resource_profile_selections_json`

Current shape:

```json
{
  "domains": {}
}
```

Reserved for future per-domain or per-resource refinement.

No override merge behavior is implemented yet.

## Resolved Model Shape

The resolver should emit:

- provider family
- deployment id and `name_prefix`
- placement organization
- selected chassis profile bundle id
- selected chassis policies and values
- shared managed object names
- site/global settings when useful later

Illustrative shape:

```yaml
provider:
  family: intersight_imm_resource
deployment:
  id: ai-pod-sjc01-prod
  name_prefix: vf1
placement:
  organization: ai-prod
resource_bundles:
  chassis_profile:
    profile_id: recommended
    included_policies:
      - chassis_power_policy
      - chassis_thermal_policy
    managed_object_names:
      chassis_power_policy: vf1-Chassis-Power
      chassis_thermal_policy: vf1-Chassis-Thermal
      chassis_profile_template: vf1-Chassis-Template
      chassis_profile_prefix: vf1-Chassis
    policy_values:
      chassis_power_policy: ...
      chassis_thermal_policy: ...
```

## Discovery Output Shape

The discovery grain should emit:

- discovered chassis list
- discovered chassis count
- resource target summary

Illustrative shape:

```yaml
discovered_chassis:
  - serial: FOX...
    moid: ...
    model: UCSX-9508
    management_mode: Intersight
    oper_state: Operable
    connection_status: Connected
resource_targets:
  chassis:
    count: 1
    serials:
      - FOX...
```

## Realization Output Shape

The first implementation slice may export:

- selected bundle id
- shared chassis policy names
- shared chassis template identity
- target chassis serials
- realization mode
- planned or realized template-derived profile attachments

Illustrative shape:

```yaml
chassis_resource_state:
  profile_id: recommended
  realization_mode: shared_chassis_profile_template_bundle
  policies:
    chassis_power_policy:
      name: vf1-Chassis-Power
    chassis_thermal_policy:
      name: vf1-Chassis-Thermal
  profile_template:
    name: vf1-Chassis-Template
  target_chassis_serials:
    - FOX...
  attachment_strategy:
    target_scope: all_discovered_chassis
    per_chassis_overrides_supported: false
    derive_from_template: true
```

## Final Output Contract

Top-level outputs should remain simple and stable:

- `phase_ready`
- `phase_status`
- `phase_readiness_json`
- `infrastructure_resource_model_json`
- `infrastructure_resource_live_state_json`
- `chassis_resource_state_json`
- `validation_summary_json`
- `tac_handoff_json`
