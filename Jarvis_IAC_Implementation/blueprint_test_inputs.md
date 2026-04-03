# Blueprint Test Inputs

Reusable first-run inputs for the current Torque blueprint:

- [onboard-intersight-devices.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/blueprints/onboard-intersight-devices.yaml)

## SaaS Small Mixed Test

Use this for the first real Torque SaaS run with:

- FI pair target via `10.29.135.101`
- rack target via `10.29.135.106`

### `deployment_yaml`

```yaml
deployment:
  id: ai-pod-sjc01-prod
  site: sjc01
  environment: production
```

### `intersight_endpoint`

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

### `deployment_yaml`

```yaml
deployment:
  id: ai-pod-pva-sjc01-prod
  site: sjc01
  environment: production
```

### `intersight_endpoint`

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
- The active claim branch is selected from `intersight_endpoint`.
- Use SaaS endpoint for `claim_to_saas`.
- Use appliance endpoint for `claim_to_appliance`.
- The blueprint now accepts direct secret inputs and internally uses an env bridge plus internal YAML refs for the reusable grains.
- `validate_certs` and reuse-policy values are intentionally fixed inside the blueprint during development and are not exposed in the launch form.
