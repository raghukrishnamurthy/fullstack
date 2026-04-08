# Domain Baseline Schema Draft

## Purpose

Define the schema layer that should feed `infrastructure-network-provisioning`
for shared FI and fabric/network foundation.

This draft treats the existing repos as references, not implementation truth.
It keeps the current Jarvis broad input model and adds a new catalog/defaults
layer for shared FI domain provisioning.

## Recommendation

Use the existing Jarvis baseline model as the outer orchestration contract, but
rewrite the FI/domain baseline content into a cleaner structure.

Recommended split:

- keep existing broad launch inputs:
  - `deployment_yaml`
  - `platform_yaml`
  - `placement_yaml`
  - `inventory_yaml`
  - `solution_yaml`
  - `site_yaml`
  - `baseline_input_source`
  - `baseline_directory`
  - `overrides_yaml`
- add new shared-fabric schema content under:
  - `defaults/fi_models/`
  - `catalog/port_mapping_profiles/`
  - `catalog/domain_profile_profiles/`
  - `catalog/domain_profile_policies/`
  - `catalog/chassis_profile_profiles/`
  - `catalog/chassis_profile_policies/`
  - `catalog/supported_policies.yaml`

## Why Rewrite Instead Of Reuse As-Is

### What already fits well

- Jarvis already has the right baseline precedence model:
  1. built-in baseline
  2. customer baseline
  3. overrides
- Jarvis already has the right wrapped input model.
- The reference `domain_profile` repo already demonstrates:
  - FI-model defaults
  - port-profile catalogs
  - policy catalogs
  - domain-profile-oriented naming

### What should change

- The current Jarvis built-in baseline is solution-oriented, not FI-domain
  oriented.
- The reference repo mixes a few implementation-era assumptions into the
  defaults and catalog files.
- We need an explicit separation between:
  - hardware capability defaults
  - port mapping profile selection
  - supported policy inventory
  - policy bundle/profile selection

## Proposed Data Model

### Layer 1: FI Model Defaults

Path:

- `defaults/fi_models/<model>.yaml`

Purpose:

- define hardware capabilities and guardrails by discovered FI model
- no customer naming or deployment-specific data here

Required sections:

- `model`
- `transport_modes`
- `unified_ports`
- `breakout`
- `port_ranges`
- `recommended_layout_defaults`
- `constraints`

Example responsibilities:

- which ports are unified
- which ports are breakout-capable
- which transport modes are allowed
- recommended uplink ranges
- recommended server-port ranges
- whether FC breakout is supported

### Layer 2: Port Mapping Profiles

Path:

- `catalog/port_mapping_profiles/<profile>.yaml`

Purpose:

- define reusable physical layout intent independent of deployment naming

Examples:

- `ethernet`
- `ethernet_fc`
- `ethernet_breakout`
- `ethernet_fc_breakout`

Required sections:

- `profile_id`
- `transport_mode`
- `breakout_strategy`
- `uplink_strategy`
- `server_port_strategy`
- `optional_features`

This layer answers:

- are we Ethernet-only or combined Ethernet+FC
- do we require breakout
- do we use one uplink port-channel by default
- is disjoint available or explicitly deferred

### Layer 3: Supported Policies Catalog

Path:

- `catalog/supported_policies.yaml`

Purpose:

- define which policy/resource types this automation platform owns

This file should be explicit and stable.

It should describe:

- policy/resource id
- scope
- required vs optional
- managed by which phase
- primary Intersight resource type

It should also preserve expansion candidates discovered from tested reference
flows, even when they are not part of the current v1 required set. Current
examples include:

- `ldap_policy`
- `certificate_policy`
- `snmp_policy`
- runtime deployment inventory such as pin-group information

### Layer 4: Domain Profile Policies

Path:

- `catalog/domain_profile_profiles/<profile>.yaml`
- `catalog/domain_profile_policies/<profile>/<policy>.yaml`
- `catalog/domain_profile_policies/supported.yaml`

Purpose:

- define reusable shared-fabric policy bundles and per-policy values using the
  same variant-per-policy model used by chassis profiles

Examples:

- `default`
- `recommended`

Required sections:

- `profile_id`
- `included_policies`
- `policy_defaults`
- `naming`

This layer answers:

- which shared policies should exist
- what their recommended values are
- how names should be formed

Initial v1 policy set:

- `port_policy`
- `switch_control_policy`
- `system_qos_policy`
- `ntp_policy`
- `network_connectivity_policy`

### Layer 5: Chassis Profile Policies

Path:

