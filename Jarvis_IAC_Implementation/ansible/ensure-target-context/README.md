# ensure-target-context

Shared Jarvis grain that ensures the requested Intersight target context exists before claim.

## Intent

- provide one reusable run-level context step for both appliance and SaaS claim flows
- ensure the requested Intersight organization exists
- keep hidden context plumbing out of the user-facing blueprint contract

## Required inputs

- `platform_yaml`

## Optional inputs

- `placement_yaml`
- `debug_enabled`

## Current behavior

- resolves the Intersight endpoint and env-backed API credentials from `platform_yaml`
- reads the requested organization from `placement_yaml`
- when an organization is supplied:
  - queries `/organization/Organizations`
  - creates the organization when missing
- exports a shared context contract for downstream claim grains

## Outputs

- `context_status`
- `org_status`
- `org_name`
- `org_action`
- `org_result_json`
- `context_result_json`

## Notes

- this grain does not delete organizations during teardown
- Resource Group and reservation creation still stay inside the current claim implementations
- the first slice is intentionally narrow: shared org context first, broader shared placement context later
