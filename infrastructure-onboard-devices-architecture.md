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
- internal orchestration should translate those direct inputs into the grain contracts already used by the reusable reset and claim grains

Initial implementation note:

- the first working implementation of this phase reuses `resolve-intersight-deployment-model` directly together with summary rendering
- standalone rack reset remains available through the separate focused `cisco-standalone-rack-reset-password` workflow until inventory-to-reset-target derivation is promoted into this phase

Planned internal grain composition:

1. `resolve-intersight-deployment-model`
   - current reusable model and discovery grain
   - planned future naming direction: `build-infrastructure-domain-model`
   - used here to build the effective infrastructure model, discover current state, classify devices, and derive onboarding readiness and claim candidates

2. `cisco-standalone-rack-reset-password`
   - optional sub-step for standalone rack targets that still require manufacturing-to-target credential normalization
   - should only act on the subset of rack targets that the model/discovery step identifies as needing reset

3. `resolve-claim-target-credentials`
   - maps final target credentials onto the current claim candidate set
   - remains an internal reusable resolver grain rather than a user-facing phase blueprint

4. `claim-devices-to-intersight`
   - claims prepared FI and rack targets into the requested Intersight backend
   - assumes organization/context and other claim prerequisites are already satisfied within the higher stack orchestration model

5. validation and phase report build
   - confirm devices are now onboarded, manageable, and ready for the next infrastructure phase
   - summarize phase readiness without requiring later phases to consume a large transient payload

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

- declared devices have been discovered or reconciled against current Intersight state
- standalone rack devices needing credential normalization have either been corrected or clearly reported as blockers
- claim-capable devices have been claimed or confirmed already onboarded
- resulting managed devices are validated as ready for downstream infrastructure provisioning phases

Behavior expectations:

- idempotent execution is required
- the phase may complete quickly when devices are already onboarded
- the phase should rely on durable Intersight state for validation rather than passing a heavy phase-to-phase runtime contract
- grain-to-grain data flow within the phase is expected and appropriate

Relationship to later phases:

- later infrastructure phases should not need to replay claim or rack reset logic
- they should treat this phase as the boundary where unmanaged bare-metal becomes manageable infrastructure
- later phases should re-read current state from Intersight and use `phase_readiness` only as a compact readiness signal
