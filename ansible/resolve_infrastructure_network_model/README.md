# resolve_infrastructure_network_model

Resolver grain for `infrastructure-network-provisioning`.

This grain consumes onboarding-style wrapped inputs plus the v1 phase-specific
inputs:

- `name_prefix`
- `policy_profile`
- `port_mapping_profile`
- `domain_profile_selections_json`

It resolves a deterministic machine-facing model for downstream grains.

The current implementation is a scaffold that validates the contract and exports
stable JSON outputs.
