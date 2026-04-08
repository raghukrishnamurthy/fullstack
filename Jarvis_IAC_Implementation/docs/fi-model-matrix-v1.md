# FI Model Matrix v1

## Purpose

Define the v1 FI model matrix used by the
`infrastructure-network-provisioning` resolver.

This matrix is the model-aware source used to derive:

- allowed transport modes
- unified-port behavior
- breakout capability
- recommended server-port ranges
- recommended uplink-port ranges
- default uplink port-channel members

## Supported Models

- `UCS-FI-6454`
- `UCS-FI-6536`
- `UCS-FI-6652`
- `UCS-FI-6664`

## Design Rule

Use recommended settings based on recommended port mappings for the discovered
model and selected `port_mapping_profile`.

In v1, the exposed port mapping profiles remain:

- `ethernet`
- `ethernet_fc`

## Matrix

### `UCS-FI-6454`

- supported transport modes:
  - `ethernet`
  - `ethernet_fc`
- unified ports:
  - `1-16`
- breakout support:
  - Ethernet breakout supported on `49-54`
  - FC breakout not planned in v1
- recommended server-port range:
  - `1-48`
- recommended uplink-port range:
  - `49-54`
- default uplink port-channel members:
  - `1/49`
  - `1/50`
  - `1/51`
  - `1/52`

### `UCS-FI-6536`

- supported transport modes:
  - `ethernet`
  - `ethernet_fc`
- unified ports:
  - `33-36`
- breakout support:
  - Ethernet breakout supported
  - FC breakout supported on unified ports
  - breakout-specific profiles are deferred from the exposed v1 input surface
- recommended server-port range:
  - `1-32`
- recommended uplink-port range:
  - `33-36`
- default uplink port-channel members:
  - `1/33`
  - `1/34`
  - `1/35`
  - `1/36`

### `UCS-FI-6652`

- supported transport modes:
  - `ethernet`
  - `ethernet_fc`
- unified ports:
  - `17-32`
- breakout support:
  - not exposed as part of v1 customer-facing profiles
  - keep implementation clean so this can be added later if validated
- recommended server-port range:
  - `1-48`
- recommended uplink-port range:
  - `49-52`
- default uplink port-channel members:
  - `1/49`
  - `1/50`
  - `1/51`
  - `1/52`

### `UCS-FI-6664`

- supported transport modes:
  - `ethernet`
  - `ethernet_fc`
- unified ports:
  - `25-40`
- breakout support:
  - not part of the v1 model
- recommended server-port range:
  - `1-24`
  - `41-64` should be treated as higher-speed uplink-capable range
- recommended uplink-port range:
  - `41-64`
- default uplink port-channel members:
  - `1/41`
  - `1/42`
  - `1/43`
  - `1/44`

## Resolver Rules

The resolver should:

- derive actual FI model from live Intersight state when available
- validate selected `port_mapping_profile` against model capabilities
- use model-specific recommended ranges as the starting point
- generate the recommended uplink port channel by default
- reject unsupported profile/model combinations

## v1 Simplification Rules

- support all four models in the resolver
- expose only `ethernet` and `ethernet_fc` in the first customer-facing slice
- do not expose breakout profiles in v1
- keep model data structured so breakout profiles can be added later without
  redesign

## Open Follow-Up

Before implementation is finalized, the exact 6652 and 6664 detailed rules
should receive one last Cisco/OpenAPI verification pass so the resolver data is
as accurate as possible.
