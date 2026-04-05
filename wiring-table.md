# Wiring Table

Blueprint file:

- [claim-devices-to-intersight.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/claim-devices-to-intersight.yaml)
- [cisco-standalone-rack-reset-password.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/cisco-standalone-rack-reset-password.yaml)
- [infrastructure-onboard-devices.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/infrastructure-onboard-devices.yaml)
- [infrastructure-network-provisioning.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/infrastructure-network-provisioning.yaml)

## Published Automation Sources

| Repo Path | Torque Store | Blueprint Use | Notes |
| --- | --- | --- | --- |
| `ansible/claim-devices-to-intersight/playbook.yaml` | `intersight-fullstack-repo` | Grain source | Unified claim execution |
| `ansible/claim-devices-to-intersight/teardown.yaml` | `intersight-fullstack-repo` | Grain source | Explicit no-op destroy |
| `ansible/reset-standalone-rack-password/playbook.yaml` | `intersight-fullstack-repo` | Grain source | Standalone rack password reset |
| `ansible/reset-standalone-rack-password/teardown.yaml` | `intersight-fullstack-repo` | Grain source | Explicit no-op destroy |
| `ansible/prepare-claim-target-credentials/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Claim credential resolution |
| `ansible/prepare-claim-target-credentials/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
| `ansible/prepare-intersight-context/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Higher-level org/context preparation |
| `ansible/prepare-intersight-context/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
| `ansible/build-infrastructure-onboarding-targets/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Direct onboarding target construction from inventory |
| `ansible/build-infrastructure-onboarding-targets/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
| `ansible/prepare-device-connector/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Connector preparation step in the shared onboarding flow |
| `ansible/prepare-device-connector/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
| `ansible/bootstrap_runtime/playbook.yaml` | `intersight-fullstack-repo` | Utility grain | Optional worker bootstrap |
| `blueprints/infrastructure-onboard-devices.yaml` | `intersight-fullstack-repo` | Phase blueprint | First working all-YAML onboarding phase |
| `blueprints/infrastructure-network-provisioning.yaml` | `intersight-fullstack-repo` | Phase blueprint | First working all-YAML network phase |
| `ansible/infrastructure-network-provisioning/playbook.yaml` | `intersight-fullstack-repo` | Grain source | Shared FI and fabric/network foundation planning |
| `ansible/infrastructure-network-provisioning/teardown.yaml` | `intersight-fullstack-repo` | Grain source | Explicit no-op destroy |
| `ansible/validate-infrastructure-onboarding/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Final onboarding completion validation |
| `ansible/validate-infrastructure-onboarding/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |


## Launch Inputs

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `api_uri` | `claim_devices_to_intersight` | `platform_yaml` | `platform_yaml` |
| `intersight_api_key_id` | `claim_devices_to_intersight` | `platform_yaml` | `platform_yaml` |
| `intersight_api_private_key` | `claim_devices_to_intersight` | `platform_yaml` | `platform_yaml` |
| `organization` | `claim_devices_to_intersight` | `organization` | `organization` |
| `claim_targets_json` | `prepare_claim_target_credentials` | `claim_targets_json` | `claim_targets_json` |
| `fi_target_username` | `prepare_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `fi_target_password` | `prepare_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_username` | `prepare_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `rack_target_password` | `prepare_claim_target_credentials` | `credential_candidates_yaml` | `credential_candidates_yaml` |

## Grain-to-Grain Wiring

| Upstream Output | Downstream Grain | Torque Grain Input |
| --- | --- | --- |
| `resolved_claim_targets_json` | `claim_devices_to_intersight` | `claim_targets_json` |

## Exported Outputs

| Grain | Output |
| --- | --- |
| `prepare_claim_target_credentials` | `resolved_claim_targets_json` |
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
| `targets_json` | `reset_standalone_rack_passwords` | `targets_json` | `targets_json` |
| `manufacturing_username` | `reset_standalone_rack_passwords` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `manufacturing_password` | `reset_standalone_rack_passwords` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `target_username` | `reset_standalone_rack_passwords` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `target_password` | `reset_standalone_rack_passwords` | `credential_candidates_yaml` | `credential_candidates_yaml` |

## Reset Blueprint Exported Outputs

| Grain | Output |
| --- | --- |
| `reset_standalone_rack_passwords` | `rack_password_reset_results_json` |
| `reset_standalone_rack_passwords` | `password_reset_ready_targets_json` |
| `reset_standalone_rack_passwords` | `password_reset_pending_targets_json` |


