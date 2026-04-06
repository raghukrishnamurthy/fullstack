# Infrastructure Onboard Devices Architecture

Purpose:

- Define the first infrastructure phase that converts unmanaged bare-metal devices into devices validated and ready for later infrastructure provisioning phases
- Keep the phase independent, idempotent, and capable of re-reading current state from Intersight rather than depending on heavy upstream phase payloads

Phase boundary:

- this phase includes discovery, optional standalone rack password reset, claim, and validation
- it is the complete bring-managed phase for an `infrastructure-domain`
- later infrastructure phases should assume the devices are already onboarded and manageable

Input model:

This phase is expected to use shared YAML-shaped stack context rather than focused JSON-only target inputs.

Required shared inputs:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`

Common optional inputs:

- `site_yaml`
- `solution_yaml`
- `baseline_input_source`
- `baseline_directory`
- `overrides_yaml`
- `validation_mode`
- `execution_intent`

Credential inputs:

- phase orchestration may still accept shared direct credential inputs for FI and standalone rack targets
- standalone rack manufacturing/default credentials remain part of the optional rack reset path
- bundle-backed or override credential contracts should model both
  `credential_role: target` and `credential_role: manufacturing` when
  standalone rack reset may be required
- internal orchestration should translate those inputs into the grain contracts
  already used by the reusable reset and claim grains

Initial implementation note:

- the current implementation uses `build-infrastructure-domain-model` for discovery, preflight readiness, and guarded onboarding action execution
- a dedicated `validate-infrastructure-onboarding` grain now owns the final phase completion contract so higher-level stacks can depend on a separate validation/completeness step
- over time, this validator grain is the right place for customer-defined static rules, full inventory/device presence checks, and Intersight-side logical discovery/completion checks
- standalone rack reset remains available through the separate focused `reset-standalone-rack-password` workflow until inventory-to-reset-target derivation is promoted into this phase

Validation contract:

- onboarding validation is based on inventory intent plus live Intersight truth
- onboarding validation checks only direct onboarding targets for this phase
- current direct onboarding targets are:
  - declared `fi_pair` Fabric Interconnect domains
  - standalone rack servers with direct management endpoints
- child devices discovered later through those control points, such as FI-managed chassis or blades, do not gate onboarding completion
- logical Intersight context checks, such as organization or resource-group creation or reuse policy, belong in earlier `prepare-*` grains and are not end-validation blockers
- claim submission success and onboarding completion are different outcomes:
  - claim grains report submission or immediate claim status
  - validation reports whether the declared direct targets have converged in Intersight

Planned internal grain composition:

1. `build-infrastructure-domain-model`
   - current reusable model and discovery grain
   - planned future naming direction: `build-infrastructure-domain-model`
   - used here to build the effective infrastructure model, discover current state, classify devices, and derive onboarding readiness and claim candidates

2. `reset-standalone-rack-password`
   - optional sub-step for standalone rack targets that still require manufacturing-to-target credential normalization
   - should only act on the subset of rack targets that the model/discovery step identifies as needing reset

3. `prepare-claim-target-credentials`
   - maps final target credentials onto the current claim candidate set
   - remains an internal reusable resolver grain rather than a user-facing phase blueprint

4. `claim-devices-to-intersight`
   - claims prepared FI, rack, Assist, and supported storage targets into the requested Intersight backend
   - assumes organization/context and other claim prerequisites are already satisfied within the higher stack orchestration model
   - handles storage through a referenced Assist path when storage targets are present, without forcing Assist dependency into direct-only onboarding runs

5. `validate-infrastructure-onboarding`
   - interpret preflight readiness, onboarding action execution, and live-validation evidence
   - publish the final phase completion contract that later stacks can fail, wait on, or depend on

6. validation and phase report build
   - summarize discovery and onboarding outputs without requiring later phases to consume a large transient payload

Phase output model:

Primary phase result:

- `phase_readiness`

Supporting outputs may include:

- onboarding validation summary
- claimed-device result summary
- rack reset summary when that path was used
- effective claim result details for troubleshooting

Readiness meaning:

This phase should be considered ready when:

- declared direct onboarding targets have been discovered or reconciled against current Intersight state
- standalone rack devices needing credential normalization have either been corrected or clearly reported as blockers
- direct onboarding targets have been claimed or confirmed already onboarded
- referenced Assist-backed storage targets, when requested, have either been submitted cleanly or reported with explicit Assist dependency failures
- resulting direct onboarding targets are validated as ready for downstream infrastructure provisioning phases

Behavior expectations:

- idempotent execution is required
- the phase may complete quickly when devices are already onboarded
- the phase should rely on durable Intersight state for validation rather than passing a heavy phase-to-phase runtime contract
- grain-to-grain data flow within the phase is expected and appropriate

Relationship to later phases:

- later infrastructure phases should not need to replay claim or rack reset logic
- they should treat this phase as the boundary where unmanaged bare-metal becomes manageable infrastructure
- later phases should re-read current state from Intersight and use `phase_readiness` only as a compact readiness signal
