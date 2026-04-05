# POC Device Secret Bundle

This directory is reserved for proof-of-concept encrypted device secret bundles.

Recommended bundle archive contents:

- `credential_candidates.yaml`
- `fi-password.txt`
- `rack-password.txt`

The `credential_candidates.yaml` file can reference the unpacked bundle root with
the placeholder `__BUNDLE_ROOT__`, for example:

```yaml
device_credentials:
  per_device:
    FDO272406DE:
      username: admin
      password_ref: file://__BUNDLE_ROOT__/fi-password.txt
    WZP270500PQ:
      username: admin
      password_ref: file://__BUNDLE_ROOT__/rack-password.txt
  globals:
    fabric_interconnect:
      username: admin
      password_ref: file://__BUNDLE_ROOT__/fi-password.txt
    server:
      username: admin
      password_ref: file://__BUNDLE_ROOT__/rack-password.txt
```

Do not commit real plaintext secrets in this directory.