## Infrastructure Onboard Devices Launch Inputs

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `deployment_json` | shared onboarding phase | `deployment_json` | phase inputs |
| `api_uri` | shared onboarding phase | `api_uri` | phase inputs |
| `platform_json` | shared onboarding phase | `platform_json` | phase inputs |
| `placement_json` | shared onboarding phase | `placement_json` | phase inputs |
| `inventory_json` | shared onboarding phase | `inventory_json` | phase inputs |
| `solution_json` | shared onboarding phase | `solution_json` | phase inputs |
| `credential_candidates_json` | shared onboarding phase | `credential_candidates_json` | phase inputs |
| `site_json` | shared onboarding phase | `site_json` | phase inputs |
| `baseline_input_source` | shared onboarding phase | `baseline_input_source` | phase inputs |
| `baseline_directory` | shared onboarding phase | `baseline_directory` | phase inputs |
| `overrides_json` | shared onboarding phase | `overrides_json` | phase inputs |
| `validation_mode` | shared onboarding phase | `validation_mode` | phase inputs |
| `execution_intent` | shared onboarding phase | `execution_intent` | phase inputs |
| `wait_for_completion` | `validate_infrastructure_onboarding` | `wait_for_completion` | `wait_for_completion` |
| `validation_poll_interval` | `validate_infrastructure_onboarding` | `validation_poll_interval` | `validation_poll_interval` |
| `validation_timeout_seconds` | `validate_infrastructure_onboarding` | `validation_timeout_seconds` | `validation_timeout_seconds` |

## Infrastructure Onboard Devices Grain-to-Grain Wiring

| Upstream Output | Downstream Grain | Torque Grain Input |
| --- | --- | --- |
| `reset_targets_json` | `reset_standalone_rack_passwords` | `targets_json` |
| `claim_targets_json` | `prepare_claim_target_credentials` | `claim_targets_json` |
| `resolved_claim_targets_json` | `prepare_device_connector` | `claim_targets_json` |
| `prepared_claim_targets_json` | `claim_devices_to_intersight` | `claim_targets_json` |
| `org_name` | `claim_devices_to_intersight` | `organization` |
| `results_json` | `validate_infrastructure_onboarding` | `claim_execution_results_json` |

## Infrastructure Onboard Devices Exported Outputs

| Grain | Output |
| --- | --- |
| `build_infrastructure_onboarding_targets` | `claim_targets_json` |
| `build_infrastructure_onboarding_targets` | `reset_targets_json` |
| `prepare_intersight_context` | `org_name` |
| `prepare_claim_target_credentials` | `resolved_claim_targets_json` |
| `prepare_device_connector` | `prepared_claim_targets_json` |
| `claim_devices_to_intersight` | `results_json` |
| `claim_devices_to_intersight` | `normalized_claim_results_json` |
| `validate_infrastructure_onboarding` | `phase_ready` |
| `validate_infrastructure_onboarding` | `phase_status` |
| `validate_infrastructure_onboarding` | `phase_readiness_json` |



## Infrastructure Network Provisioning Launch Inputs

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `deployment_yaml` | `build_infrastructure_domain_model` | `deployment_yaml` | `deployment_yaml` |
| `platform_yaml` | `build_infrastructure_domain_model` | `platform_yaml` | `platform_yaml` |
| `placement_yaml` | `build_infrastructure_domain_model` | `placement_yaml` | `placement_yaml` |
| `inventory_yaml` | `build_infrastructure_domain_model` | `inventory_yaml` | `inventory_yaml` |
| `solution_yaml` | `build_infrastructure_domain_model` | `solution_yaml` | `solution_yaml` |
| `credential_candidates_yaml` | `build_infrastructure_domain_model` | `credential_candidates_yaml` | `credential_candidates_yaml` |
| `site_yaml` | `build_infrastructure_domain_model` | `site_yaml` | `site_yaml` |
| `baseline_input_source` | `build_infrastructure_domain_model` | `baseline_input_source` | `baseline_input_source` |
| `baseline_directory` | `build_infrastructure_domain_model` | `baseline_directory` | `baseline_directory` |
| `overrides_yaml` | `build_infrastructure_domain_model` | `overrides_yaml` | `overrides_yaml` |
| `validation_mode` | `build_infrastructure_domain_model` | `validation_mode` | `validation_mode` |
| `execution_intent` | `infrastructure_network_provisioning` | `execution_intent` | `execution_intent` |

## Infrastructure Network Provisioning Grain-to-Grain Wiring

| Upstream Output | Downstream Grain | Torque Grain Input |
| --- | --- | --- |
| `discovery_model_json` | `infrastructure_network_provisioning` | `discovery_model_json` |
| `discovery_summary_json` | `infrastructure_network_provisioning` | `discovery_summary_json` |

## Infrastructure Network Provisioning Exported Outputs

| Grain | Output |
| --- | --- |
| `build_infrastructure_domain_model` | `discovery_model_json` |
| `build_infrastructure_domain_model` | `discovery_summary_json` |
| `infrastructure_network_provisioning` | `phase_ready` |
| `infrastructure_network_provisioning` | `phase_status` |
| `infrastructure_network_provisioning` | `phase_readiness_json` |
| `infrastructure_network_provisioning` | `network_foundation_plan_json` |
| `infrastructure_network_provisioning` | `network_foundation_summary_json` |
