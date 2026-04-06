# Jarvis IAC Torque Scaffold

This directory contains a Torque-ready scaffold derived from the v2 Jarvis IAC architecture and input model.

The current implementation focus is the first infrastructure onboarding slice:

1. Prepare the shared Intersight context needed for onboarding
2. Build direct onboarding targets from `inventory_json`
3. Optionally reset standalone rack passwords before claim
4. Map credential candidates onto per-target claim inputs
5. Run device-connector preparation where applicable
6. Claim direct onboarding targets into Intersight
7. Validate onboarding completion from inventory intent plus live Intersight truth

Current offering shape:

- offering type: `custom`
- platform focus: Cisco Intersight and Cisco infrastructure onboarding
- automation shape: multi-grain Ansible blueprint
- reference conventions: aligned to the repo's documented grain, blueprint, and orchestration standards

Repo map:

- `blueprints/`
  User-facing Torque blueprints and phase entry points.
- `ansible/`
  Reusable grains, helper playbooks, and supporting automation logic.
- `docs/`
  Active implementation guides, wiring notes, test inputs, and architecture docs.
- `prompts/`
  Canonical prompt specifications used to shape higher-level generation workflows.
- `references/`
  Non-runtime source material such as example models and lightweight vendor/documentation indexes.
- `examples/`
  Runnable sample inputs that mirror the current blueprint contracts.
- `assets/`
  Runtime assets packaged or staged by workflows, including encrypted secret bundles.
- `skills/`
  Repo-local Codex guidance and curated external-reference pointers.
- `CONTRIBUTING.md`
  Small repo-maintenance guide for where docs, prompts, references, examples, and generated files belong.

Design requirement:

- reusable grains must remain narrow and standalone
- reusable grains must not depend on the full `deployment_yaml` unless they are explicitly model/discovery grains
- blueprint or one thin direct-Ansible wrapper playbook is the orchestration layer
- orchestration or wrapper layers should own user-facing input normalization so the same leaf grain can be reused from Torque, direct Ansible, or future Tower/AAP-style orchestrators
- credential-map resolution belongs in orchestration or in a dedicated resolver grain, not inside execution grains
- standalone execution grains should consume per-target fields such as `claim_username` and `claim_password_ref`
- the public Torque blueprint should prefer direct inputs for endpoints, organizations, and secrets, then translate them into internal YAML or env-shaped contracts as needed
- focused operational blueprints should prefer small JSON target contracts, while higher-level stack orchestration should continue to use normalized `inventory_yaml` as the shared source of truth

Higher-level orchestration blueprint boundary:

- the higher-level stack blueprint is intentionally not the same as the focused operational blueprints
- it should own normalized `inventory_yaml` as the shared source of truth across discovery, preparation, claim, and reporting workflows
- it is the right place for optional scan or discovery-driven target selection before those targets are normalized
- it should own context preparation concerns such as organization or resource-group preparation before downstream claim execution
- it should orchestrate focused operational workflows such as `reset-standalone-rack-password` and `claim-devices-to-intersight` rather than re-implementing their endpoint logic
- it should continue to use reusable grains such as `prepare-intersight-context`, `build-infrastructure-onboarding-targets`, `prepare-device-connector`, `claim-devices-to-intersight`, and `validate-infrastructure-onboarding` for broader flow composition
- focused operational blueprints should remain narrow wrappers for a single operational task, while the higher-level blueprint becomes the place where sequencing, policy, and shared inventory normalization are expressed

Blueprint promotion and handoff standard:

- top-level stack workflows should get blueprint surfaces
- lowest-level user-facing operational workflows should get blueprint surfaces
- middle layers should remain reusable grains until they clearly need promotion to a user-facing phase or stack boundary
- grain-to-grain information flow is expected within a phase, but inter-phase contracts should stay minimal because later phases re-read durable state from Intersight
- `build-infrastructure-domain-model` can remain available as a separate model/report grain, but it is no longer the main onboarding validation authority
- separate validation/completeness grains are encouraged where a phase must publish a reusable completion authority that later blueprints can fail on, wait on, or run independently

Implementation scope note:

- the current repo is an Intersight-focused implementation of the broader phase model
- Intersight is treated as the durable source of truth for onboarding state, management state, and downstream phase readiness
- the same high-level phases may still generalize to non-Intersight stacks later
- non-Intersight implementations would likely need different internal grains, validations, and input/output contracts even when the phase names stay similar

Planned stack architecture:

- [infrastructure-stack-architecture.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/infrastructure-stack-architecture.md)
  Draft architecture for the higher-level `deploy-infrastructure-stack` blueprint and its phase boundaries.
- [infrastructure-onboard-devices-architecture.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/infrastructure-onboard-devices-architecture.md)
  Draft phase boundary for the first infrastructure onboarding phase, including discovery, optional rack reset, claim, and validation.
