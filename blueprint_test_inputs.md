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

### `fi_target_username`

```text
admin
```

### `fi_target_password`

```text
<fi-target-password>
```

### `rack_target_username`

```text
admin
```

### `rack_target_password`

```text
<rack-target-password>
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

### `fi_target_username`

```text
admin
```

### `fi_target_password`

```text
<fi-target-password>
```

### `rack_target_username`

```text
admin
```

### `rack_target_password`

```text
<rack-target-password>
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
- The blueprint now accepts direct secret inputs and internally uses an env bridge plus internal YAML refs for the reusable grains.
- `validate_certs` and reuse-policy values are intentionally fixed inside the blueprint during development and are not exposed in the launch form.
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

Use this for the first real Torque run of the all-YAML onboarding phase blueprint.

### `deployment_yaml`

```yaml
deployment:
  id: ai-pod-sjc01-prod
  site: sjc01
  environment: prod
```

### `platform_yaml`

```yaml
platform:
  intersight:
    endpoint: https://intersight.com/api/v1
    validate_certs: true
    credentials:
      api_key_id_ref: env://INTERSIGHT_API_KEY_ID
      api_private_key_ref: env://INTERSIGHT_API_PRIVATE_KEY
```

### `placement_yaml`

```yaml
placement:
  intersight:
    organization: ai-prod
    resource_group: ai-prod
```

### `inventory_yaml`

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
```

### `solution_yaml`

```yaml
solution:
  profile: virtualization_foundation
  delivery_scope: infrastructure
```

### `credential_candidates_yaml`

```yaml
credential_candidates:
  - credential_role: target
    target_category: server
    target_form_factor: rack
    target_management_type: standalone
    username: admin
    password_ref: env://RACK_TARGET_PASSWORD
  - credential_role: target
    target_category: fabric_interconnect
    username: admin
    password_ref: env://FI_TARGET_PASSWORD
```

### Notes

- This first working implementation reuses `resolve-intersight-deployment-model` directly.
- Standalone rack password reset remains available through the separate focused reset workflow until that derivation is promoted into this phase.
- `execution_intent: validate_only` is the safest first run.
