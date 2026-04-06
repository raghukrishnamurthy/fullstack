# Infrastructure Scan Blueprint Architecture

## Goal

Define a new infrastructure scan blueprint that minimizes hand-authored JSON
inputs and uses the encrypted device secret bundle as the primary source of
device-side credentials.

This document is intentionally about a standalone blueprint, not a runtime mode
inside the existing structured onboarding blueprint.

The scan blueprint should:

- accept a small set of seed inputs
- discover and classify reachable infrastructure targets
- rotate through bundle-backed credentials where needed
- generate normalized inventory data internally
- reuse the existing downstream onboarding and claim grains
- build generated inventory for downstream onboarding

This is intentionally different from the current structured onboarding blueprint,
which assumes the operator already knows the target inventory and can provide it
explicitly.

## Why A Separate Mode

The current structured onboarding flow works well when inventory intent is already
known, but it becomes operator-hostile when the user must handcraft multiple JSON
payloads just to get started.

The main pain points scan mode is intended to solve are:

- `inventory_json` is too detailed for first contact with an unknown environment
- `credential_candidates_json` is not a good primary UX for most operators
- the encrypted bundle should be the primary device-secret source of truth
- discovery confidence matters more than contract validation during the first pass
- the operator should not have to manually build the Intersight-ready target list
  before the system can attempt onboarding

Scan mode should therefore be modeled as a separate blueprint, not as a flag
inside the current structured onboarding blueprint.

Recommended blueprint identity:

- blueprint file: `blueprints/infrastructure-scan-and-onboard-devices.yaml`
- catalog label: `Infrastructure Scan And Onboard Devices`
- operating intent: discover broadly, then hand off the Intersight-ready target
  inventory into onboarding

## Blueprint Boundary

The new blueprint should own:

- scan-scope collection
- credential rotation against discovered endpoints
- discovery evidence and operator-facing reporting
- generated inventory construction
- handoff into the current onboarding grains
- direct and Assist-mediated discovery decisions
- generation of onboarding-ready inventory

The current `infrastructure-onboard-devices` blueprint should continue to own:

- explicit known-inventory onboarding
- advanced or deterministic operator-driven launches
- environments where the target inventory is already modeled externally

That split keeps both contracts understandable:

- structured blueprint for known inventory
- scan blueprint for low-input discovery and broad claim execution

## User Experience

The scan blueprint launch contract should stay small.

Recommended inputs:

- `deployment_json`
- `placement_json`
- `site_json`
- `api_uri`
- `intersight_api_key_id`
- `intersight_api_private_key`
- `scan_credentials_json`
- `encrypted_device_secret_bundle_path`
- `device_secret_bundle_key`
- `scan_targets_json`
- optional `claim_target_serials_json`
- `execution_intent`

Recommended `scan_targets_json` content:

- single endpoints
- IP ranges

Example shape:

```json
[
  {
    "type": "single",
    "endpoint": "10.29.135.101"
  },
  {
    "type": "range",
    "start_ip": "10.29.135.106",
    "end_ip": "10.29.135.109"
  }
]
```

Optional advanced scan-shaping input:

- `scan_profile_json`

Recommended `scan_profile_json` content:

- platform hints
- scan timeout or concurrency settings
- explicit automation-time behavior toggles

Example shape:

```yaml
scan_profile:
  platform_hints:
    scan_fabric_interconnects: true
    scan_rack_servers: true
    scan_assist: true
    scan_storage: true
```

The operator should not need to provide:

- full `inventory_json`
- direct inline passwords
- separate `credential_candidates_json` for normal use

The generated inventory and generated claim plan should be internal to the
blueprint unless the operator explicitly chooses an export-oriented
discover-only workflow.

Optional customer-facing scope selector:

- `claim_target_serials_json`

Purpose:

- restrict claim execution to a known serial allow-list when the scanned
  infrastructure is broader than the intended onboarding scope

Example shape:

```json
[
  "FDO272406DE",
  "WZP270500PQ",
  "WZP270500PV"
]
```

## High-Level Flow

The scan blueprint should have two major phases:

1. discovery and normalization
2. onboarding execution from generated inventory

Proposed grain sequence:

1. `prepare_intersight_context`
2. `prepare_device_secret_bundle`
3. `scan_infrastructure_targets`
4. `build_generated_inventory_from_scan`
5. `build_infrastructure_onboarding_targets`
6. `prepare_claim_target_credentials`
7. `prepare_device_connector`
8. `split_claim_target_phases`
9. claim grains
10. merge and validation grains

This keeps the current onboarding implementation reusable while moving discovery
and inventory construction into dedicated scan blueprint grains.

## V1 Reuse Principle

V1 scan mode should not introduce a completely separate detection and target
classification stack if the current repo already has working build and
discovery-target logic for supported infrastructure types.

Recommended V1 implementation principle:

- reuse the existing `build-*` and discovery-target logic where possible
- add the missing scan-specific outer loop:
  - IP-block expansion
  - credential cycling
  - supported-target detection orchestration
  - generated inventory creation
- avoid forking target classification rules into a second incompatible model

This keeps V1 grounded in the current implementation and reduces the risk that
scan mode and onboarding drift apart in supported-target behavior.

## V1 Scope And Non-Goals

V1 scope:

- scan IP blocks and single endpoints
- use encrypted bundle-backed credentials
- detect supported direct Cisco target types
- build onboarding-ready generated inventory
- hand generated inventory into the existing infrastructure onboarding flow

V1 non-goals:

- external connector endpoint scanning
- a separate claim engine outside the existing onboarding flow
- a broad multi-vendor discovery framework
- customer-authored full inventory as a prerequisite for scan mode
- interactive correction loops or customer-choice inference during execution

## Discovery Boundary

Scan mode should not depend on external device-connector preparation as part of
discovery.

Recommended discovery rules:

- use direct endpoint access for FI and rack-style endpoints
- use direct endpoint access for Assist targets
- discover and model Assist-managed targets when a real discovery mechanism exists
- do not assume scan mode can always determine which Assist owns or reaches an
  Assist-managed target when multiple Assists exist
- allow Assist-mediated validation only after an Assist mapping is explicitly
  supplied or otherwise established by trustworthy evidence
- do not require pre-existing external connector preparation just to discover or
  model the environment

This keeps scan mode aligned to first-contact workflows where the operator may
have credentials, but does not yet have connector state prepared across the
environment.

Out of scope for scan-time inference:

- external connector endpoint scanning
- implicit determination of Assist-managed ownership in multi-Assist
  environments when discovery evidence is insufficient
- claiming that an Assist-managed target belongs to a specific Assist without
  explicit operator input or later control-plane evidence

## Proposed Blueprint Contract

Suggested top-level launch inputs:

- `deployment_json`
- `placement_json`
- `site_json`
- `api_uri`
- `intersight_api_key_id`
- `intersight_api_private_key`
- `scan_credentials_json`
- `encrypted_device_secret_bundle_path`
- `device_secret_bundle_key`
- `scan_targets_json`
- optional `claim_target_serials_json`
- `execution_intent`
- optional `scan_profile_json`
- optional `scan_overrides_json`

Suggested launch outputs:

- `discovered_targets_json`
- `discovery_report_json`
- `generated_inventory_json`
- `generated_inventory_yaml`
- optional `claim_plan_json`
- optional `claimable_targets_json`
- optional `blocked_targets_json`
- `batch_status`

The scan blueprint should hide the internal wiring to:

- `inventory_json`
- `credential_candidates_json`
- intermediate target lists
- claim target normalization outputs

Those artifacts should still exist internally, but they should be derived
products, not primary launch-time inputs.

Recommended output-contract principle:

- keep JSON only at the launch and export boundary
- convert discovery results into generated inventory early
- drive downstream grains from generated inventory rather than repeated
  hand-authored JSON payloads
- export stable aggregate outputs for Torque chaining and UI visibility

Recommended execution intents:

- `discover`
- `discover_and_claim`

The default scan blueprint intent should be `discover_and_claim`.

For `discover_and_claim`, the scan blueprint should hand generated inventory into
the existing onboarding chain. That downstream
chain continues to own:

- claim target derivation from inventory
- already-claimed handling
- conflict handling
- claim submission
- final aggregate claim status

## Proposed New Grains

### `scan-infrastructure-targets`

Purpose:

- probe the provided scope
- identify reachable devices
- try credential rotation using bundle-backed credentials
- prefer direct connectivity over external connector assumptions
- classify discovered devices into normalized candidate records

Expected outputs:

- `discovered_targets_json`
- `discovery_report_json`

`discovered_targets_json` should capture facts such as:

- endpoint
- reachable status
- probable platform or category
- serial if known
- hostname if known
- management type if known
- credential match result
- discovery evidence

`discovery_report_json` should capture operator-facing diagnostics such as:

- successful probes
- authentication failures
- unmatched endpoints
- ambiguous classifications
- suggested next actions
- claim eligibility by discovered target

Recommended structure:

- `discovered_targets_json`
  - normalized list of discovered targets and their evidence
- `discovery_report_json`
  - operator-facing summary with warnings, auth failures, ambiguous cases, and
    recommended follow-up actions

### `build-generated-inventory-from-scan`

Purpose:

- transform discovery output into the normalized inventory contract already expected
  by `build-infrastructure-onboarding-targets`
- assign stable internal ids
- infer relationships such as FI pairs
- preserve unresolved Assist-managed relationships when the scan evidence is
  ambiguous

Expected outputs:

- `inventory_yaml`
- `generated_inventory_json`
- optional `inventory_summary_json`
- optional `inventory_warnings_json`

This grain is the boundary between the scan-specific world and the existing
structured onboarding flow.

Recommended structure:

- `generated_inventory_json`
  - normalized inventory object suitable for downstream grains
- `generated_inventory_yaml`
  - same inventory rendered for debugging, export, or operator inspection
- `inventory_warnings_json`
  - unresolved relationships and follow-up actions

### `build-claim-plan-from-scan`

Purpose:

- optionally derive a preview claim plan from the generated inventory
- separate deterministic onboarding-ready inventory content from blocked or
  out-of-scope targets

Expected outputs:

- `claim_plan_json`
- `claimable_targets_json`
- `blocked_targets_json`

Recommended structure:

- `claim_plan_json`
  - optional preview of onboarding intent for all discovered relevant targets
- `claimable_targets_json`
  - optional subset of targets expected to become claimable after onboarding
    target derivation
- `blocked_targets_json`
  - subset of targets that require operator input, better evidence, or future
  capability

## Credential Strategy

Scan mode should treat the encrypted bundle as the primary credential source.

The intended precedence should be:

1. direct launch overrides, if explicitly provided for debugging
2. encrypted bundle content
3. optional explicit candidate input, only as an advanced escape hatch

Normal scan-mode runs should rely on the bundle alone.

The practical authentication model for scan mode should be:

- direct credentials for FI, rack, and Assist discovery
- Assist-mediated credentials or follow-on validation for Assist-managed targets
  where needed
- no dependency on externally prepared connector state for first-pass discovery

The practical execution model for scan mode should be:

- discover as much as possible from direct reachability and bundle-backed creds
- build generated inventory for every sufficiently modeled and eligible target
- hand off generated inventory into onboarding
- report but do not silently skip blocked targets

## Credential Set And Match Model

Scan mode should accept a list of credential candidates and determine which
credential matches which endpoint during discovery.

This is a core reason scan mode exists:

- the customer may know IP blocks
- the customer may know a candidate credential set
- the customer may not know which credential maps to which endpoint

So scan mode should discover:

- endpoint identity
- platform classification
- matched credential identity
- next lifecycle action

Customer-facing input:

- normal path: encrypted bundle inputs only
- advanced override path: `scan_credentials_json`

Intent:

- define the list of credential identities and usages to try during scan
- keep secret values in the encrypted device secret bundle
- allow automation to match credentials to endpoints without per-endpoint
  credential mapping at launch time

Recommended credential-entry fields:

- `id`
- `username`
- `password_ref`
- `usage`
- optional platform hints
- optional platform hints

