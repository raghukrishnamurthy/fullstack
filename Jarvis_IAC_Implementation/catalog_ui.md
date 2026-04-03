# Catalog UI Definition

Offering type: `Custom`

End-user workflow steps:

1. Deployment Context
2. Platform Context
3. Placement Context
4. Site Settings
5. Baseline Resolution
6. Device Inventory
7. Review and Classify

Stable form keys:

| Step | Label | Type | Required | Key |
| --- | --- | --- | --- | --- |
| Deployment Context | Torque Agent | agent | yes | `agent` |
| Deployment Context | Deployment YAML | textarea | yes | `deployment_yaml` |
| Platform Context | Platform YAML | textarea | yes | `platform_yaml` |
| Placement Context | Placement YAML | textarea | yes | `placement_yaml` |
| Site Settings | Site YAML | textarea | no | `site_yaml` |
| Site Settings | Credential Candidates YAML | textarea | no | `credential_candidates_yaml` |
| Baseline Resolution | Baseline Input Source | text | no | `baseline_input_source` |
| Baseline Resolution | Baseline Directory | text | no | `baseline_directory` |
| Baseline Resolution | Overrides YAML | textarea | no | `overrides_yaml` |
| Device Inventory | Inventory YAML | textarea | yes | `inventory_yaml` |
| Device Inventory | Solution YAML | textarea | yes | `solution_yaml` |
| Device Inventory | Validation Mode | text | no | `validation_mode` |
| Review and Classify | Execution Intent | text | no | `execution_intent` |

Notes:

- YAML textareas are the preferred contract for nested input data in Torque.
- The keys above should remain stable across the launch form, blueprint inputs, and Ansible extra-vars.
- `site_yaml` is optional and is the preferred place for site-scoped settings such as location, DNS, NTP, and proxy defaults.
- `credential_candidates_yaml` is optional and is the current direct-input path for credential rotation candidates used by claim preparation.
- support typed candidates such as `credential_role: manufacturing` and `credential_role: target` for rack-server flows.
- `baseline_input_source` is the higher-orchestration baseline hook and may be hidden in Quali/Torque or Cisco Zero Touch offerings.
- `baseline_directory` is primarily for direct Ansible-style execution and should contain `baseline.yaml`.
- provide only one customer baseline source at a time.
- `baseline_input_source` must be an HTTP(S) URL.
- `overrides_yaml` is the narrow deployment-specific delta layer and is merged recursively on top of the loaded customer baseline payload.
- `validation_mode` should typically be `strict`; use `live` only when the referenced Intersight credentials are available to the grain runtime.
- `execution_intent` should remain `validate_only` until real claim/onboarding actions are implemented.
