# Phase Validator Steps

This note lists the current phase blueprints, the validator grain each one ends
with, and the core checks that validator performs.

Use this as the repo reference for the rule:

- each phase blueprint should end with a validator grain
- that validator grain is the phase completion authority

## Current Validator Matrix

### `infrastructure-onboard-devices`

- Blueprint:
  [infrastructure-onboard-devices.yaml](/tmp/jarvis-main-push/blueprints/infrastructure-onboard-devices.yaml)
- Validator grain:
  [validate-infrastructure-onboarding/playbook.yaml](/tmp/jarvis-main-push/ansible/validate-infrastructure-onboarding/playbook.yaml)

Validator steps:

1. Resolve Intersight credentials and normalize polling inputs.
2. Validate the input contract:
   - either `discovery_model_json`
   - or raw `platform_yaml` plus `inventory_yaml`
3. Build the expected direct-target set from inventory:
   - standalone racks
   - FI pairs
4. Query live Intersight state for those direct targets.
5. Validate presence and readiness rules:
   - racks must be present in allowed management modes
   - fabric interconnects must be present and `online`
   - FI pairs must validate as a pair
6. Optionally poll until completion if wait mode is enabled.
7. Export the final onboarding completion outputs:
   - `phase_ready`
   - `phase_status`
   - `phase_readiness_json`

Implementation notes from review:

- this validator already does real live polling and pair validation, which matches the intended validator-grain role well
- its per-poll Intersight read path should use explicit retries so transient `500 Retry later` responses do not abort the validator loop

### `infrastructure-network-provisioning`

- Blueprint:
  [infrastructure-network-provisioning.yaml](/tmp/jarvis-main-push/blueprints/infrastructure-network-provisioning.yaml)
- Validator grain:
  [validate_and_summarize_infrastructure_network/playbook.yaml](/tmp/jarvis-main-push/ansible/validate_and_summarize_infrastructure_network/playbook.yaml)

Validator steps:

1. Validate required upstream phase artifacts exist:
   - effective model
   - realized policy state
   - domain profile state
2. If apply/deploy intent was used, assert deployed switch profiles reached
   `Associated`.
3. Build the managed-object inventory:
   - domain profile
   - switch profiles
   - network policy objects
4. Build the final validation summary:
   - model summary
   - policy realization summary
   - policy attachment summary
   - deploy summary
5. Export the final phase outputs:
   - `phase_ready`
   - `phase_status`
   - `phase_readiness_json`
   - `managed_object_inventory_json`
   - `validation_summary_json`
   - `tac_handoff_json`

Implementation notes from review:

- this validator currently acts more as a final gate and summarizer than a fully independent live-state validator
- it should remain the phase completion authority, but future hardening should prefer direct durable-state checks where practical
- validator-owned Torque output export should be treated as authoritative and should not be silently ignored on failure

### `infrastructure-resource-provisioning`

- Blueprint:
  [infrastructure-resource-provisioning.yaml](/tmp/jarvis-main-push/blueprints/infrastructure-resource-provisioning.yaml)
- Validator grain:
  [validate_and_summarize_infrastructure_resources/playbook.yaml](/tmp/jarvis-main-push/ansible/validate_and_summarize_infrastructure_resources/playbook.yaml)

Validator steps:

1. Validate required upstream resource artifacts exist:
   - resource model
   - live discovery state
   - chassis realization state
2. Summarize current discovery and realization facts:
   - discovered chassis count
   - expected chassis and blade counts
   - associated chassis profile count
   - failed chassis profile count
3. Decide readiness:
   - at least one chassis target must be discovered
   - if apply mode was used, no chassis profile may be failed
   - if apply mode was used, associated profile count must equal target chassis count
4. Build the final resource validation summary.
5. Export the final phase outputs:
   - `phase_ready`
   - `phase_status`
   - `phase_readiness_json`
   - `validation_summary_json`
   - `tac_handoff_json`

### `infrastructure-domain-post-validation`

- Blueprint:
  [infrastructure-domain-post-validation.yaml](/tmp/jarvis-main-push/blueprints/infrastructure-domain-post-validation.yaml)
- Validator grain:
  [validate_infrastructure_domain_inventory/playbook.yaml](/tmp/jarvis-main-push/ansible/validate_infrastructure_domain_inventory/playbook.yaml)

Validator steps:

1. Validate the domain-validator input contract:
   - deployment
   - placement
   - inventory
   - site
   - Intersight credentials
2. Build the expected inventory set:
   - FI serials
   - blade serials
   - FI-managed rack serials
   - standalone rack serials
   - expected chassis count
3. Poll live Intersight inventory until ready, if polling is enabled.
4. Build the validator summary:
   - present devices
   - missing devices
   - not-ready devices
   - chassis validation
   - blocking scope versus advisory scope
5. Decide phase readiness and export:
   - `phase_ready`
   - `phase_status`
   - `phase_readiness_json`
   - `validation_summary_json`
   - `inventory_validation_json`
   - `tac_handoff_json`

## Authoring Rule

When adding a new phase blueprint:

1. define the final validator grain explicitly
2. document what that validator checks
3. make that validator the source for `phase_ready` and `phase_status`
4. keep downstream handoff outputs owned by that validator

Review reminder:

- the validator pattern is not complete unless its live reads are resilient and its final export path is authoritative