Recommended match result fields per discovered target:

- `matched_credential_id`
- `matched_credential_role`
- `post_match_action`

Recommended `post_match_action` values:

- `claim_now`
- `reset_to_desired`
- `blocked`

Routing rules:

- if a `target` credential matches and the target is otherwise eligible, route
  toward claim
- if a `manufacturing` credential matches, route toward reset or normalization
- after successful reset, continue to claim preparation
- if no credential matches, mark the target `blocked`

## Scan Secret Bundle Contract

For v1, scan mode should keep the customer launch surface simple and source scan
passwords from the encrypted device secret bundle.

Preferred customer-facing inputs:

- `encrypted_device_secret_bundle_path`
- `device_secret_bundle_key`

The bundle should carry at least:

- `target` credentials used for normal direct login and claim preparation
- `manufacturing` credentials used by the onboarding reset path

Recommended internal shape:

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
```

Recommended direct-target behavior:

- use username `admin`
- try `target` credentials first
- if the target requires reset or normalization, try `manufacturing`
  credentials
- if a Cisco default password matches, route to reset
- after reset, continue into downstream onboarding

Recommended Cisco fallback rule:

- preferred: supply an explicit `manufacturing` credential in the bundle or
  override contract
- fallback: for the Cisco direct rack reset path only, if no manufacturing
  credential is present, assume the known default password `password`
- do not apply this fallback to vendor-managed or non-Cisco claim paths

Design intent:

- keep password lists out of normal launch-time JSON
- keep the customer contract simple
- allow the internal scan secret contract to expand later without changing the
  top-level blueprint surface

Important onboarding alignment:

- infrastructure onboarding already owns reset behavior today
- reset requires a manufacturing or default password to log in before the target
  password can be applied
- therefore the infra scan or onboarding bundle contract must model both
  `target` and `manufacturing` credentials explicitly

### Bundle Responsibilities

The bundle should hold:

- per-device credentials where known and stable
- global category credentials where appropriate
- Assist and storage credentials in addition to FI and rack/server credentials

Current lessons learned:

- serial-keyed `per_device` entries work well for FI and rack servers
- Assist and storage need category or management-type coverage unless the bundle
  contract is extended to support non-serial per-target identity keys

Recommended bundle contract coverage:

```yaml
device_credentials:
  globals:
    fabric_interconnect:
      username: admin
      password_ref: file://__BUNDLE_ROOT__/fi-password.txt
    server:
      username: admin
      password_ref: file://__BUNDLE_ROOT__/rack-password.txt
    assist:
      username: admin
      password_ref: file://__BUNDLE_ROOT__/assist-password.txt
    storage:
      username: pureuser
      password_ref: file://__BUNDLE_ROOT__/pure-password.txt
