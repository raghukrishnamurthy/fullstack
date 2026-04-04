# Wiring Table

Blueprint file:

- [claim-intersight-devices.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/blueprints/claim-intersight-devices.yaml)
- [cisco-standalone-rack-reset-password.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/blueprints/cisco-standalone-rack-reset-password.yaml)

## Launch Inputs

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `api_uri` | `ensure_intersight_context` | `platform_yaml` | `platform_yaml` |
| `intersight_api_key_id` | `ensure_intersight_context` | `platform_yaml` | `platform_yaml` |
| `intersight_api_private_key` | `ensure_intersight_context` | `platform_yaml` | `platform_yaml` |
| `organization` | `ensure_intersight_context` | `placement_yaml` | `placement_yaml` |
| `api_uri` | `claim_intersight_devices` | `platform_yaml` | `platform_yaml` |
| `intersight_api_key_id` | `claim_intersight_devices` | `platform_yaml` | `platform_yaml` |
| `intersight_api_private_key` | `claim_intersight_devices` | `platform_yaml` | `platform_yaml` |
| `organization` | `ensure_intersight_context` | `organization` | `organization` |
| `claim_targets_json` | `resolve_claim_target_credentials` | `claim_targets_json` | `claim_targets_json` |
| `fi_target_username` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `fi_target_password` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_username` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_password` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |

## Grain-to-Grain Wiring

| Upstream Output | Downstream Grain | Torque Grain Input |
| --- | --- | --- |
| `org_name` | `claim_intersight_devices` | `organization` |
| `resolved_claim_targets_json` | `claim_intersight_devices` | `claim_targets_json` |

## Exported Outputs

| Grain | Output |
| --- | --- |
| `ensure_intersight_context` | `context_status` |
| `ensure_intersight_context` | `org_status` |
| `ensure_intersight_context` | `org_name` |
| `ensure_intersight_context` | `org_action` |
| `ensure_intersight_context` | `org_result_json` |
| `ensure_intersight_context` | `context_result_json` |
| `resolve_claim_target_credentials` | `resolved_claim_targets_json` |
| `claim_intersight_devices` | `batch_status` |
| `claim_intersight_devices` | `successful_targets` |
| `claim_intersight_devices` | `failed_targets` |
| `claim_intersight_devices` | `conflict_targets` |
| `claim_intersight_devices` | `skipped_targets` |
| `claim_intersight_devices` | `changed_targets` |
| `claim_intersight_devices` | `results_json` |
| `claim_intersight_devices` | `normalized_claim_results_json` |
| `claim_intersight_devices` | `normalized_claim_batch_status` |
| `claim_intersight_devices` | `normalized_claim_successful_count` |
| `claim_intersight_devices` | `normalized_claim_failed_count` |
| `claim_intersight_devices` | `normalized_claim_conflict_count` |
| `claim_intersight_devices` | `normalized_claim_skipped_count` |
| `claim_intersight_devices` | `normalized_claim_changed_count` |

## Reset Blueprint Launch Inputs

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `targets_json` | `reset_rack_password` | `targets_json` | `targets_json` |
| `manufacturing_username` | `reset_rack_password` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `manufacturing_password` | `reset_rack_password` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `target_username` | `reset_rack_password` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `target_password` | `reset_rack_password` | `credential_candidates_yaml` | `credential_candidates_yaml` |

## Reset Blueprint Exported Outputs

| Grain | Output |
| --- | --- |
| `reset_rack_password` | `rack_password_reset_results_json` |
| `reset_rack_password` | `password_reset_ready_targets_json` |
| `reset_rack_password` | `password_reset_pending_targets_json` |