- [infrastructure-network-provisioning-architecture.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/infrastructure-network-provisioning-architecture.md)
  Draft phase boundary for shared FI and fabric/network foundation, kept separate from later solution-specific logical network provisioning.
- [infrastructure-resource-provisioning-architecture.md](/Users/rkrishn2/Documents/Jarvis_IAC/docs/infrastructure-resource-provisioning-architecture.md)
  Draft phase boundary for reusable chassis and management-plane resource foundation, kept separate from later solution-specific resource consumption.
- [blueprints/infrastructure-onboard-devices.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/infrastructure-onboard-devices.yaml)
  First working phase blueprint for device onboarding using JSON-string launch inputs and an explicit grain chain for context preparation, target building, reset, claim preparation, claim, and validation.
- [blueprints/infrastructure-network-provisioning.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/infrastructure-network-provisioning.yaml)
  First working phase blueprint for shared FI and fabric/network foundation planning, currently implemented as planning and validation only.

Blueprint naming convention in this repo:

- keep blueprint files under top-level `blueprints/` and use `.yaml`
- use descriptive `kebab-case` file names
- for cross-system operational workflows, prefer directional names in the form `<action>-<object>-to-<target>`
- use focused action names for grain-level blueprints, for example:
  - `claim-devices-to-intersight.yaml`
  - `cisco-standalone-rack-reset-password.yaml`
- reserve broader names such as `onboard-*` for true end-to-end orchestration blueprints, not focused operational wrappers
- keep the file name scope-accurate even when the Torque catalog display name later becomes more user-friendly

Files:

- `blueprints/claim-devices-to-intersight.yaml`
  Torque `spec_version: 2` blueprint
  uses `store: intersight-fullstack-repo` for grain sources
- `blueprints/cisco-standalone-rack-reset-password.yaml`
  Focused standalone rack password reset blueprint
  wraps the reusable `reset-standalone-rack-password` grain with direct credential inputs
- `blueprints/infrastructure-onboard-devices.yaml`
  First working infrastructure phase blueprint using JSON-string launch inputs with internal structured context for preparation, direct target claim, and onboarding validation
- `blueprints/infrastructure-network-provisioning.yaml`
  First working infrastructure network phase blueprint using shared structured phase context and a reusable planning grain for shared FI and fabric/network foundation
- `docs/README.md`
  Supplemental documentation index for blueprint UX, wiring, examples, architecture, and secret handling
- `docs/catalog_ui.md`
  End-user workflow and stable form keys
- `docs/wiring-table.md`
  Form key to grain input mapping
- `docs/blueprint_test_inputs.md`
  Reusable first-run launch inputs for the active blueprints
- `prompts/infrastructure-prompt-spec.md`
  Canonical prompt specification for infrastructure input and solution-profile generation
- `references/`
  Non-runtime reference material such as model examples and vendor/API reference files
- `skills/`
  Repo-local shared Torque/Codex skill guidance for blueprint and Ansible patterns used in this repo
- `ansible/build-infrastructure-onboarding-targets/`
  Builds direct onboarding targets from `inventory_json` for FI pairs and standalone racks
- `ansible/bootstrap_runtime/`
  Optional worker bootstrap playbook that installs shared Python and collection requirements
- `ansible/reset-standalone-rack-password/`
  Separate grain for IMC rack manufacturing-to-desired password reset before prepare-and-claim
- `ansible/prepare-claim-target-credentials/`
  Maps shared credential candidates onto per-target claim credential fields
- `ansible/prepare-device-connector/`
  Explicit device-connector preparation grain used in the shared onboarding flow
- `ansible/claim-devices-to-intersight/`
  Unified claim grain that routes internally to SaaS or appliance logic, uses shared helper tasks for claim/result handling, and exports one stable final claim contract
- `ansible/infrastructure-network-provisioning/`
  First working planning grain for shared FI and fabric/network foundation under the infrastructure stack model
- `ansible/validate-infrastructure-onboarding/`
  Validation and completion grain that owns the final onboarding phase readiness contract using inventory intent plus live direct-target truth
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

Published automation sources:

| Repo Path | Torque Store | Blueprint Use | Notes |
| --- | --- | --- | --- |
| `blueprints/claim-devices-to-intersight.yaml` | `intersight-fullstack-repo` | Public blueprint | Focused claim workflow |
| `blueprints/cisco-standalone-rack-reset-password.yaml` | `intersight-fullstack-repo` | Public blueprint | Focused standalone rack reset workflow |
| `blueprints/infrastructure-onboard-devices.yaml` | `intersight-fullstack-repo` | Phase blueprint | First working infrastructure onboarding phase |
| `blueprints/infrastructure-network-provisioning.yaml` | `intersight-fullstack-repo` | Phase blueprint | First working infrastructure network phase |
| `ansible/validate-infrastructure-onboarding/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Final onboarding completion validation |
| `ansible/validate-infrastructure-onboarding/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
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
| `ansible/prepare-device-connector/playbook.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit connector preparation step |
| `ansible/prepare-device-connector/teardown.yaml` | `intersight-fullstack-repo` | Reusable grain | Explicit no-op destroy |
| `ansible/bootstrap_runtime/playbook.yaml` | `intersight-fullstack-repo` | Utility grain | Optional worker bootstrap |

Local test path:

- `./scripts/run_example_strict.sh`
  executes the example input set end to end against the current onboarding blueprint chain
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
- user-facing input normalization should happen as early as practical in the blueprint or wrapper layer; leaf grains should keep only the validation and derivation they need for correct execution
- the blueprint internally builds:
  - `platform_yaml` for the claim and context grains
  - `placement_yaml` only for `prepare-intersight-context`
  - `credential_candidates_yaml` only for the secret-bundle and credential-resolution grains
- claim grains assume the organization/context is already prepared and consume direct `organization`
- `site_json` is optional and carries site-scoped operational defaults such as location, DNS, NTP, and proxy settings
- `credential_candidates_json` and `credential_candidates_yaml` are optional override contracts for target credential candidates
- the public claim and onboarding blueprints now prefer encrypted bundle inputs for device-side secrets:
  - `encrypted_device_secret_bundle_path`
  - `device_secret_bundle_key`
- the public onboarding blueprint no longer exposes direct FI or rack password inputs; control-plane credentials stay as launch inputs and are mapped to env-backed refs internally during execution
- the checked-in POC bundle at `assets/secrets/device-secrets.enc` with the current test key `jarvis-poc-unlock-key` is intended only for validated lab flows; real plaintext secrets should not be committed
- per-device credentials remain supported through the credential-candidate and claim-target contracts even though the primary Torque path now stages the encrypted bundle and then resolves `file://__BUNDLE_ROOT__/...` references at runtime
- rack-server flows can use typed candidates such as:
  `manufacturing` for factory/default login and `target` for the desired post-rotation credential
- in the main prepare-and-claim flow, standalone rack targets are expected to already use the desired credential
- manufacturing/default rack credentials now belong in the separate `reset-standalone-rack-password` grain
- `baseline_input_source` and `baseline_directory` are optional customer-baseline sources for higher orchestration and direct Ansible execution
- `overrides_json` is the deployment-specific delta layer and is optional
- provide only one customer baseline source at a time
- the scaffold always starts from a built-in baseline selected by `solution.profile`
- when `baseline_directory` is provided, the scaffold expects `baseline.yaml` in that directory
- when `baseline_input_source` is provided, the scaffold fetches YAML from the given HTTP(S) URL
- precedence is:
  built-in baseline -> customer baseline -> overrides
- `overrides_json` is merged recursively onto the effective baseline payload
- the scaffold now uses the effective baseline payload for early onboarding expectation checks
- `validation_mode: strict` validates the input contract only
- `validation_mode: live` resolves env-based Intersight credential refs and queries Cisco Intersight for declared serials
- `execution_intent` defaults to `validate_only`
- `execution_intent: apply` now supports real PVA claim submission for:
  - one Fabric Interconnect pair claim unit per declared `fi_pair` domain
  - standalone rack servers using target credentials
- onboarding validation compares inventory intent with live direct-target objects only:
  - FI pair intent validates against two FI member objects in `network/Elements`
  - standalone rack intent validates against `compute/PhysicalSummaries`
- blade and other child devices do not gate onboarding completion
- organization and resource-group policy belongs in `prepare-intersight-context`, not in end validation
- future target handling should remain type-aware:
  FI and server targets may become claim/onboarding-ready, while storage targets may initially support only reachability-style readiness such as TCP or ping validation
- discovery outputs now carry target readiness profiles to make that distinction explicit for downstream workflows
- vault or secret-manager integration for target credentials is intentionally deferred until the Torque-side mechanism is agreed
- storage target handling should evolve toward an Assist-mediated flow:
  first validate Assist reachability, then run storage claim using Assist as the effective target path
- Explicit no-op destroy flows are included so focused operational blueprints have a predictable, non-destructive destroy behavior

Runtime dependencies:

- shared Python requirements live in [requirements.txt](/Users/rkrishn2/Documents/Jarvis_IAC/ansible/requirements.txt)
- this includes `cryptography==44.0.3`, which is the pinned runtime dependency used by the repo's Intersight-backed workflows
- [playbook.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/ansible/bootstrap_runtime/playbook.yaml)
  can be used to prepare a worker with:
  - shared Python dependencies
  - the repo's Intersight automation collections

