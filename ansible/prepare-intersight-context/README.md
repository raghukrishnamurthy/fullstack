# prepare-intersight-context

Shared Jarvis grain that prepares the requested Intersight target context before claim.

## Intent

- provide one reusable run-level context step for both appliance and SaaS claim flows
- prepare the requested Intersight organization context
- keep hidden context plumbing out of the user-facing blueprint contract

## Required inputs

- `platform_yaml`

## Optional inputs

- `organization`
- `placement_yaml`
- `debug_enabled`

## Current behavior

- resolves the Intersight endpoint and Intersight API credentials from `platform_yaml`
- supported Intersight credential inputs within `platform_yaml.intersight.credentials` are:
  - direct values
  - `env://...` references
  - `file://...` references
- for Torque-oriented orchestration, Intersight control-plane credentials are expected to remain workflow-scoped and commonly env-backed
- uses direct `organization` when supplied
- otherwise reads the requested organization from `placement_yaml`
- when an organization is supplied:
  - queries `/organization/Organizations`
  - creates the organization when missing
- exports a shared context contract for downstream claim grains

## Credential model

- this grain treats Intersight credentials as control-plane credentials, not device credentials
- control-plane credentials remain small, workflow-global inputs
- device credentials should not be pushed through this grain; they belong in the target credential mapping path used by downstream device-facing grains

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
- a shared secret-resolution helper now backs this grain so control-plane secret references follow the same direct/file/env contract used elsewhere in the branch
