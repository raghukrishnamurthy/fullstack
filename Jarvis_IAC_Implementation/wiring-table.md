# Wiring Table

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `deployment_yaml` | `resolve_intersight_deployment_model` | `deployment_yaml` | `deployment_yaml` |
| `platform_yaml` | `resolve_intersight_deployment_model` | `platform_yaml` | `platform_yaml` |
| `placement_yaml` | `resolve_intersight_deployment_model` | `placement_yaml` | `placement_yaml` |
| `site_yaml` | `resolve_intersight_deployment_model` | `site_yaml` | `site_yaml` |
| `baseline_input_source` | `resolve_intersight_deployment_model` | `baseline_input_source` | `baseline_input_source` |
| `baseline_directory` | `resolve_intersight_deployment_model` | `baseline_directory` | `baseline_directory` |
| `overrides_yaml` | `resolve_intersight_deployment_model` | `overrides_yaml` | `overrides_yaml` |
| `inventory_yaml` | `resolve_intersight_deployment_model` | `inventory_yaml` | `inventory_yaml` |
| `solution_yaml` | `resolve_intersight_deployment_model` | `solution_yaml` | `solution_yaml` |
| `validation_mode` | `resolve_intersight_deployment_model` | `validation_mode` | `validation_mode` |
| `discovery_model_json` | `render_intersight_deployment_summary` | `discovery_model_json` | `discovery_model_json` |
| `discovery_summary_json` | `render_intersight_deployment_summary` | `discovery_summary_json` | `discovery_summary_json` |

Exported outputs:

| Grain | Output |
| --- | --- |
| `resolve_intersight_deployment_model` | `discovery_model_json` |
| `resolve_intersight_deployment_model` | `discovery_summary_json` |
| `render_intersight_deployment_summary` | `discovery_report_json` |
| `render_intersight_deployment_summary` | `discovery_summary_markdown` |
| `resolve_intersight_deployment_model` | `destroy_status` |
| `resolve_intersight_deployment_model` | `destroy_results_json` |
| `render_intersight_deployment_summary` | `destroy_status` |
| `render_intersight_deployment_summary` | `destroy_results_json` |