Python helpers and custom modules:

- [/Users/rkrishn2/Documents/Jarvis_IAC/ansible/claim-devices-to-intersight/tools/run_claim_readiness.py](/Users/rkrishn2/Documents/Jarvis_IAC/ansible/claim-devices-to-intersight/tools/run_claim_readiness.py)
  Repo-local helper that retrieves per-target claim-readiness data from device connector endpoints before SaaS claim submission inside the unified claim grain.
- [/Users/rkrishn2/Documents/Jarvis_IAC/ansible/claim-devices-to-intersight/library/intersight_scoped_claim.py](/Users/rkrishn2/Documents/Jarvis_IAC/ansible/claim-devices-to-intersight/library/intersight_scoped_claim.py)
  Custom Ansible module used by the unified claim grain to submit scoped SaaS claims and return a stable result payload.
- [/Users/rkrishn2/Documents/Jarvis_IAC/ansible/reset-standalone-rack-password/tools/run_cisco_standalone_rack_reset_password.py](/Users/rkrishn2/Documents/Jarvis_IAC/ansible/reset-standalone-rack-password/tools/run_cisco_standalone_rack_reset_password.py)
  Repo-local helper for manufacturing-to-desired IMC rack password rotation used by the separate reset grain.

Current checkpoint:

- `main` is now clean and includes the docs reorg, prompt consolidation, references layout, and bundle-based onboarding updates.
- PVA flow is proven live for:
  - one FI pair claim unit derived from a declared `fi_pair` domain
  - standalone rack claim targets
- storage claim now depends on the referenced Assist only when storage targets are included in the run
- appliance storage short-circuits existing storage targets first, then waits for the referenced Assist to reach `Connected` before submitting new storage claims
- appliance claim follow-up now waits once after all submissions, then enriches results in an aggregate pass
- the focused claim blueprint now uses the active grain-level chain:
  - `prepare_device_secret_bundle`
  - `resolve_claim_target_credentials`
  - `split_claim_target_phases`
  - `claim_assist_targets_to_intersight`
  - `claim_direct_targets_to_intersight`
  - `claim_assist_dependent_targets_to_intersight`
  - `merge_claim_phase_results`
- the public focused claim blueprint now exposes:
  - `agent`
  - `api_uri`
  - `intersight_api_key_id`
  - `intersight_api_private_key`
  - `organization`
  - `encrypted_device_secret_bundle_path`
  - `device_secret_bundle_key`
  - `credential_candidates_yaml`
  - `claim_targets_json`
- the focused claim blueprint no longer exposes `deployment_yaml`; it uses a fixed internal deployment label for traceability
- the focused rack reset blueprint now exposes:
  - `targets_json`
  - `manufacturing_username`
  - `manufacturing_password`
  - `target_username`
  - `target_password`
- the focused rack reset blueprint builds internal credential candidates for the reusable reset grain and exports Torque-native outputs directly from that grain
- the reusable reset grain now consumes `targets_json` directly
- `api_uri` is the backend selector for the focused claim blueprint and should be the real API base URI, for example:
  - `https://intersight.com/api/v1`
  - `https://ucs-hci-appliance-2.cisco.com/api/v1`
- the focused claim blueprint treats `organization` as an existing-org precondition and passes it directly to the unified claim grain
- claim grains intentionally assume org/resource-group prerequisites are already satisfied
- the unified claim grain also assumes other endpoint prerequisites are already satisfied, such as device connector preparation and any required reset-to-known-state work
- appliance claim API calls now default to `use_proxy: false`; proxy use should only be enabled when that path is explicitly wired into the contract
- rack password reset is split into its own grain and is no longer part of the main prepare-and-claim playbook
- the public onboarding blueprint now uses the active phase chain:
  - `prepare_intersight_context`
  - `build_infrastructure_onboarding_targets`
  - `prepare_device_secret_bundle`
  - `reset_standalone_rack_passwords`
  - `prepare_claim_target_credentials`
  - `prepare_device_connector`
  - `split_claim_target_phases`
  - `claim_assist_targets_to_intersight`
  - `claim_direct_targets_to_intersight`
  - `claim_assist_dependent_targets_to_intersight`
  - `merge_claim_phase_results`
  - `validate_infrastructure_onboarding`
- the latest validated Torque onboarding run completed successfully with:
  - `phase_ready: true`
  - `phase_status: completed`
  - `next_action: proceed_to_infrastructure_network_provisioning`
  - `successful_claim_result_count: 5`
  - `blocking_claim_result_count: 0`
  - `missing_device_count: 0`
  - `not_ready_device_count: 0`
  - `attempts_executed: 2`
