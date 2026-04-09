# Intersight Authoring Guidelines

This note captures the current repo conventions for Cisco Intersight-backed grains, playbooks, and blueprint-facing contracts.

## Purpose

Use these rules when adding or changing:

- Intersight realization grains
- policy payload builders
- discovery or validation tasks that read live Intersight state
- model-to-provider normalization logic

## Core Rules

1. Treat Intersight as the source of truth for live state.
2. Keep customer-facing model contracts stable unless we are intentionally versioning that contract.
3. Normalize at the provider boundary when the internal model and Intersight schema differ.
4. Do not pass provider-only runtime identifiers such as organization Moids across blueprint phases when the downstream phase can look them up directly.
5. Prefer one shared normalization path per provider shape instead of repeating ad hoc field mapping in multiple grains.

## What To Store In The Model

The model should stay customer-oriented and export-friendly.

Good model fields:

- `name`
- `admin_state`
- `weight`
- `preferred_ipv4_dns_server`
- `selected_policies`

Avoid making the source model look like raw Intersight export payloads unless that is an explicit product decision.

Reason:

- customers may author values directly
- customers may export values and compare them later
- provider-specific field names leak implementation details into the customer contract

## When To Normalize To Intersight

Normalize when either of these is true:

- Intersight expects a different field name or nested structure
- Intersight requires fields or defaults that are not part of the customer-facing model

Examples:

- `name` -> `Name`
- `admin_state` -> `AdminState`
- sparse QoS class model -> full `fabric.SystemQosPolicy.Classes` payload

This normalization should happen as close as possible to the REST or module call that needs the provider shape.

## Create Vs Patch Rules

When realizing objects in Intersight:

1. Look up the existing object by stable identity such as `Name` plus organization scope.
2. If it does not exist, create it on the collection resource path and include required creation relationships such as `Organization`.
3. If it exists, patch the object on its instance resource path using its Moid.
4. Do not include read-only relationships like `Organization` in patch bodies.

This prevents failures like:

- read-only relationship errors during patch
- ambiguous updates against collection endpoints

## Payload Construction Rules

When building API bodies:

- prefer explicit normalization facts for complex payloads
- avoid relying on Jinja `ternary` when one branch indexes into optional data
- use short-circuiting conditional expressions for optional keys
- keep provider defaults in one place when possible

Examples of risky patterns:

- splitting `port_id` and indexing `[1]` inside a `ternary`
- mixing model-shaped keys and provider-shaped keys in the same payload

## When To Read Live Intersight State

Read live state when:

- validating that a target org, policy, or profile exists
- resolving Moids needed for a mutation
- checking whether an object already exists before choosing create vs patch
- confirming device or FI model details that affect the module path or supported realization logic

Do not invent or cache live values in blueprint outputs unless there is a strong reason and the downstream stage cannot safely look them up again.

## Retry Rules For Live Intersight Reads

Live Intersight reads are not perfectly stable during discovery, validation, or idempotent reruns.

Repo rule:

1. Add explicit retries around `cisco.intersight.intersight_rest_api` read tasks that query existing live state.
2. Keep the retry contract consistent within a playbook by defining shared values such as:
   - `intersight_read_retry_count`
   - `intersight_read_retry_delay`
3. Apply those values to lookups for:
   - organizations
   - fabric interconnects
   - chassis
   - policies
   - profiles
   - other live inventory or validation reads
4. Do not stop after hardening the first read in a playbook. Follow-on live lookups in the same phase should use the same retry contract unless there is a clear reason not to.
5. Prefer retrying transient upstream failures such as:
   - HTTP `500`
   - HTTP `502`
   - HTTP `503`
   - HTTP `504`
   - usually HTTP `429`
6. Do not use retries to hide deterministic authoring or contract problems such as:
   - HTTP `400`
   - HTTP `401`
   - HTTP `403`
   - HTTP `404`

Reason:

- Quali's Intersight codebase has retry-aware client plumbing and many internal callers pass explicit retry counts for read operations.
- In this repo, explicit playbook retries are the clearest and safest way to make idempotent read paths resilient without obscuring true schema or payload defects.

## Full Idempotent Run Rules

Every Intersight-backed phase should be authored with full reruns in mind.

## Validator Grain Standard

Each phase blueprint should end with a validator grain.

That validator grain is the phase completion authority and should:

1. re-read durable Intersight state
2. decide `ready` versus `not ready`
3. publish the stable phase summary outputs
4. publish the downstream handoff contract

The validator grain should be the canonical end-of-phase signal that later blueprints depend on.

Validator export rule:

- if the validator owns `phase_ready`, `phase_status`, and final handoff JSON, its export path should be treated as required
- avoid `ignore_errors: true` on the final validator export unless there is a separately enforced failure path

Repo expectation:

1. A second full run with the same inputs should complete successfully across discovery, realization, deployment, validation, and summary phases.
2. Read-heavy phases should tolerate transient upstream instability with explicit retries rather than failing on the first `500 Retry later` response.
3. Realization phases should re-read live state, compare by stable identity, and only mutate when live state truly differs from desired state.
4. Validation and summary phases should be safe to rerun repeatedly and should not depend on ephemeral outputs from previous runs when they can re-read durable state from Intersight.
5. The validator grain is the official completion authority, but the full phase chain still needs to rerun cleanly before that validator is reached.

When reviewing idempotency, pay special attention to:

- repeated `changed` results on pure lookup or validation tasks
- create tasks that should have fallen back to patch or no-op behavior
- deployment actions that trigger again even though the final state is already terminal and clean
- worker bootstrap tasks that mutate the runtime on every execution
- transient Intersight read failures that should have been retried
- validators that declare success while relying only on prior in-memory artifacts instead of re-checking durable state where practical

Preferred authoring pattern:

1. validate inputs
2. read live state with retries
3. derive normalized desired payloads
4. compare live versus desired using stable identities and meaningful fields
5. mutate only when needed
6. validate terminal state
7. export stable summaries

## Recommended Authoring Flow

1. Validate user/model inputs.
2. Derive local facts from the canonical model.
3. Read the minimum live Intersight state needed for safe execution.
4. Build normalized provider payloads.
5. Look up existing objects by stable identity.
6. Create or patch using the correct resource path.
7. Export only stable downstream outputs.

## Use This Guidance When

- adding a new Intersight-backed grain
- fixing provider-schema mismatches
- deciding whether a field belongs in the model or only in the provider adapter
- reviewing whether a grain is leaking too much provider detail into user-facing contracts

## Do Not Use This As An Excuse To

- rewrite existing customer contracts casually
- pass Moids through multiple grains just to save one lookup
- normalize differently in every playbook
- patch collection endpoints with create-only or read-only relationships in the body
