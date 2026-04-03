# Catalog UI Definition

Offering type: `Custom`

End-user workflow steps:

1. Deployment Context
2. Platform Context
3. Placement Context
4. Site Settings
5. Device Inventory
6. Review and Classify

Stable form keys:

| Step | Label | Type | Required | Key |
| --- | --- | --- | --- | --- |
| Deployment Context | Torque Agent | agent | yes | `agent` |
| Deployment Context | Deployment YAML | textarea | yes | `deployment_yaml` |
| Platform Context | Platform YAML | textarea | yes | `platform_yaml` |
| Placement Context | Placement YAML | textarea | yes | `placement_yaml` |
| Site Settings | Site YAML | textarea | no | `site_yaml` |
| Device Inventory | Inventory YAML | textarea | yes | `inventory_yaml` |
| Device Inventory | Solution YAML | textarea | yes | `solution_yaml` |
| Device Inventory | Validation Mode | text | no | `validation_mode` |

Notes:

- YAML textareas are the preferred contract for nested input data in Torque.
- The keys above should remain stable across the launch form, blueprint inputs, and Ansible extra-vars.
- `site_yaml` is optional and is the preferred place for site-scoped settings such as location, DNS, NTP, and proxy defaults.
- `validation_mode` should typically be `strict`; use `live` only when the referenced Intersight credentials are available to the grain runtime.
