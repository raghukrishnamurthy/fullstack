# render-intersight-deployment-summary

Purpose:

- Convert the discovery model into a discovery-summary artifact
- Export a JSON report and a human-readable markdown summary

Grain inputs:

- `discovery_model_json`
- `discovery_summary_json`

Exported outputs:

- `discovery_report_json`
- `discovery_summary_markdown`

Execution notes:

- Runs on `localhost`
- Uses `connection: local`
- Uses `hosts: "{{ group | default('localhost') }}"`
- Uses `any_errors_fatal: true`
- Expects the upstream grain to pass a JSON string

Destroy behavior:

- `teardown.yaml` is a no-op
- Exports `destroy_status` and `destroy_results_json`