```

## Inventory Model Expectations

The generated inventory should continue to follow the structured inventory model
already used by the current onboarding flow.

Important design expectations:

- `assist.id` is an internal reference key
- `storage[*].assist` should reference that Assist `id`
- downstream code should resolve that internal reference to the appropriate Assist
  endpoint or record rather than treating it as an external display name

For scan mode specifically:

- Assist inventory can be discovered directly
- some Assist-managed targets may be discovered directly today
- additional Assist-managed discovery can be added as mechanisms mature
- the Assist relationship for a discovered Assist-managed target may remain
  unresolved after discovery
- unresolved Assist-managed mappings should be surfaced as operator action, not
  silently guessed

Recommended handling for ambiguous Assist-managed mappings:

- emit the discovered target in generated inventory
- emit an inventory warning indicating that the Assist relationship must be
  assigned
- block only the Assist-dependent claim path until that mapping exists

This means scan mode should still include in generated inventory everything else
it can:

- include FI targets when credentials and classification are good
- include rack targets when credentials and classification are good
- include Assist targets when credentials and classification are good
- include Assist-managed targets only when their Assist relationship is explicit
  enough to support a trustworthy onboarding path

This keeps the input contract stable and avoids brittle dependency on external
target names in Intersight.

## Scan Eligibility Policy

Scan mode should classify every discovered target into exactly one execution
bucket before inventory handoff begins.

Recommended buckets:

- `handoff_ready`
- `blocked`
- `unsupported`
- `out_of_scope`

Decision table:

| Bucket | Meaning | Typical conditions | Expected action |
| --- | --- | --- | --- |
| `handoff_ready` | Safe to include in generated inventory for downstream onboarding | recognized Intersight-supported type, matched credentials or reset path, required fields present, no unresolved dependency | include in generated inventory |
| `blocked` | Relevant target, but unsafe or incomplete to claim now | missing Assist mapping, ambiguous classification, missing required field, insufficient evidence, conflict | do not submit; surface exact reason |
| `unsupported` | Discovered target is outside current scan-mode claim capability | unsupported platform, unsupported workflow, unsupported claim path | do not submit; report unsupported state |
| `out_of_scope` | Discovered target is valid but not selected for this run | not in serial allow-list, excluded by deterministic automation filter | do not submit; report as intentionally skipped |

Recommended policy rules:

- scan mode should hand off only `handoff_ready` targets
- `blocked` should be explicit and actionable, never silent
- `unsupported` should be explicit and separate from `blocked`
- `out_of_scope` should be explicit and separate from both `blocked` and
  `unsupported`

Recommended batch status rules:

- `success` when usable generated inventory is produced for every eligible
  discovered target and the remaining targets are intentionally out of scope
- `partial_success` when usable generated inventory is produced for at least one
  target and at least one target is `blocked`, `unsupported`, or `out_of_scope`
- `failed` when no useful generated inventory is produced and the batch is
  stopped by errors or universal blockage

## Validation Behavior

Scan mode should not focus primarily on schema validation.

The useful question is not whether claim already succeeded, but whether scan
produced valid onboarding-ready inventory.

Validation should answer:

- what endpoints were scanned
- which credentials matched
- which devices were classified confidently
- which relationships were inferred
- which relationships remain unresolved
- whether valid generated inventory was created
- what needs operator intervention before retry

Recommended validation outputs:

- discovery summary by category
- auth failures by endpoint and credential family
- ambiguous matches
- generated inventory summary
- skipped or unsupported targets
- blocked targets with explicit reasons

Meaningful validation should report:

- what endpoints were scanned
- what devices were discovered
- what credentials matched
- what endpoints failed authentication
- what inventory objects were generated
- whether inventory is onboarding-ready
- what blockers remain before onboarding

Recommended validation outputs:

- `discovery_report_json`
- `generated_inventory_json` or `inventory_yaml`
- `onboarding_preview_json`

`execution_intent: validate` or `discover` should stop after reporting these
artifacts without making claim or onboarding mutations.

## Execution Modes

Recommended scan-mode intents:

- `discover`
  - run bundle prep, discovery, normalization, and reporting only
- `plan`
  - build discovery outputs and the derived onboarding preview
- `apply`
  - continue into the existing onboarding and claim grains

This gives operators a safe first pass before performing any mutation.

## Reuse Boundary

The existing onboarding grains should remain the system of record for:

- claim target construction
- credential finalization
- device connector preparation
- claim execution
- result merging
- final onboarding validation

Scan mode should add value before those grains, not replace them.

That keeps the implementation incremental and lowers regression risk.

## Tradeoffs

Benefits:

- much better first-run UX
- encrypted bundle becomes the normal secret path
- less manual JSON authoring
- better support for partial or unknown environments
- reuses the current working onboarding chain

Costs:

- new discovery logic and probe orchestration
- more complexity around credential rotation and classification
- need for stronger operator-facing reporting
- potential ambiguity when multiple credentials or device types match

## Recommended Implementation Path

1. Create the scan-mode architecture and blueprint contract.
2. Implement `scan-infrastructure-targets` with discovery-only outputs first.
3. Implement `build-scanned-inventory` to emit the existing inventory contract.
4. Reuse the current onboarding chain unchanged wherever possible.
5. Add richer reporting for discovery confidence, credential matches, and derived
   onboarding preview.

This sequence lets scan mode land incrementally while preserving the current
structured onboarding path.
