# Jarvis IAC Torque Scaffold

This directory contains a Torque-ready scaffold derived from the v2 Jarvis IAC architecture and input model.

The current implementation focus is the first infrastructure slice:

1. Collect deployment, platform, placement, site, baseline-resolution, and inventory inputs
2. Normalize optional credential candidate inputs for endpoint preparation and claim
3. Normalize and validate infrastructure devices
4. Optionally validate declared serials against Cisco Intersight
5. Derive run-level claim readiness from baseline, placement, and target selection
6. Run endpoint-side connector preparation and PVA claim for supported targets
7. Render a discovery summary artifact for downstream workflows

Current offering shape:

- offering type: `custom`
- platform focus: Cisco Intersight and Cisco infrastructure onboarding
- automation shape: multi-grain Ansible blueprint
- reference conventions: aligned to `/Users/rkrishn2/intersightztp`

Design requirement:

- reusable grains must remain narrow and standalone
- reusable grains must not depend on the full `deployment_yaml` unless they are explicitly model/discovery grains
- blueprint or one thin direct-Ansible wrapper playbook is the orchestration layer
- credential-map resolution belongs in orchestration or in a dedicated resolver grain, not inside execution grains
- standalone execution grains should consume per-target fields such as `claim_username` and `claim_password_ref`
- the public Torque blueprint should prefer direct inputs for endpoints, organizations, and secrets, then translate them into internal YAML or env-shaped contracts as needed

Files:

- `blueprints/claim-intersight-devices.yaml`
  Torque `spec_version: 2` blueprint
  uses `store: intersight-fullstack-repo` for grain sources
- `catalog_ui.md`
  End-user workflow and stable form keys
- `wiring-table.md`
  Form key to grain input mapping
- `skills/`
  Repo-local shared Torque/Codex skill guidance for blueprint and Ansible patterns used in this repo
- `ansible/resolve-intersight-deployment-model/`
  Validates inventory, derives claim candidates, and runs prepare-and-claim flow
- `ansible/render-intersight-deployment-summary/`
  Produces a discovery summary from the derived infrastructure view
- `ansible/bootstrap_runtime/`
  Optional worker bootstrap playbook that installs shared Python and collection requirements
- `ansible/reset-rack-password/`
  Separate grain for IMC rack manufacturing-to-desired password reset before prepare-and-claim
- `ansible/resolve-claim-target-credentials/`
  Maps shared credential candidates onto per-target claim credential fields
- `ansible/claim-intersight-devices/`
  Unified claim grain that routes internally to SaaS or appliance logic and exports one stable final claim contract
- `ansible/run-intersight-claim-chain/`
  Thin direct-Ansible orchestration path that invokes the reusable context, credential-resolution, claim, and normalize grains
- `examples/ai-pod-sjc01-prod/`
  Local example inputs that mirror the blueprint contract
- `scripts/run_example_strict.sh`
  Safe local runner for the example inputs in strict non-mutating mode
- `scripts/run_example_strict_checked.sh`
  Safe local runner plus lightweight assertions for expected strict-mode outputs
- `scripts/run_example_live.sh`
  Local runner for live Intersight validation mode using the same example input set
- `scripts/run_example_live_checked.sh`
  Live-mode runner plus lightweight assertions for expected live-validation outputs
  the checked runners use small embedded Python assertion blocks to validate
  persisted JSON outputs rather than relying only on Ansible exit codes

Local test path:

- `./scripts/run_example_strict.sh`
  executes the example input set end to end against `ansible/resolve-intersight-deployment-model/playbook.yaml`
  in `validation_mode=strict` and `execution_intent=validate_only`
- `./scripts/run_example_strict_checked.sh`
  executes the same path and verifies a few expected JSON output values for the AI Pod example
- `./scripts/run_example_live.sh`
  executes the example input set in `validation_mode=live`; requires the referenced env-based Intersight credentials
- `./scripts/run_example_live_checked.sh`
  executes the live path and verifies a few expected live-validation output values
  both live scripts fail fast when `INTERSIGHT_API_KEY_ID` or `INTERSIGHT_API_PRIVATE_KEY` are not present

