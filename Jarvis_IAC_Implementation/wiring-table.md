# Wiring Table

Blueprint file:

- [claim-devices-to-intersight.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/blueprints/claim-devices-to-intersight.yaml)
- [cisco-standalone-rack-reset-password.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/blueprints/cisco-standalone-rack-reset-password.yaml)

## Launch Inputs

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `api_uri` | `prepare_intersight_context` | `platform_yaml` | `platform_yaml` |
| `intersight_api_key_id` | `prepare_intersight_context` | `platform_yaml` | `platform_yaml` |
| `intersight_api_private_key` | `prepare_intersight_context` | `platform_yaml` | `platform_yaml` |
| `organization` | `prepare_intersight_context` | `placement_yaml` | `placement_yaml` |
| `api_uri` | `claim_devices_to_intersight` | `platform_yaml` | `platform_yaml` |
| `intersight_api_key_id` | `claim_devices_to_intersight` | `platform_yaml` | `platform_yaml` |
| `intersight_api_private_key` | `claim_devices_to_intersight` | `platform_yaml` | `platform_yaml` |
| `organization` | `prepare_intersight_context` | `organization` | `organization` |
| `claim_targets_json` | `resolve_claim_target_credentials` | `claim_targets_json` | `claim_targets_json` |
| `fi_target_username` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `fi_target_password` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_username` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_password` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |

## Grain-to-Grain Wiring

| Upstream Output | Downstream Grain | Torque Grain Input |
| --- | --- | --- |
| `org_name` | `claim_devices_to_intersight` | `organization` |
| `resolved_claim_targets_json` | `claim_devices_to_intersight` | `claim_targets_json` |

## Exported Outputs

| Grain | Output |
| --- | --- |
| `prepare_intersight_context` | `context_status` |
| `prepare_intersight_context` | `org_status` |
| `prepare_intersight_context` | `org_name` |
| `prepare_intersight_context` | `org_action` |
| `prepare_intersight_context` | `org_result_json` |
| `prepare_intersight_context` | `context_result_json` |
| `resolve_claim_target_credentials` | `resolved_claim_targets_json` |
| `claim_devices_to_intersight` | `batch_status` |
| `claim_devices_to_intersight` | `successful_targets` |
| `claim_devices_to_intersight` | `failed_targets` |
| `claim_devices_to_intersight` | `conflict_targets` |
| `claim_devices_to_intersight` | `skipped_targets` |
| `claim_devices_to_intersight` | `changed_targets` |
| `claim_devices_to_intersight` | `results_json` |
| `claim_devices_to_intersight` | `normalized_claim_results_json` |
| `claim_devices_to_intersight` | `normalized_claim_batch_status` |
| `claim_devices_to_intersight` | `normalized_claim_successful_count` |
| `claim_devices_to_intersight` | `normalized_claim_failed_count` |
| `claim_devices_to_intersight` | `normalized_claim_conflict_count` |
| `claim_devices_to_intersight` | `normalized_claim_skipped_count` |
| `claim_devices_to_intersight` | `normalized_claim_changed_count` |

## Reset Blueprint Launch Inputs

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `targets_json` | `cisco_standalone_rack_reset_password` | `targets_json` | `targets_json` |
| `manufacturing_username` | `cisco_standalone_rack_reset_password` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `manufacturing_password` | `cisco_standalone_rack_reset_password` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `target_username` | `cisco_standalone_rack_reset_password` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `target_password` | `cisco_standalone_rack_reset_password` | `credential_candidates_yaml` | `credential_candidates_yaml` |

## Reset Blueprint Exported Outputs

| Grain | Output |
| --- | --- |
| `cisco_standalone_rack_reset_password` | `rack_password_reset_results_json` |
| `cisco_standalone_rack_reset_password` | `password_reset_ready_targets_json` |
| `cisco_standalone_rack_reset_password` | `password_reset_pending_targets_json` |
