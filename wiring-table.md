# Wiring Table

Blueprint file:

- [claim-devices-to-intersight.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/claim-devices-to-intersight.yaml)
- [cisco-standalone-rack-reset-password.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/cisco-standalone-rack-reset-password.yaml)

## Published Automation Sources

| Repo Path | Torque Store | Blueprint Use | Notes |
| --- | --- | --- | --- |
| `ansible/claim-devices-to-intersight/playbook.yaml` | `intersight-fullstack-repo` | Grain source | Unified claim execution |
| `ansible/claim-devices-to-intersight/teardown.yaml` | `intersight-fullstack-repo` | Grain source | Explicit no-op destroy |
| `ansible/cisco-standalone-rack-reset-password/playbook.yaml` | `intersight-fullstack-repo` | Grain source | Standalone rack password reset |
| `ansible/cisco-standalone-rack-reset-password/teardown.yaml` | `intersight-fullstack-repo` | Grain source | Explicit no-op destroy |
| `ansible/resolve-claim-target-credentials/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Claim credential resolution |
| `ansible/resolve-claim-target-credentials/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
| `ansible/prepare-intersight-context/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Higher-level org/context preparation |
| `ansible/prepare-intersight-context/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
| `ansible/resolve-intersight-deployment-model/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Stack discovery and derived model |
| `ansible/resolve-intersight-deployment-model/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
| `ansible/render-intersight-deployment-summary/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Discovery summary rendering |
| `ansible/render-intersight-deployment-summary/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
| `ansible/bootstrap_runtime/playbook.yaml` | `intersight-fullstack-repo` | Utility grain | Optional worker bootstrap |


## Launch Inputs

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `api_uri` | `claim_devices_to_intersight` | `platform_yaml` | `platform_yaml` |
| `intersight_api_key_id` | `claim_devices_to_intersight` | `platform_yaml` | `platform_yaml` |
| `intersight_api_private_key` | `claim_devices_to_intersight` | `platform_yaml` | `platform_yaml` |
| `organization` | `claim_devices_to_intersight` | `organization` | `organization` |
| `claim_targets_json` | `resolve_claim_target_credentials` | `claim_targets_json` | `claim_targets_json` |
| `fi_target_username` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `fi_target_password` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_username` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_password` | `resolve_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |

## Grain-to-Grain Wiring

| Upstream Output | Downstream Grain | Torque Grain Input |
| --- | --- | --- |
| `resolved_claim_targets_json` | `claim_devices_to_intersight` | `claim_targets_json` |

## Exported Outputs

| Grain | Output |
| --- | --- |
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
