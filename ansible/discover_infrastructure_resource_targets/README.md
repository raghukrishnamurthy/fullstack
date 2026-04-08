# discover_infrastructure_resource_targets

Discovery grain for `infrastructure-resource-provisioning`.

This first slice discovers chassis targets from live Intersight state using:

- wrapped platform credentials
- placement organization
- the resolved resource model

The current implementation is intentionally chassis-focused.

Current endpoint strategy:

- query `equipment.Chasses`
- query `equipment.ChassisIdentities`
- query `compute.Blades` for supporting diagnostics

If direct chassis objects are absent, the grain now reports that as a live
readiness gap instead of silently pretending chassis targets exist.
