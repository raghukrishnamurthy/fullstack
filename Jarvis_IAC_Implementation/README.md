# Jarvis IAC Torque Scaffold

This directory contains a Torque-ready scaffold derived from the v2 Jarvis IAC architecture and input model.

The current implementation focus is the first infrastructure slice:

1. Collect deployment, platform, placement, site, baseline-resolution, and inventory inputs
2. Normalize optional credential candidate inputs for future claim preparation
3. Normalize and validate infrastructure devices
4. Optionally validate declared serials against Cisco Intersight
5. Derive infrastructure classification from device facts and topology
6. Render a discovery summary artifact for downstream workflows

Current offering shape:

- offering type: `custom`
- platform focus: Cisco Intersight and Cisco infrastructure onboarding
- automation shape: multi-grain Ansible blueprint
- reference conventions: aligned to `/Users/rkrishn2/intersightztp`

Files:

- `blueprint.yaml`
  Torque `spec_version: 2` blueprint
- `catalog_ui.md`
  End-user workflow and stable form keys
- `wiring-table.md`
  Form key to grain input mapping
- `ansible/resolve-deployment-model/`
  Validates inventory, normalizes devices, and derives infrastructure classification
- `ansible/render-master-plan/`
  Produces a discovery summary from the derived infrastructure view

Assumptions:

- Torque launch-form complex inputs are passed as strings
- YAML-shaped customer data is supplied as multiline string inputs
- `site_yaml` is optional and carries site-scoped operational defaults such as location, DNS, NTP, and proxy settings
- `credential_candidates_yaml` is the current direct-input mechanism for target credential rotation candidates
- rack-server flows can use typed candidates such as:
  `manufacturing` for factory/default login and `target` for the desired post-rotation credential
- `baseline_input_source` and `baseline_directory` are optional customer-baseline sources for higher orchestration and direct Ansible execution
- `overrides_yaml` is the deployment-specific delta layer and is optional
- provide only one customer baseline source at a time
- the scaffold always starts from a built-in baseline selected by `solution.profile`
- when `baseline_directory` is provided, the scaffold expects `baseline.yaml` in that directory
- when `baseline_input_source` is provided, the scaffold fetches YAML from the given HTTP(S) URL
- precedence is:
  built-in baseline -> customer baseline -> overrides
- `overrides_yaml` is merged recursively onto the effective baseline payload
- the scaffold now uses the effective baseline payload for early onboarding expectation checks
- `validation_mode: strict` validates the input contract only
- `validation_mode: live` resolves env-based Intersight credential refs and queries Cisco Intersight for declared serials
- live mode also evaluates placement targets in Intersight and reports whether the requested organization/resource group would be reused, created, or would conflict with placement policy
- `execution_intent` defaults to `validate_only`
- even when onboarding is ready, this scaffold still stops at a guarded no-op onboarding-action boundary
- This scaffold does not yet claim devices or mutate Intersight resources
- future target handling should remain type-aware:
  FI and server targets may become claim/onboarding-ready, while storage targets may initially support only reachability-style readiness such as TCP or ping validation
- discovery outputs now carry target readiness profiles to make that distinction explicit for downstream workflows
- vault or secret-manager integration for target credentials is intentionally deferred until the Torque-side mechanism is agreed
- Explicit no-op destroy flows are included to match the reference repo pattern
