# POC Device Secret Bundle

This directory is reserved for proof-of-concept encrypted device secret bundles.

Recommended bundle archive contents:

- `credential_candidates.yaml`
- `fi-password.txt`
- `rack-password.txt`
- `rack-manufacturing-password.txt`
- `assist-password.txt`
- `pure-password.txt`

The `credential_candidates.yaml` file can reference the unpacked bundle root with
the placeholder `__BUNDLE_ROOT__`, for example:

```yaml
credential_candidates:
  - credential_role: manufacturing
    target_category: server
    target_form_factor: rack
    target_management_type: standalone
    username: admin
    password_ref: file://__BUNDLE_ROOT__/rack-manufacturing-password.txt
  - credential_role: target
    target_category: server
    target_form_factor: rack
    target_management_type: standalone
    username: admin
    password_ref: file://__BUNDLE_ROOT__/rack-password.txt
  - credential_role: target
    target_category: fabric_interconnect
    username: admin
    password_ref: file://__BUNDLE_ROOT__/fi-password.txt
  - credential_role: target
    target_category: assist
    target_management_type: device_connector
    username: admin
    password_ref: file://__BUNDLE_ROOT__/assist-password.txt
  - credential_role: target
    target_category: storage
    target_management_type: assist_managed
    username: pureuser
    password_ref: file://__BUNDLE_ROOT__/pure-password.txt
```

For infrastructure onboarding examples, prefer:

- no inline device passwords in `inventory_json`
- `storage[*].assist` referencing the Assist `id`
- the encrypted bundle as the source of truth for device claim credentials
- carrying both `target` and `manufacturing` credentials when standalone rack
  reset may be required

Do not commit real plaintext secrets in this directory.
