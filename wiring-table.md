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
| `blueprints/infrastructure-onboard-devices.yaml` | `intersight-fullstack-repo` | Phase blueprint | First working all-YAML onboarding phase |
| `blueprints/infrastructure-network-provisioning.yaml` | `intersight-fullstack-repo` | Phase blueprint | First working all-YAML network phase |
| `ansible/infrastructure-network-provisioning/playbook.yaml` | `intersight-fullstack-repo` | Grain source | Shared FI and fabric/network foundation planning |
| `ansible/infrastructure-network-provisioning/teardown.yaml` | `intersight-fullstack-repo` | Grain source | Explicit no-op destroy |
| `ansible/validate-infrastructure-onboarding-completion/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Final onboarding completion validation |
| `ansible/validate-infrastructure-onboarding-completion/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |


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


## Infrastructure Onboard Devices Launch Inputs

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
| `execution_intent` | `build_infrastructure_domain_model` | `execution_intent` | `execution_intent` |

## Infrastructure Onboard Devices Grain-to-Grain Wiring

| Upstream Output | Downstream Grain | Torque Grain Input |
| --- | --- | --- |
| `discovery_model_json` | `validate_infrastructure_onboarding_completion` | `discovery_model_json` |
| `discovery_model_json` | `render_infrastructure_onboarding_summary` | `discovery_model_json` |
| `discovery_summary_json` | `render_infrastructure_onboarding_summary` | `discovery_summary_json` |

## Infrastructure Onboard Devices Exported Outputs

| Grain | Output |
| --- | --- |
| `build_infrastructure_domain_model` | `discovery_model_json` |
| `build_infrastructure_domain_model` | `discovery_summary_json` |
| `validate_infrastructure_onboarding_completion` | `phase_ready` |
| `validate_infrastructure_onboarding_completion` | `phase_status` |
| `validate_infrastructure_onboarding_completion` | `phase_readiness_json` |
| `build_infrastructure_domain_model` | `claim_candidate_targets_json` |
| `build_infrastructure_domain_model` | `reachability_only_targets_json` |
| `build_infrastructure_domain_model` | `onboarding_action_execution_json` |
| `build_infrastructure_domain_model` | `claim_execution_results_json` |
| `render_infrastructure_onboarding_summary` | `discovery_report_json` |
| `render_infrastructure_onboarding_summary` | `discovery_summary_markdown` |



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
