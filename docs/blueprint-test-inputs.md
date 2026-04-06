# Blueprint Test Inputs

Reusable first-run inputs for the current Torque blueprint:

- [claim-devices-to-intersight.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/claim-devices-to-intersight.yaml)
- [cisco-standalone-rack-reset-password.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/cisco-standalone-rack-reset-password.yaml)
- [infrastructure-onboard-devices.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/infrastructure-onboard-devices.yaml)

## SaaS Small Mixed Test

Use this for the first real Torque SaaS run with:

- FI pair target via `10.29.135.101`
- rack target via `10.29.135.106`

### `api_uri`

```text
https://intersight.com/api/v1
```

### `intersight_api_key_id`

```text
<your-saas-api-key-id>
```

### `intersight_api_private_key`

```text
-----BEGIN EC PRIVATE KEY-----
...
-----END EC PRIVATE KEY-----
```

### `organization`

```text
ai-prod
```

### `encrypted_device_secret_bundle_path`

```text
assets/secrets/device-secrets.enc
```

### `device_secret_bundle_key`

```text
jarvis-poc-unlock-key
```

### `credential_candidates_yaml`

```yaml
{}
```

### `claim_targets_json`

```json
[
  {
    "target_id": "domain-01",
    "target_category": "fabric_interconnect",
    "device_type": "imm",
    "serial": "FDO272406DE",
    "endpoint": "10.29.135.101",
    "claim_submission_required": true
  },
  {
    "target_id": "rack-server-01",
    "target_category": "server",
    "device_type": "imc",
    "form_factor": "rack",
    "management_type": "standalone",
    "serial": "WZP270500PQ",
    "endpoint": "10.29.135.106",
    "claim_submission_required": true
  }
]
```

## Appliance Small Mixed Test

Use this for the first real Torque appliance run with:

- FI pair target via `10.29.135.101`
- rack target via `10.29.135.106`

### `api_uri`

```text
https://ucs-hci-appliance-2.cisco.com
```

### `intersight_api_key_id`

```text
<your-appliance-api-key-id>
```

### `intersight_api_private_key`

```text
-----BEGIN EC PRIVATE KEY-----
...
-----END EC PRIVATE KEY-----
```

### `organization`

```text
ai-prod
```

### `encrypted_device_secret_bundle_path`

```text
assets/secrets/device-secrets.enc
```

### `device_secret_bundle_key`

```text
jarvis-poc-unlock-key
```

### `credential_candidates_yaml`

```yaml
{}
```

### `claim_targets_json`

```json
[
  {
    "target_id": "domain-01",
    "target_category": "fabric_interconnect",
    "device_type": "imm",
    "serial": "FDO272406DE",
    "endpoint": "10.29.135.101",
    "platform_type": "UCSFIISM",
    "claim_submission_required": true
  },
  {
    "target_id": "rack-server-01",
    "target_category": "server",
    "device_type": "imc",
    "form_factor": "rack",
    "management_type": "standalone",
    "serial": "WZP270500PQ",
    "endpoint": "10.29.135.106",
    "platform_type": "IMCRack",
    "claim_submission_required": true
  }
]
```

## Notes

- For blueprint claim testing, the key launch input is `claim_targets_json`.
- The active backend branch is selected internally from `api_uri`.
- The grain-level claim blueprint does not expose `deployment_yaml`; it uses a fixed internal deployment label for traceability.
- The blueprint now stages an encrypted device secret bundle and internally resolves `file://__BUNDLE_ROOT__/...` references before the reusable grains run.
- Control-plane Intersight credentials remain direct launch inputs and are bridged to env refs internally.
- `validate_certs` is intentionally fixed to `false` inside the blueprint during current development and is not exposed in the launch form.
- The focused claim blueprint now treats `organization` as an existing-org precondition and passes it directly to `claim_devices_to_intersight`.

## Rack Reset Small Test

