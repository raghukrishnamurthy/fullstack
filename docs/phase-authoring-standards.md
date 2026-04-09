# Phase Authoring Standards

This note captures the authoring standard that should apply across all
infrastructure phases, not only onboarding or network provisioning.

Use it when designing or reviewing:

- onboarding phases
- network provisioning phases
- resource provisioning phases
- validator-only or post-validation phases
- higher-level stack orchestration that composes those phases

## Scope

These standards apply across the current phase model:

1. `infrastructure-onboard-devices`
2. `infrastructure-network-provisioning`
3. `infrastructure-resource-provisioning`
4. `infrastructure-domain-post-validation`
5. future infrastructure phases added to the same stack model

## Coding Style

Phase automation should favor clarity over cleverness.

Rules:

- keep playbooks readable and linear
- prefer explicit local facts over deeply nested inline expressions
- keep names stable and descriptive
- isolate provider-specific shaping from customer-facing model fields
- avoid repeating the same normalization logic in multiple tasks
- treat large Jinja expressions as a smell and move them into preparation steps

Preferred patterns:

- `set_fact` or task-level `vars` for shaped payloads
- one normalized variable per provider payload shape
- one shared `api_info` anchor for Intersight connection parameters
- short, phase-specific summaries rather than giant transient payloads

Avoid:

- inline list comprehensions in module arguments
- `ternary` expressions that index optional split values
- mixing customer-model keys and raw Intersight keys in the same structure

## Torque-Ready Ansible Standard

All phase automation should remain Torque-ready.

Rules:

- keep grains under `ansible/<grain-name>/playbook.yaml`
- keep blueprint wiring conservative
- use scalar `depends-on`
- export only stable downstream outputs
- avoid fragile blueprint-side conditional routing when a grain can no-op safely
- keep launch-form contracts simple and JSON-first where complex structures are needed

Phase blueprint pattern:

1. resolve or normalize inputs
2. discover or validate current state
3. realize or deploy only when needed
4. run a validator grain at the end

The validator grain is the completion authority for the phase.

Validator-authority rules:

- validator export tasks should not ignore failure when publishing the final phase contract
- `phase_ready`, `phase_status`, and validator-owned JSON outputs should be treated as required outputs, not best-effort outputs

## Python Documentation Standard

Python used in helpers, embedded validation blocks, or supporting scripts should
be documented like operational code, not disposable glue.

Rules:

- add a short module-level purpose when the file is not self-evident
- document non-obvious helper functions with concise docstrings
- explain inputs and outputs when a helper shapes or validates data contracts
- document retry behavior, polling behavior, and failure semantics when they are important
- prefer short comments explaining why a rule exists, not what a line does

For phase-facing scripts and helpers, the docs should make it clear:

- what the script validates or mutates
- what inputs it expects
- what outputs or files it produces
- whether it is safe for reruns

## Intersight Best Practices

Intersight is the durable operational source of truth for these phases.

Rules:

- re-read current Intersight state before deciding whether to mutate
- use stable identity for lookups, such as `Name` plus organization scope
- create on collection paths and patch on instance paths
- do not patch read-only relationships such as `Organization`
- normalize to provider shape at the boundary to the REST or module call
- do not pass provider-only Moids across phases when later phases can look them up directly

Read-path rules:

- add explicit retries around Intersight reads
- keep shared retry vars such as:
  - `intersight_read_retry_count`
  - `intersight_read_retry_delay`
- apply the retry contract consistently to all live lookup stages in the playbook, not only the first organization or inventory read
- treat `500`, `502`, `503`, `504`, and usually `429` as transient read failures
- do not hide `400`, `401`, `403`, or `404` with broad retry loops

## Idempotency Standard

Every phase should be safe for full reruns with the same inputs.

That means:

- discovery should be safe to rerun
- realization should only mutate on real drift
- deployment should not retrigger unnecessarily
- validation should be safe to rerun repeatedly
- summary outputs should reflect durable state, not only in-memory prior-task state

Things to treat as idempotency bugs:

- repeated `changed` on pure lookups
- repeated deployment actions after terminal success
- worker bootstrap steps that mutate the environment every run
- read failures caused by missing retries on transient Intersight responses
- validator grains that can succeed locally while silently failing to export the final Torque contract

## Validator Grain Standard

Each phase blueprint should end with a validator grain.

That validator grain should:

1. re-read durable state or consume the final durable phase evidence
2. decide `ready` versus `not ready`
3. publish `phase_ready` and `phase_status`
4. publish stable summary and handoff outputs

The validator grain is the official completion authority for the phase.

Earlier grains still need to be rerun-safe. A correct validator pattern does not
replace the need for idempotent discovery and realization.

Preferred validator behavior:

- re-read durable live state when the final readiness decision depends on mutable provider state
- avoid making the validator a pure repackaging step when a direct live check is practical
- fail visibly if the final contract cannot be exported

## Documentation Standard For Each Phase

Each phase should document:

1. phase purpose and boundary
2. what belongs in scope and what does not
3. expected input contracts
4. source-of-truth rules
5. realization behavior
6. validator grain and validator steps
7. output contract
8. rerun and idempotency expectations

At minimum, each phase should have:

- an architecture doc
- a validator description
- a blueprint wiring reference or equivalent grain sequence note

## Review Checklist

When reviewing a phase, check:

1. Is the customer-facing model still stable and provider-neutral?
2. Is the Intersight shaping isolated to clear preparation steps?
3. Are Intersight reads retried explicitly?
4. Does the blueprint end with a validator grain?
5. Does the validator own `phase_ready` and `phase_status`?
6. Can the full phase rerun with the same inputs?
7. Is the phase documentation clear about scope, validator checks, and outputs?
