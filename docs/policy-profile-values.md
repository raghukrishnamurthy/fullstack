# Policy Profile Values

## Purpose

Define the initial value differences between the built-in policy profiles:

- `default`
- `recommended`

These profiles apply to the current in-scope shared physical/domain policies:

- `port_policy`
- `switch_control_policy`
- `system_qos_policy`
- `ntp_policy`
- `network_connectivity_policy`

The two profiles should differ mainly by values, not by policy
membership.

## Shared Membership

Both `default` and `recommended` include:

- `port_policy`
- `switch_control_policy`
- `system_qos_policy`
- `ntp_policy`
- `network_connectivity_policy`

## Design Intent

### `default`

- minimal safe shared baseline
- least opinionated values
- suitable when the user wants a low-assumption shared infrastructure posture

### `recommended`

- preferred operational baseline
- still generic and shared, not solution-specific
- can use stronger recommended values derived from Cisco guidance, site
  defaults, and established platform conventions

## Policy Values

### `port_policy`

`default`:

- use model-derived recommended server/uplink ranges
- use one uplink port-channel by default
- use model-derived default uplink members
- use `Auto` speed where model defaults do not require stronger preference
- use `Auto` FEC unless model-specific guidance requires otherwise

`recommended`:

- same structural behavior as `default`
- use model-derived recommended server/uplink ranges
- use one uplink port-channel by default
- use model-derived default uplink members
- prefer recommended speed values per model where known
- prefer recommended FEC values per model where known

### `switch_control_policy`

`default`:

- `ethernet_switching_mode: end-host`
- `fc_switching_mode: end-host` when FC profile is used
- `mac_aging_option: default`
- `vlan_port_optimization_enabled: false`
- `message_interval: 15`
- reserved VLAN start id should use the platform default baseline value

`recommended`:

- `ethernet_switching_mode: end-host`
- `fc_switching_mode: end-host` when FC profile is used
- `mac_aging_option: default`
- `vlan_port_optimization_enabled: false`
- `message_interval: 15`
- reserved VLAN start id should use the recommended baseline value maintained by
  the built-in policy catalog

## `system_qos_policy`

`default`:

- use platform-safe default class weights
- keep the standard shared traffic classes enabled
- avoid solution-specific QoS shaping

`recommended`:

- use the preferred built-in shared class weights for the supported traffic
  classes
- keep the standard shared traffic classes enabled
- still avoid solution-specific QoS shaping

## `ntp_policy`

`default`:

- enable NTP
- prefer system or site global settings when available
- otherwise fall back to a minimal built-in default list

`recommended`:

- enable NTP
- prefer site global settings first
- if site values are missing, use the built-in recommended NTP server list

## `network_connectivity_policy`

`default`:

- prefer site global settings when available
- otherwise use the minimal built-in DNS posture
- no solution-specific connectivity assumptions

`recommended`:

- prefer site global settings first
- otherwise use the built-in recommended DNS posture
- no solution-specific connectivity assumptions

## Practical v1 Resolver Behavior

The resolver should treat these profile values as policy catalog selections,
then allow model-aware composition where required.

In other words:

- `port_policy` values are partly profile-driven and partly model-driven
- `ntp_policy` and `network_connectivity_policy` may prefer site values when
  present
- `default` versus `recommended` should resolve deterministically even when
  optional site inputs are absent

## Suggested Built-In Catalog Structure

For the first implementation, the built-in catalog can be represented as:

```text
catalog/
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
  domain_profile_profiles/
    default.yaml
    recommended.yaml
```

## v1 Implementation Note

This document intentionally defines behavior at the policy-profile level, not
every field in final API payload form.

The actual policy catalog files should make those values concrete using the same
profile names:

- `default`
- `recommended`

while still allowing model-aware port-policy composition in the resolver.
