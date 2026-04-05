# Secret Handling Runbook

This runbook captures the secret-handling model validated on the `codex/secrets-file-testing` branch.

## Contract

- Intersight control-plane credentials stay workflow-scoped.
- Device credentials stay target-scoped.
- Control-plane credentials are expected to be supplied as environment-backed inputs.
- Device credentials are expected to be supplied through structured YAML with secret references.
- Secret references can use:
  - `env://NAME`
  - `file:///absolute/path`

## Recommended Split

- Use `env://...` for:
  - Intersight API key id
  - Intersight API private key
  - other workflow-global control-plane credentials
- Use `file://...` for:
  - rack passwords
  - FI passwords
  - storage target passwords
  - other per-device or per-group device login secrets

## Local POC Pattern

For local testing, keep the control-plane credentials in environment variables and keep device passwords in local files.

Example env:

```bash
export INTERSIGHT_API_KEY_ID='your-api-key-id'
export INTERSIGHT_API_PRIVATE_KEY="$(cat /path/to/private-key.pem)"
```

Example device secret files:

```text
/tmp/jarvis-secrets/rack-password.txt
/tmp/jarvis-secrets/fi-password.txt
```

Example `platform_yaml`:

```yaml
platform:
  intersight:
    endpoint: https://ucs-hci-appliance-2.cisco.com
    validate_certs: false
    credentials:
      api_key_id_ref: env://INTERSIGHT_API_KEY_ID
      api_private_key_ref: env://INTERSIGHT_API_PRIVATE_KEY
```

Example device credential bundle:

```yaml
device_credentials:
  per_device:
    WZP270500PQ:
      username: admin
      password_ref: file:///tmp/jarvis-secrets/rack-password.txt
    FDO272406DE:
      username: admin
      password_ref: file:///tmp/jarvis-secrets/fi-password.txt
  globals:
    server:
      username: admin
      password_ref: file:///tmp/jarvis-secrets/rack-password.txt
    fabric_interconnect:
      username: admin
      password_ref: file:///tmp/jarvis-secrets/fi-password.txt
```

## Inventory Guidance

- Inventory should primarily contain device identity and non-secret metadata.
- Good inventory fields:
  - `serial`
  - `mgmt_ip`
  - `category`
  - `form_factor`
  - `management_type`
- Avoid putting raw passwords in inventory.
- If a non-Torque local flow truly needs target-specific secret routing, `password_ref` is supported as an escape hatch.
- The preferred Torque-oriented pattern is:
  - inventory provides identity such as `serial`
  - blueprint/runtime provides the secret bundle source
  - the grain resolves the device credential by serial

## Encryption Pattern

For a stronger local or pre-production pattern, keep encrypted files in the repo or workspace and keep the decryption key outside the repo.

Suggested layout:

```text
repo/
  examples/
  blueprints/
  secrets/
    device-credentials.yaml.enc

outside-repo/
  secrets.key
```

Runtime flow:

1. Keep `secrets.key` outside git-tracked content.
2. Decrypt the bundle into a runtime-local file before Ansible runs.
3. Point the grain at the decrypted file through `file://...`.

Example shape:

```text
encrypted bundle: /workspace/secrets/device-credentials.yaml.enc
key file:        /secure/secrets.key
runtime file:    /tmp/jarvis-secrets/device-credentials.yaml
```

The consuming grain should only see the final runtime file or the file-backed refs inside it.

## `secrets.key` Example Workflow

One simple POC-friendly pattern is:

```bash
openssl rand -hex 32 > /secure/secrets.key
openssl enc -aes-256-cbc -pbkdf2 \
  -in device-credentials.yaml \
  -out device-credentials.yaml.enc \
  -pass file:/secure/secrets.key
```

Then before running Ansible:

```bash
openssl enc -d -aes-256-cbc -pbkdf2 \
  -in device-credentials.yaml.enc \
  -out /tmp/jarvis-secrets/device-credentials.yaml \
  -pass file:/secure/secrets.key
```

After decryption, the runtime can use either:

- a bundle file path directly
- or `file://...` refs that point at files created from that decrypted bundle

## Torque-Oriented Direction

For Torque-style execution, the current validated direction is:

- Intersight credentials:
  - remain env-backed
  - remain customer-facing or orchestration-facing inputs
- device credentials:
  - remain structured YAML
  - carry secret references
  - typically use `file://...` when many devices are involved

This keeps the control-plane auth path simple and keeps device secret handling scalable.

## Validated Branch Behavior

Validated locally on the current branch:

- `prepare-intersight-context` succeeds with:
  - `api_key_id_ref: env://INTERSIGHT_API_KEY_ID`
  - `api_private_key_ref: env://INTERSIGHT_API_PRIVATE_KEY`
- `prepare-claim-target-credentials` succeeds with:
  - `device_credentials.per_device`
  - `device_credentials.globals`
  - `file://...` password refs
- `validate-infrastructure-onboarding` and `reset-standalone-rack-password` now use the same shared secret-resolution helper pattern

## Minimal PVA Test Shape

The current minimal PVA claim validation target is:

- one FI pair target represented by:
  - `domain-01`
  - primary serial `FDO272406DE`
  - endpoint `10.29.135.101`
- one rack target:
  - `rack-server-01`
  - serial `WZP270500PQ`
  - endpoint `10.29.135.106`

Use:

- env-backed Intersight credentials
- file-backed FI and rack passwords
- the appliance endpoint from the PVA example platform model

## Validated PVA Result

Validated on April 5, 2026 against the appliance endpoint:

- `https://ucs-hci-appliance-2.cisco.com`

Using:

- `env://INTERSIGHT_API_KEY_ID`
- `env://INTERSIGHT_API_PRIVATE_KEY`
- `file:///tmp/jarvis-pva-test/fi-password.txt`
- `file:///tmp/jarvis-pva-test/rack-password.txt`

Validated targets:

- FI `FDO272406DE` at `10.29.135.101`
- rack `WZP270500PQ` at `10.29.135.106`

Observed result:

- both appliance claim submissions completed successfully
- both targets accepted `claim_username: admin`
- both targets accepted file-backed device passwords
- the aggregate claim batch exported:
  - `batch_status: successful`
  - `successful_targets: 2`
  - `failed_targets: 0`
  - `changed_targets: 2`

This is the current proof point that the mixed contract works end to end:

- control-plane auth through env-backed refs
- device auth through `file://` refs

## Design Summary

- Control-plane auth stays env/direct.
- Device auth stays structured and reference-based.
- Inventory carries identity, not raw secrets.
- Secret resolution happens in the consuming grain, not upstream.
- One shared resolver should remain the implementation path for direct, file, and env secret references.