- `catalog/chassis_profile_profiles/<profile>.yaml`
- `catalog/chassis_profile_policies/<profile>/<policy>.yaml`
- `catalog/chassis_profile_policies/supported.yaml`

Purpose:

- define shared chassis-profile bundles and their policy values using the same
  variant-per-policy model used by the newer domain policy catalog

Initial examples:

- `chassis_profile_profiles/default.yaml`
- `chassis_profile_profiles/recommended.yaml`
- `default/power_policy.yaml`
- `default/thermal_policy.yaml`
- `recommended/power_policy.yaml`
- `recommended/thermal_policy.yaml`

Bundle behavior:

- keep chassis policy values shared by default
- create one shared Power policy and one shared Thermal policy per selected
  variant
- attach those shared policies to all discovered chassis in the infrastructure
  scope
- only add per-chassis variance later if a real requirement appears

Initial v1 policy set:

- `chassis_power_policy`
- `chassis_thermal_policy`

Later candidates:

- `chassis_imc_access_policy`
- `chassis_snmp_policy`

For readability, keep a local support list in:

- `catalog/domain_profile_policies/supported.yaml`
- `catalog/chassis_profile_policies/supported.yaml`

while preserving `catalog/supported_policies.yaml` as the master cross-phase
inventory.

## Merge Order

For `infrastructure-network-provisioning`, the effective shared-fabric model
should be resolved in this order:

1. built-in solution baseline from Jarvis
2. built-in FI model defaults
3. built-in port mapping profile
4. built-in domain policy profile
5. customer baseline override source
6. launch-time overrides

The important rule is:

- FI model capability constraints cannot be overridden into invalid states

## Relationship To Existing Jarvis Baseline

Current Jarvis built-in baseline:

- `/Users/rkrishn2/Documents/Jarvis_IAC/baselines/solution_profiles/ai_pod/baseline.yaml`

This still makes sense as a solution-level baseline, but it is not enough for
shared FI fabric provisioning because it currently focuses on:

- onboarding validation rules
- placement defaults
- generic naming
- solution expectations

Recommendation:

- keep `solution_profiles/*/baseline.yaml` for orchestration-wide expectations
- add shared-fabric catalogs/defaults beside it rather than forcing everything
  into the same file

## Relationship To Reference Repo

Useful references from `/Users/rkrishn2/Documents/domain_profile`:

- `defaults/fi_models/`
- `catalog/domain_profile_ports/`
- `catalog/domain_profile_policies/default.yaml`

Recommendation:

- reuse them as concept references
- do not copy them over unchanged
- rewrite them into the new Jarvis schema with clearer separation of concerns

## Suggested New Tree

```text
baselines/
  solution_profiles/
    ai_pod/
      baseline.yaml
catalog/
  supported_policies.yaml
  port_mapping_profiles/
    ethernet.yaml
    ethernet_fc.yaml
    ethernet_breakout.yaml
    ethernet_fc_breakout.yaml
  domain_profile_profiles/
    default.yaml
    recommended.yaml
  domain_profile_policies/
    supported.yaml
    default/
      port_policy.yaml
      switch_control_policy.yaml
      system_qos_policy.yaml
      ntp_policy.yaml
      network_connectivity_policy.yaml
    recommended/
      port_policy.yaml
      switch_control_policy.yaml
      system_qos_policy.yaml
      ntp_policy.yaml
      network_connectivity_policy.yaml
  chassis_profile_profiles/
    default.yaml
    recommended.yaml
  chassis_profile_policies/
    supported.yaml
    default/
      power_policy.yaml
      thermal_policy.yaml
    recommended/
      power_policy.yaml
      thermal_policy.yaml
defaults/
  fi_models/
    ucs_fi_6454.yaml
    ucs_fi_6536.yaml
    ucs_fi_6652.yaml
    ucs_fi_6664.yaml
```

## Initial Assessment

### Keep

- Jarvis broad wrapped input contract
- Jarvis baseline precedence model
- reference-repo idea of per-model defaults
- reference-repo idea of policy and port catalogs

### Rewrite

- current reference `domain_profile_ports` shape into clearer
  `port_mapping_profiles`
- current single `default.yaml` policy catalog into named
  `domain_profile_profiles` plus `domain_profile_policies`
- current model defaults so they carry capabilities and constraints first,
  not just port suggestions

### Defer

- child-target discovery schema
- solution/application logical network schema
- VLAN and VSAN intent schema

## Next Step

After this schema is accepted, the next design pass should define:

1. exact fields for each catalog file
2. the resolved `shared_fabric_model` output contract
3. which grain resolves schema inputs into the effective model
