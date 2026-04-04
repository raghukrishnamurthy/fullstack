# Wiring Table

Blueprint file:

- [claim-intersight-devices.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/blueprints/claim-intersight-devices.yaml)

## Launch Inputs

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `deployment_yaml` | `claim_to_saas` | `deployment_yaml` | `deployment_yaml` |
| `deployment_yaml` | `claim_to_appliance` | `deployment_yaml` | `deployment_yaml` |
| `intersight_endpoint` | `ensure_intersight_context` | `platform_yaml` | `platform_yaml` |
| `intersight_api_key_id` | `ensure_intersight_context` | `platform_yaml` | `platform_yaml` |
| `intersight_api_private_key` | `ensure_intersight_context` | `platform_yaml` | `platform_yaml` |
| `organization` | `ensure_intersight_context` | `placement_yaml` | `placement_yaml` |
| `intersight_endpoint` | `claim_to_saas` | `platform_yaml` | `platform_yaml` |
| `intersight_api_key_id` | `claim_to_saas` | `platform_yaml` | `platform_yaml` |
| `intersight_api_private_key` | `claim_to_saas` | `platform_yaml` | `platform_yaml` |
| `intersight_endpoint` | `claim_to_appliance` | `platform_yaml` | `platform_yaml` |
| `intersight_api_key_id` | `claim_to_appliance` | `platform_yaml` | `platform_yaml` |
| `intersight_api_private_key` | `claim_to_appliance` | `platform_yaml` | `platform_yaml` |
| `organization` | `ensure_intersight_context` | `organization` | `organization` |
| `claim_targets_json` | `resolve_claim_target_credentials` | `claim_targets_json` | `claim_targets_json` |
| `fi_target_username` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `fi_target_password` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_username` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_password` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |

## Grain-to-Grain Wiring

| Upstream Output | Downstream Grain | Torque Grain Input |
| --- | --- | --- |
| `org_name` | `claim_to_saas` | `organization` |
| `org_name` | `claim_to_appliance` | `organization` |
| `resolved_claim_targets_json` | `claim_to_saas` | `claim_targets_json` |
| `resolved_claim_targets_json` | `claim_to_appliance` | `claim_targets_json` |
| `results_json` from `claim_to_saas` | `normalize_claim_results` | `saas_claim_results_json` |
| `results_json` from `claim_to_appliance` | `normalize_claim_results` | `appliance_claim_results_json` |

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
| `claim_to_saas` | `batch_status` |
| `claim_to_saas` | `successful_targets` |
| `claim_to_saas` | `failed_targets` |
| `claim_to_saas` | `conflict_targets` |
| `claim_to_saas` | `skipped_targets` |
| `claim_to_saas` | `changed_targets` |
| `claim_to_saas` | `results_json` |
| `claim_to_appliance` | `batch_status` |
| `claim_to_appliance` | `successful_targets` |
| `claim_to_appliance` | `failed_targets` |
| `claim_to_appliance` | `conflict_targets` |
| `claim_to_appliance` | `skipped_targets` |
| `claim_to_appliance` | `changed_targets` |
| `claim_to_appliance` | `results_json` |
| `normalize_claim_results` | `normalized_claim_results_json` |
| `normalize_claim_results` | `normalized_claim_batch_status` |
| `normalize_claim_results` | `normalized_claim_successful_count` |
| `normalize_claim_results` | `normalized_claim_failed_count` |
| `normalize_claim_results` | `normalized_claim_conflict_count` |
| `normalize_claim_results` | `normalized_claim_skipped_count` |
| `normalize_claim_results` | `normalized_claim_changed_count` |
