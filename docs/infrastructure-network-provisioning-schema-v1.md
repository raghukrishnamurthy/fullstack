# Infrastructure Network Provisioning Schema v1

## Purpose

Define the v1 schema contract for `infrastructure-network-provisioning`.

This document focuses on:

- top-level launch/input shape
- per-domain selection shape
- resolved model output shape

The goal is to make the first implementation concrete while keeping the design
clean enough for later expansion.

## Design Principles

- keep the customer-facing surface small
- use onboarding/discovery context instead of re-asking for raw infrastructure
  facts
- support global defaults with per-domain refinement
- keep the resolved model separate from the input model
- keep v1 built-in only, but shape the resolver so future customer baseline and
  override support can be added later

## Top-Level v1 Input Contract

The phase should continue to accept the broad wrapped Jarvis context:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`
- `solution_yaml`
- `site_yaml`
- `baseline_input_source`
- `baseline_directory`
- `overrides_yaml`
- `validation_mode`
- `execution_intent`

On top of that broad context, v1 adds the specific phase selections below.

## Phase-Specific v1 Inputs

### Required

- `name_prefix`
- `policy_profile`
- `port_mapping_profile`

### Optional

- `domain_profile_selections_json`

This should be a JSON string for Torque safety.

The global values act as defaults.

Per-domain values refine or override those defaults.

## Built-In v1 Allowed Values

### `policy_profile`

Allowed values:

- `default`
- `recommended`

### `port_mapping_profile`

Allowed values:

- `ethernet`
- `ethernet_fc`

## Per-Domain Selection Contract

`domain_profile_selections_json` should normalize into a structure like this:

```yaml
domains:
  domain-01:
    policy_profile: recommended
    port_mapping_profile: ethernet
    uplink_port_channel_id: 100
  domain-02:
    policy_profile: default
    port_mapping_profile: ethernet_fc
    uplink_port_channel_id: 110
```

### Per-Domain Fields

Required for each selected domain in v1:

- `policy_profile`
- `port_mapping_profile`

Optional in v1:

- `uplink_port_channel_id`

If a per-domain field is not given, the global top-level value is used.

## Domain Identity Source

The resolver should not invent domains.

The list of target domains should come from onboarding/discovery context,
especially:

- `inventory.domains`
- resolved FI-pair domain information from the upstream model

`domain_profile_selections_json` should only refine known domains.

If a domain selection references an unknown domain, validation should fail.

## Input Precedence

For v1, precedence should be:

1. built-in system defaults
2. global phase-specific input values
3. per-domain input values

Notes:

- customer baseline and customer policy override sources are intentionally not
  implemented in v1
- the resolver should still be written cleanly enough that those layers can be
  added later

## Top-Level Input Example

```yaml
name_prefix: vf1
policy_profile: recommended
port_mapping_profile: ethernet
domain_profile_selections_json: |
  {
    "domains": {
      "domain-01": {
        "policy_profile": "recommended",
        "port_mapping_profile": "ethernet",
        "uplink_port_channel_id": 100
      },
      "domain-02": {
        "policy_profile": "default",
        "port_mapping_profile": "ethernet_fc",
        "uplink_port_channel_id": 110
      }
    }
  }
```

## Resolved Model Output Contract

The resolver should emit one effective model for provisioning consumption.

Suggested output name:

- `infrastructure_network_model_json`

Supporting output:

- `infrastructure_network_summary_json`

## Resolved Model Shape

Suggested structure:

```yaml
provider:
  family: intersight_imm_domain

deployment:
  id: vf1
  name_prefix: vf1

placement:
  organization: ai-prod

domains:
  - domain_id: domain-01
    fi_model: UCS-FI-6454
    policy_profile: recommended
    port_mapping_profile: ethernet
    uplink_port_channel_id: 100
    selected_policies:
      - port_policy
      - switch_control_policy
      - system_qos_policy
      - ntp_policy
      - network_connectivity_policy
    recommended_port_mapping:
      transport_mode: ethernet
      server_ports: []
      uplink_ports: []
      uplink_port_channels: []
    managed_object_names:
      port_policy: vf1-Port-Policy
      switch_control_policy: vf1-Switch-Control
      system_qos_policy: vf1-System-QoS
      ntp_policy: vf1-NTP
      network_connectivity_policy: vf1-Network-Connectivity
      domain_profile: vf1-Domain-Profile
      switch_profile_a: vf1-A
      switch_profile_b: vf1-B
```

## Resolved Model Required Fields

At minimum, each resolved domain entry should include:

- `domain_id`
- `fi_model`
- `policy_profile`
- `port_mapping_profile`
- `selected_policies`
- `recommended_port_mapping`
- `managed_object_names`

## Why Separate Resolved Model From Input Model

The input model is intentionally small and customer-facing.

The resolved model is richer and machine-facing.

This separation makes it easier to:

- keep the blueprint simple
- centralize validation and resolution logic
- later add customer baseline and override layers
- feed downstream grains with a stable provisioning contract

## Validation Rules For v1 Schema

The resolver should validate:

- `name_prefix` is present
- global `policy_profile` is allowed
- global `port_mapping_profile` is allowed
- every selected domain exists in discovery context
- every per-domain `policy_profile` is allowed
- every per-domain `port_mapping_profile` is allowed
- selected profile is compatible with discovered FI model
- required per-domain fields are present after global-default resolution

## Future Expansion Hooks

The v1 schema should be implemented cleanly enough to allow later additions:

- customer baseline model source
- customer policy override YAML/JSON
- additional port-mapping profiles such as breakout variants
- additional policy profiles
- more provider families

These should be added by extending the resolver, not by breaking the v1
contract.
