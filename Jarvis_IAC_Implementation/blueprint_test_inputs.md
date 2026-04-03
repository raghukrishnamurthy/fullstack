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

### `platform_yaml`

```yaml
platform:
  intersight:
    endpoint: https://intersight.com/api/v1
    credentials:
      api_key_id_ref: env://INTERSIGHT_API_KEY_ID
      api_private_key_ref: env://INTERSIGHT_API_PRIVATE_KEY
```

### `placement_yaml`

```yaml
placement:
  intersight:
    organization: ai-prod
    policy:
      reuse_existing_organization: true
      reuse_existing_resource_group: false
```

### `organization`

```text
ai-prod
```

### `credential_candidates_yaml`

```yaml
credential_candidates:
  - credential_role: target
    target_category: fabric_interconnect
    username: admin
    password_ref: env://FI_TARGET_PASSWORD
  - credential_role: target
    target_category: server
    target_form_factor: rack
    target_management_type: standalone
    username: admin
    password_ref: env://RACKSERVER_DESIRED_PASSWORD
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
    "canonical_endpoint": "10.29.135.101",
    "normalized_claim_key": "FDO272406CK&FDO272406DE",
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
    "canonical_endpoint": "10.29.135.106",
    "normalized_claim_key": "WZP270500PQ",
    "claim_submission_required": true
  }
]
```

### `validation_mode`

```text
strict
```

### `execution_intent`

```text
validate_only
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

### `platform_yaml`

```yaml
platform:
  intersight:
    endpoint: https://ucs-hci-appliance-2.cisco.com
    validate_certs: false
    credentials:
      api_key_id_ref: env://INTERSIGHT_API_KEY_ID
      api_private_key_ref: env://INTERSIGHT_API_PRIVATE_KEY
```

### `placement_yaml`

```yaml
placement:
  intersight:
    organization: ai-prod
    policy:
      reuse_existing_organization: true
      reuse_existing_resource_group: false
```

### `organization`

```text
ai-prod
```

### `credential_candidates_yaml`

```yaml
credential_candidates:
  - credential_role: target
    target_category: fabric_interconnect
    username: admin
    password_ref: env://FI_TARGET_PASSWORD
  - credential_role: target
    target_category: server
    target_form_factor: rack
    target_management_type: standalone
    username: admin
    password_ref: env://RACKSERVER_DESIRED_PASSWORD
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
    "canonical_endpoint": "10.29.135.101",
    "normalized_claim_key": "FDO272406CK&FDO272406DE",
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
    "canonical_endpoint": "10.29.135.106",
    "normalized_claim_key": "WZP270500PQ",
    "platform_type": "IMCRack",
    "claim_submission_required": true
  }
]
```

### `validation_mode`

```text
strict
```

### `execution_intent`

```text
validate_only
```

## Notes

- For blueprint claim testing, the key launch input is `claim_targets_json`.
- The active claim branch is selected from `platform_yaml` endpoint.
- Use SaaS endpoint for `claim_to_saas`.
- Use appliance endpoint for `claim_to_appliance`.
- Keep `credential_candidates_yaml` at the blueprint layer; standalone claim grains expect per-target credentials after resolver mapping.
