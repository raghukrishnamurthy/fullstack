---
name: torque-catalog-designer
description: Create or update Torque/Quali catalog blueprints, grain chains, and user-facing input models for this repo's reusable Intersight automation.
---

# Torque Catalog Designer

## Purpose
Use this skill when shaping the Torque-facing user experience for this repo.

Focus on:
- stable blueprint input names
- clean grain topology in Torque
- minimal user-facing launch inputs
- clear mapping from form keys to grain inputs

## Design Rules
1. Blueprint topology should match the user story.
- Do not expose unrelated grains in a user-facing blueprint just because they exist in the repo.
- Prefer a focused chain over a technically valid but visually disconnected topology.

2. Prefer narrow, understandable inputs.
- Expose values the user actually chooses.
- Hide internal orchestration details behind the blueprint or wrapper.
- Prefer direct string/sensitive inputs or JSON-string contracts over YAML-shaped blueprint inputs, since Torque support for YAML-type blueprint inputs is currently unreliable.

3. Keep field names stable.
- Use `snake_case`.
- Avoid renaming once docs, blueprints, and grains depend on a key.

4. Model secrets as Torque inputs or credentials.
- Do not make end users think in `env://...` unless the environment truly works that way.
- If needed, map Torque inputs into env vars inside automation.

## Repo Patterns
- Public blueprint:
  - `blueprints/claim-intersight-devices.yaml`
- Wiring map:
  - `wiring-table.md`
- Example launch inputs:
  - `blueprint_test_inputs.md`

## When To Use
- designing or cleaning up blueprint inputs
- aligning form keys with Ansible contracts
- simplifying user-facing Torque flows
- deciding what belongs in blueprint UX versus internal orchestration

## References
- [official-quali-guides.md](references/official-quali-guides.md)
- qTorque docs to consult first for user-facing blueprint design:
  - [Blueprint Quickstart / Design](https://docs.qtorque.io/blueprint-designer-guide/blueprint-quickstart-guide)
  - [Blueprints Overview](https://docs.qtorque.io/blueprint-designer-guide/blueprints/blueprints-overview)
