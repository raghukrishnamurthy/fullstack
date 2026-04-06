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
| Deployment Context | Deployment JSON | textarea | yes | `deployment_json` |
| Platform Context | API URI | text | yes | `api_uri` |
| Platform Context | Intersight API Key ID | text | yes | `intersight_api_key_id` |
| Platform Context | Intersight API Private Key | textarea | yes | `intersight_api_private_key` |
| Placement Context | Platform JSON | textarea | yes | `platform_json` |
| Placement Context | Placement JSON | textarea | yes | `placement_json` |
| Site Settings | Site JSON | textarea | no | `site_json` |
| Site Settings | Credential Candidates JSON | textarea | no | `credential_candidates_json` |
| Site Settings | Encrypted Device Secret Bundle Path | text | yes | `encrypted_device_secret_bundle_path` |
| Site Settings | Device Secret Bundle Key | text | no | `device_secret_bundle_key` |
| Baseline Resolution | Baseline Input Source | text | no | `baseline_input_source` |
| Baseline Resolution | Baseline Directory | text | no | `baseline_directory` |
| Baseline Resolution | Overrides JSON | textarea | no | `overrides_json` |
| Device Inventory | Inventory JSON | textarea | yes | `inventory_json` |
| Device Inventory | Solution JSON | textarea | yes | `solution_json` |
| Device Inventory | Validation Mode | text | no | `validation_mode` |
| Review and Classify | Execution Intent | text | no | `execution_intent` |
| Review and Classify | Wait For Completion | text | no | `wait_for_completion` |
| Review and Classify | Validation Poll Interval | text | no | `validation_poll_interval` |
| Review and Classify | Validation Timeout Seconds | text | no | `validation_timeout_seconds` |

Notes:

- JSON-string textareas are the preferred contract for nested input data in Torque.
- The keys above should remain stable across the launch form, blueprint inputs, and Ansible extra-vars.
- `site_json` is optional and is the preferred place for site-scoped settings such as location, DNS, NTP, and proxy defaults.
- `credential_candidates_json` is optional and should usually be `{}` for the bundle-backed happy path.
- `encrypted_device_secret_bundle_path` and `device_secret_bundle_key` are the preferred user-facing contract for device-side secrets.
- control-plane credentials remain direct launch inputs and are mapped to env refs internally for the runtime grains.
- `baseline_input_source` is the higher-orchestration baseline hook and may be hidden in Quali/Torque or Cisco Zero Touch offerings.
- `baseline_directory` is primarily for direct Ansible-style execution and should contain `baseline.yaml`.
- provide only one customer baseline source at a time.
- `baseline_input_source` must be an HTTP(S) URL.
- `overrides_json` is the narrow deployment-specific delta layer and is merged recursively on top of the loaded customer baseline payload.
- `validation_mode` should typically be `strict`; use `live` only when the referenced Intersight credentials are available to the grain runtime.
- `execution_intent: apply` now supports the validated PVA path for one FI pair claim unit plus standalone rack claims.
