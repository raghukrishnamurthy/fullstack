# resolve_infrastructure_resource_model

Resolver grain for `infrastructure-resource-provisioning`.

This first slice consumes onboarding-style wrapped inputs plus the v1
phase-specific inputs:

- `name_prefix`
- `chassis_profile`
- `resource_profile_selections_json`

It resolves a deterministic machine-facing model for downstream chassis resource
grains.
