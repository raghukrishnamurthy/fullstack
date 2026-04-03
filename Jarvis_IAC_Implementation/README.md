# Jarvis IAC Torque Scaffold

This directory contains a Torque-ready scaffold derived from the v2 Jarvis IAC architecture and input model.

The current implementation focus is the first infrastructure slice:

1. Collect deployment, platform, placement, site, and inventory inputs
2. Normalize and validate infrastructure devices
3. Optionally validate declared serials against Cisco Intersight
4. Derive infrastructure classification from device facts and topology
5. Render a discovery summary artifact for downstream workflows

Current offering shape:

- offering type: `custom`
- platform focus: Cisco Intersight and Cisco infrastructure onboarding
- automation shape: multi-grain Ansible blueprint
- reference conventions: aligned to `/Users/rkrishn2/intersightztp`

Files:

- `blueprint.yaml`
  Torque `spec_version: 2` blueprint
- `catalog_ui.md`
  End-user workflow and stable form keys
- `wiring-table.md`
  Form key to grain input mapping
- `ansible/resolve-deployment-model/`
  Validates inventory, normalizes devices, and derives infrastructure classification
- `ansible/render-master-plan/`
  Produces a discovery summary from the derived infrastructure view

Assumptions:

- Torque launch-form complex inputs are passed as strings
- YAML-shaped customer data is supplied as multiline string inputs
- `site_yaml` is optional and carries site-scoped operational defaults such as location, DNS, NTP, and proxy settings
- `validation_mode: strict` validates the input contract only
- `validation_mode: live` resolves env-based Intersight credential refs and queries Cisco Intersight for declared serials
- live mode also evaluates placement targets in Intersight and reports whether the requested organization/resource group would be reused, created, or would conflict with placement policy
- This scaffold does not yet claim devices or mutate Intersight resources
- Explicit no-op destroy flows are included to match the reference repo pattern