Assumptions:

- Torque launch-form complex inputs are passed as strings
- YAML-shaped blueprint inputs should be avoided in Torque-facing contracts; prefer direct inputs or JSON strings and assemble internal YAML only inside the blueprint or automation layer when necessary
- the focused claim blueprint now prefers direct user-facing inputs for endpoint, org, and secrets
- the blueprint internally builds:
  - `platform_yaml` for the claim and context grains
  - `placement_yaml` only for `ensure-intersight-context`
  - `credential_candidates_yaml` only for `resolve-claim-target-credentials`
- claim grains assume the organization/context is already prepared and consume direct `organization`
- `site_yaml` is optional and carries site-scoped operational defaults such as location, DNS, NTP, and proxy settings
- `credential_candidates_yaml` is the current direct-input mechanism for target credential rotation candidates
- blueprint and direct-Ansible orchestration can accept shared `credential_candidates_yaml`, but standalone claim grains are expected to consume per-target `claim_username` and `claim_password_ref`
- rack-server flows can use typed candidates such as:
  `manufacturing` for factory/default login and `target` for the desired post-rotation credential
- in the main prepare-and-claim flow, standalone rack targets are expected to already use the desired credential
- manufacturing/default rack credentials now belong in the separate `reset-rack-password` grain
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
- `execution_intent: apply` now supports real PVA claim submission for:
  - one Fabric Interconnect pair claim unit per declared `fi_pair` domain
  - standalone rack servers using target credentials
- blade targets currently remain in the guarded non-direct path and are not submitted for direct PVA claim
- future target handling should remain type-aware:
  FI and server targets may become claim/onboarding-ready, while storage targets may initially support only reachability-style readiness such as TCP or ping validation
- discovery outputs now carry target readiness profiles to make that distinction explicit for downstream workflows
- vault or secret-manager integration for target credentials is intentionally deferred until the Torque-side mechanism is agreed
- storage target handling should evolve toward an Assist-mediated flow:
  first validate Assist reachability, then run storage claim using Assist as the effective target path
- Explicit no-op destroy flows are included to match the reference repo pattern

Runtime dependencies:

- shared Python requirements live in [requirements.txt](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/ansible/requirements.txt)
- this includes `cryptography==44.0.3`, matching the tested `intersightztp` runtime pattern for Intersight-backed workflows
- [playbook.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/ansible/bootstrap_runtime/playbook.yaml)
  can be used to prepare a worker with:
  - shared Python dependencies
  - `resolve-intersight-deployment-model` collections
  - `render-intersight-deployment-summary` collections

Python helpers and custom modules:

- [/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/ansible/claim-to-saas/tools/run_claim_readiness.py](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/ansible/claim-to-saas/tools/run_claim_readiness.py)
  Repo-local helper that retrieves per-target claim-readiness data from device connector endpoints before SaaS claim submission.
- [/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/ansible/claim-to-saas/library/intersight_scoped_claim.py](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/ansible/claim-to-saas/library/intersight_scoped_claim.py)
  Custom Ansible module used by the SaaS claim grain to submit scoped claims and return a stable result payload.
- [/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/ansible/reset-rack-password/tools/run_reset_rack_password.py](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/ansible/reset-rack-password/tools/run_reset_rack_password.py)
  Repo-local helper for manufacturing-to-desired IMC rack password rotation used by the separate reset grain.

Current checkpoint:

- PVA flow is proven live for:
  - one FI pair claim unit derived from a declared `fi_pair` domain
  - standalone rack claim targets
- appliance claim follow-up now waits once after all submissions, then enriches results in an aggregate pass
- blueprint claim orchestration now uses the focused unified claim chain:
  - `ensure-intersight-context`
  - `resolve-claim-target-credentials`
  - `claim-intersight-devices`
- `ensure-intersight-context` owns organization/context setup
- claim grains intentionally assume org/resource-group prerequisites are already satisfied
- the unified claim grain also assumes other endpoint prerequisites are already satisfied, such as device connector preparation and any required reset-to-known-state work
- rack password reset is split into its own grain and is no longer part of the main prepare-and-claim playbook