Use this for the focused rack password reset blueprint with standalone rack inventory entries.

### `targets_json`

```json
[
  {
    "id": "rack-server-01",
    "serial": "WZP270500PQ",
    "endpoint": "10.29.135.106"
  }
]
```

### `manufacturing_username`

```text
admin
```

### `manufacturing_password`

```text
<manufacturing-or-factory-password>
```

### `target_username`

```text
admin
```

### `target_password`

```text
<desired-rack-password>
```

## Reset Blueprint Notes

- The focused reset blueprint does not expose `credential_candidates_yaml`; it builds the internal candidate list from direct manufacturing and target credential inputs.
- The focused reset blueprint does not expose `deployment_yaml`.
- The public reset blueprint now accepts `targets_json` instead of wrapped inventory YAML.


## Infrastructure Onboard Devices Small Test

Use this for the first real Torque run of the current onboarding phase blueprint.

### `deployment_json`

```yaml
deployment:
  id: ai-pod-sjc01-prod
  site: sjc01
  environment: prod
```

### `placement_json`

```yaml
placement:
  intersight:
    organization: ai-prod
    resource_group: ai-prod
```

### `inventory_json`

```yaml
inventory:
  devices:
    - id: fi-a
      category: fabric_interconnect
      serial: FDO272406DE
      mgmt_ip: 10.29.135.101
    - id: rack-server-01
      category: server
      serial: WZP270500PQ
      mgmt_ip: 10.29.135.106
      attributes:
        form_factor: rack
        management_type: standalone
  domains:
    - domain_id: domain-01
      type: fi_pair
      members:
        - fi-a
  assist:
    - id: assist-01
      name: assist01
      endpoint: assist-101.cisco.com
      credentials:
        username: admin
        password: <assist-password>
  storage:
    - id: pure-01
      name: pure01
      platform: pure
      endpoint: 10.193.42.37
      credentials:
        username: pureuser
        password: <pure-password>
      assist: assist01
```

### `solution_json`

```yaml
solution:
  profile: virtualization_foundation
  delivery_scope: infrastructure
```

### `encrypted_device_secret_bundle_path`

```text
assets/secrets/device-secrets.enc
```

### `device_secret_bundle_key`

```text
jarvis-poc-unlock-key
```

### Optional override input

- `credential_candidates_json`
  Use this only when you intentionally want to override the bundle-provided candidate mapping.
  For the current happy path:

```json
{}
```

### Notes

- The onboarding blueprint now uses the explicit phase chain:
  `prepare_device_secret_bundle` and the other grain ids below are shown in their blueprint form:
  `prepare_intersight_context` -> `build_infrastructure_onboarding_targets` -> `prepare_device_secret_bundle` -> `reset_standalone_rack_password` -> `prepare_claim_target_credentials` -> `prepare_device_connector` -> `split_claim_target_phases` -> `claim_assist_targets_to_intersight` -> `claim_direct_targets_to_intersight` -> `claim_assist_dependent_targets_to_intersight` -> `merge_claim_phase_results` -> `validate_infrastructure_onboarding`
- Onboarding validation is inventory-driven and checks direct targets only:
  FI pairs and standalone racks.
- `inventory.assist` is for claimable Assist systems.
- `inventory.storage` is for third-party storage onboarding.
  Use a user-facing `platform` such as `pure`; the claim grain maps that to the API target type internally.
  For the currently wired Pure flow, reference the Assist by inventory name via `assist: assist01`.
  Storage introduces an Assist dependency only when storage targets are present in the run; customers can still onboard direct infrastructure first and add Assist or storage later.
- The public blueprint surface now uses JSON-string inputs such as `deployment_json`, `placement_json`, `inventory_json`, and `solution_json`.
- `execution_intent: validate_only` is the safest first run.
- The latest validated live run completed after two polling attempts and returned `next_action: proceed_to_infrastructure_network_provisioning`.
