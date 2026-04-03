# Wiring Table

| Form Key | Grain | Automation Variable | Torque Grain Input |
| --- | --- | --- | --- |
| `agent` | blueprint runtime | `agent` | `agent` |
| `deployment_yaml` | `discover_infrastructure` | `deployment_yaml` | `deployment_yaml` |
| `platform_yaml` | `discover_infrastructure` | `platform_yaml` | `platform_yaml` |
| `placement_yaml` | `discover_infrastructure` | `placement_yaml` | `placement_yaml` |
| `site_yaml` | `discover_infrastructure` | `site_yaml` | `site_yaml` |
| `baseline_input_source` | `discover_infrastructure` | `baseline_input_source` | `baseline_input_source` |
| `baseline_directory` | `discover_infrastructure` | `baseline_directory` | `baseline_directory` |
| `overrides_yaml` | `discover_infrastructure` | `overrides_yaml` | `overrides_yaml` |
| `inventory_yaml` | `discover_infrastructure` | `inventory_yaml` | `inventory_yaml` |
| `solution_yaml` | `discover_infrastructure` | `solution_yaml` | `solution_yaml` |
| `validation_mode` | `discover_infrastructure` | `validation_mode` | `validation_mode` |
| `discovery_model_json` | `render_discovery_summary` | `discovery_model_json` | `discovery_model_json` |
| `discovery_summary_json` | `render_discovery_summary` | `discovery_summary_json` | `discovery_summary_json` |

Exported outputs:

| Grain | Output |
| --- | --- |
| `discover_infrastructure` | `discovery_model_json` |
| `discover_infrastructure` | `discovery_summary_json` |
| `render_discovery_summary` | `discovery_report_json` |
| `render_discovery_summary` | `discovery_summary_markdown` |
| `discover_infrastructure` | `destroy_status` |
| `discover_infrastructure` | `destroy_results_json` |
| `render_discovery_summary` | `destroy_status` |
| `render_discovery_summary` | `destroy_results_json` |
