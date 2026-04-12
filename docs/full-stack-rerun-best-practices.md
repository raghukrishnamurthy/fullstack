# Full-Stack Rerun Best Practices

This note captures the practical rules that came out of repeated full-stack
reruns across onboarding, network, domain validation, and resource phases.

Use it when:

- hardening an existing phase for idempotent reruns
- cleaning up a phase after rerun stability is reached
- starting a new phase such as Server Profile provisioning
- reviewing Intersight-backed realization and validator behavior

## Why This Exists

The full-stack blueprint can progress deeper into the chain only when every
upstream phase survives reruns with the same inputs.

That means this repo should optimize for:

- rerun safety before cleanup
- durable-state validation before summary-only validation
- stable phase contracts before convenience refactors

## Rules From Full-Stack Runs

### 1. Treat rerun survival as a design requirement

Do not consider a phase done just because the first apply succeeded.

A phase is only stable when:

- discovery can rerun safely
- realization updates only on real drift
- validators can rerun repeatedly
- the full stack can pass through the phase more than once

### 2. Prefer collection paths plus stable filters for `intersight_rest_api`

When using `cisco.intersight.intersight_rest_api`, prefer:

- collection `resource_path`
- stable `$filter` identity such as `Name` plus organization scope

Use this pattern for both create and update flows unless the specific endpoint
is already proven to require instance-path patching in the target runtime.

Why:

- some endpoints in real runs duplicated the Moid when the playbook appended it
  into `resource_path`
- the module then built invalid URLs such as `<collection>/<moid>/<moid>`
- collection path plus filter proved safer across repeated reruns

Observed examples from the network phase:

- `ntp.Policy`
- `networkconfig.Policy`

### 3. Do not generalize one endpoint's behavior to all endpoints

Different Intersight resource families may behave differently through the same
module.

When a path pattern works for one object family, do not assume it is correct for:

- another REST endpoint
- another resource collection
- another update mode

Document proven endpoint behavior as you go.

### 4. Re-read durable state before deciding to mutate

Every realization grain should re-read live Intersight state before deciding to:

- create
- patch
- deploy
- associate

Do not rely only on:

- prior in-memory facts
- upstream phase summaries
- assumptions from a previous run

### 5. Keep provider identity local to the phase

Do not make downstream phases depend on raw provider identifiers unless there is
no safe alternative.

Prefer cross-phase handoff contracts based on:

- stable names
- model ids
- selection ids
- validator summaries

Later phases should look up provider details again when needed.

### 6. Make the validator the only completion authority

Intermediate grains may discover or summarize readiness-like facts, but the
phase blueprint should only publish final completion through its validator grain.

The validator should own:

- `phase_ready`
- `phase_status`
- `phase_readiness_json`
- final summary outputs
- TAC or downstream handoff outputs

### 7. Validators should validate, not only repackage

A validator grain is stronger when it:

- re-reads durable live state
- checks readiness against real provider state
- fails visibly when the final contract cannot be exported

A validator that only repackages upstream facts is weaker and should be called
out explicitly.

### 8. Retry live reads, not contract errors

Use explicit retries for transient Intersight read behavior such as:

- `429`
- `500`
- `502`
- `503`
- `504`

Do not bury hard contract errors such as:

- `400`
- `401`
- `403`
- `404`

Those should fail fast and drive code or input cleanup.

### 9. Cleanup comes after rerun stability

When a phase is still failing on reruns, prefer targeted fixes over structural
cleanup.

Recommended order:

1. make reruns stable
2. simplify grain boundaries and contracts
3. rerun the full stack again

This reduces the chance of refactoring away evidence while real rerun bugs are
still surfacing.

### 10. Start new phases from proven patterns

New phases such as Server Profile provisioning should start with the same rules:

- resolve model first
- discover live state second
- realize only on meaningful drift
- end with one validator grain
- use stable identity lookups
- design for reruns from the first implementation

## Recommended Review Checklist

Before promoting a phase or starting the next phase, ask:

1. Can the phase pass a full rerun with the same inputs?
2. Are live reads retried explicitly?
3. Are update paths using a proven REST path pattern for that endpoint family?
4. Does the validator own the final phase contract?
5. Are downstream phases depending on stable contracts instead of provider-only ids?
6. Is cleanup being done after, not before, rerun stability?

## Related Docs

- [Phase Authoring Standards](./phase-authoring-standards.md)
- [Phase Validator Steps](./phase-validator-steps.md)
- [Infrastructure Stack](./infrastructure-stack-architecture.md)
