---
name: torque-ready-ansible
description: Use when building, reviewing, refactoring, or troubleshooting Ansible playbooks and Torque blueprints that must run cleanly in Quali Torque/qTorque for this repo's grain and blueprint patterns.
---

# Torque-Ready Ansible

## Purpose
Use this skill for Torque-facing Ansible work in this repo.

It is optimized for:
- `ansible/<grain-name>/playbook.yaml` grain layout
- top-level `blueprints/`
- scalar `depends-on`
- `torque.collections.export_torque_outputs`
- reusable leaf grains plus a thin blueprint or wrapper orchestrator
- Cisco Intersight appliance and SaaS claim workflows

## Working Rules
1. Keep reusable grains narrow.
- Leaf grains should accept only the data they truly need.
- Broad shaping, credential mapping, or launch-form convenience belongs in a wrapper or blueprint.
- Prefer user-facing input normalization in the wrapper/blueprint layer so the same execution grain can be reused from Torque, direct Ansible, or future Tower/AAP orchestrators.

2. Let Torque own runtime inputs.
- Torque passes grain inputs as extra-vars.
- Do not assume a static inventory file or pre-existing shell environment.
- Avoid YAML-shaped blueprint inputs in Torque-facing designs; current Quali guidance indicates YAML-type blueprint inputs are not supported, so prefer direct scalar inputs or JSON strings and assemble internal YAML only inside automation when necessary.

3. Model secrets in Torque-native ways.
- Prefer blueprint params, inputs, or credentials for secrets.
- Convert resolved inputs into runtime env vars only inside a wrapper when a downstream helper explicitly expects env-backed values.

4. Keep blueprint wiring conservative.
- Use scalar `depends-on: grain_name`.
- Any `{{ .grains.<grain>.outputs.<key> }}` reference must come from a grain on the active dependency chain.
- Avoid blueprint-side `if/else` templating when a grain can self-route or no-op.

5. Export stable outputs only.
- Export the minimum contract downstream grains need.
- Keep output names stable once other grains or blueprint outputs depend on them.

6. Keep blueprint names aligned to scope.
- Use descriptive `kebab-case` names under `blueprints/`.
- Focused leaf-workflow blueprints should use narrow action names.
- Reserve broader names such as `onboard-*` for true end-to-end orchestration flows.

## Repo Patterns
- Public Torque blueprint path:
  - `blueprints/claim-intersight-devices.yaml`
  - `blueprints/cisco-standalone-rack-reset-password.yaml`
- Reusable claim chain:
  - `prepare_intersight_context`
  - `resolve_claim_target_credentials`
  - `claim_intersight_devices`

## When To Use
- fixing blueprint load or resolution failures
- refining grain inputs and outputs
- making a playbook work both locally and in Torque
- deciding whether logic belongs in a blueprint, wrapper, or leaf grain

## References
- [official-quali-guides.md](references/official-quali-guides.md)
- qTorque docs to consult first for blueprint/grain behavior:
  - [Blueprints Overview](https://docs.qtorque.io/blueprint-designer-guide/blueprints/blueprints-overview)
  - [The Ansible Grain](https://docs.qtorque.io/blueprint-designer-guide/blueprints/ansible-grain)
