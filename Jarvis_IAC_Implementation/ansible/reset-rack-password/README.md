# reset-rack-password

Inventory-first standalone rack password reset grain.

## Intent

- consume the same wrapped inventory and credential inputs used elsewhere in Jarvis
- identify standalone rack targets
- perform manufacturing-to-desired password transition for IMC rack devices when required
- emit stable outputs that a later `prepare-endpoints` grain can consume

## Current behavior

- if the desired credential already works, the rack is exported as reset-ready
- if the manufacturing credential works and Redfish reports `PasswordChangeRequired`, the grain changes the password and then verifies the desired credential
- if neither path succeeds, the rack is exported in the pending/failed output set with the helper result

## Required inputs

- `inventory_yaml`
- `credential_candidates_yaml`

## Optional inputs

- `deployment_yaml`
- `validation_mode`
- `execution_intent`

## Outputs

- `rack_password_reset_results_json`
- `password_reset_ready_targets_json`
- `password_reset_pending_targets_json`
