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
- For cross-system operational workflows, prefer directional names such as `<action>-<object>-to-<target>`.
- Focused leaf-workflow blueprints should use narrow action names.
- Reserve broader names such as `onboard-*` for true end-to-end orchestration flows.

7. Treat Jinja syntax as a first-class failure mode.
- Keep nontrivial payload shaping out of inline module arguments when possible.
- Prefer precomputed `set_fact` values or task-level `vars` for complex lists, nested dicts, and provider-specific normalization.
- Avoid fragile inline Jinja constructs such as list comprehensions mixed with filters, or `ternary` branches that index optional split elements.
- After editing Ansible YAML or Jinja-heavy payload builders, run `ansible-playbook --syntax-check` before considering the change done.

8. Simplify provider payload builders aggressively.
- If an Intersight or REST body starts accumulating conditional keys, split/parse logic, or nested combines, move that shaping into an explicit preparation step.
- Keep the module call focused on sending already-shaped data rather than computing it inline.
- Prefer one clear normalized variable such as `formatted_system_qos_classes` or `formatted_uplink_ports` over repeating shape logic inside each task.

9. Retry live Intersight reads explicitly.
- Treat `cisco.intersight.intersight_rest_api` lookups as transient-failure prone, especially for discovery, validation, and idempotent reruns.
- Use explicit Ansible task retries on read-heavy Intersight calls instead of assuming a single GET will be stable.
- Prefer a shared play-level retry contract such as `intersight_read_retry_count` and `intersight_read_retry_delay` so read retries stay consistent across phases.
- Quali's Intersight client code supports retry-aware patterns and many internal callers pass explicit retry counts for reads; mirror that style in repo playbooks rather than relying on one-shot API calls.
- As a default repo stance, retry transient read failures such as HTTP `500`, `502`, `503`, `504`, and usually `429`; do not paper over deterministic contract errors like `400`, `401`, `403`, or `404`.

## Repo Patterns
- Public Torque blueprint path:
  - `blueprints/claim-devices-to-intersight.yaml`
  - `blueprints/cisco-standalone-rack-reset-password.yaml`
- Reusable claim chain:
  - `prepare_claim_target_credentials`
  - `claim_devices_to_intersight`

## When To Use
- fixing blueprint load or resolution failures
- refining grain inputs and outputs
- making a playbook work both locally and in Torque
- deciding whether logic belongs in a blueprint, wrapper, or leaf grain
- stabilizing Jinja-heavy Ansible tasks that keep failing on parse or template-evaluation issues

## References
- [official-quali-guides.md](references/official-quali-guides.md)
- qTorque docs to consult first for blueprint/grain behavior:
  - [Blueprints Overview](https://docs.qtorque.io/blueprint-designer-guide/blueprints/blueprints-overview)
  - [The Ansible Grain](https://docs.qtorque.io/blueprint-designer-guide/blueprints/ansible-grain)
