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
