# Inputs Model

## Purpose

Define the current customer-facing and automation-facing input contract for Jarvis Intersight onboarding.

This document describes:

- the stable input wrappers used by blueprint launches and local YAML examples
- the difference between broad orchestration inputs and narrow reusable-grain inputs
- the current claim flow split across Intersight SaaS, appliance/PVA, and supporting grains

## Current Architecture

The implementation now has two layers of contract:

- broad orchestration inputs
  Used by the top-level Intersight model grain. Inventory-first and solution-aware.
- narrow reusable-grain inputs
  Used by standalone grains such as context creation, claim, reset, and result normalization.

### Grain Map

| Grain | Purpose | Input Style |
| --- | --- | --- |
| `resolve-intersight-deployment-model` | Normalize deployment, platform, placement, site, inventory, solution, baseline, and readiness | Broad wrapped model inputs |
| `render-intersight-deployment-summary` | Render summary artifacts from the resolved model | Broad model outputs |
| `ensure-intersight-context` | Ensure the requested Intersight organization exists | Narrow direct inputs |
| `claim-to-saas` | Claim one or more targets into Intersight SaaS | Narrow direct inputs |
| `claim-to-appliance` | Claim one or more targets into appliance/PVA | Narrow direct inputs |
| `normalize-claim-results` | Merge backend-specific claim results into one output | Narrow result inputs |
| `reset-rack-password` | Reset IMC rack password from manufacturing to desired state | Narrow endpoint-reset inputs |

## Input Design Principles

- keep physical facts separate from higher-level intent
- keep platform-management endpoints separate from infrastructure inventory
- keep customer-facing launch inputs simpler than automation execution inputs
- use stable file and wrapper conventions for broad orchestration inputs
- prefer narrow noun-based contracts for reusable grains
- avoid action-opinion-based names like `prepared_*` or `ready_*` in reusable grain interfaces

## Input File Wrapper Convention

Each broad input file uses a single top-level wrapper key matching its domain name.

Examples:

- `deployment.yaml` -> `deployment:`
- `platform.yaml` -> `platform:`
- `placement.yaml` -> `placement:`
- `inventory.yaml` -> `inventory:`
- `solution.yaml` -> `solution:`
- `overrides.yaml` -> `overrides:`

### Example Wrappers

```yaml
deployment:
  id: sjc01-ai-prod
  site: sjc01
  environment: production
```

```yaml
platform:
  intersight:
    endpoint: https://intersight.com/api/v1
```

```yaml
placement:
  intersight:
    organization: ai-prod
```

```yaml
inventory:
  devices:
    - id: node-01
      category: server
      serial: ABC123
```

```yaml
solution:
  profile: secure_ai_factory
  delivery_scope: onboarding
```

## Broad Orchestration Input Domains

The current top-level model grain accepts these broad wrapped inputs:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `site_yaml`
- `inventory_yaml`
- `solution_yaml`
- `credential_candidates_yaml`
- `overrides_yaml`
- `baseline_input_source`
- `baseline_directory`
- `validation_mode`
- `execution_intent`

These are primarily consumed by:

- `resolve-intersight-deployment-model`

### Domain Summary

| Domain | Purpose | Typical Fields |
| --- | --- | --- |
| `deployment` | Define deployment boundary | `id`, `site`, `environment` |
| `platform` | Define management-plane and control-plane context | endpoint, API credential refs, assists, validate-certs |
| `placement` | Define where inventory lands inside Intersight | organization, resource group, reuse policy |
| `site` | Define site-scoped operational defaults | location, DNS, NTP, proxy |
| `inventory` | Define physical infrastructure facts | device ID, serial, category, mgmt IP, domains |
| `solution` | Define intended deployment profile and scope | profile, extension, goal, delivery scope |
| `credential_candidates` | Define candidate endpoint credentials | role, target category, narrowing, username, password ref |
| `overrides` / baseline inputs | Define customer-specific deltas | baseline source, directory, overrides YAML |

### Credential Candidate Roles Used Today

- `target`
- `manufacturing`

### Baseline Precedence

1. built-in baseline
2. customer baseline
3. overrides

## Reusable Grain Inputs

Reusable grains should not depend on the whole broad model unless necessary.

### Shared Context Grain

`ensure-intersight-context` currently takes:

- `platform_yaml`
- optional `organization`
- optional `placement_yaml`

Behavior:

- use direct `organization` when provided
- otherwise fall back to `placement.intersight.organization`
- ensure the organization exists in the active Intersight backend

### Shared Claim Target Contract

Current reusable claim grains use a single input name:

- `claim_targets_json`

This is a JSON string containing the target list for the active claim backend.

The blueprint exposes only one `claim_targets_json` input.

Backend selection is derived from the Intersight endpoint in `platform_yaml`:

- SaaS endpoint -> `claim-to-saas`
- appliance/PVA endpoint -> `claim-to-appliance`

The inactive backend grain receives `[]`.

### Reusable Grain Input Summary

| Grain | Required Inputs | Optional Inputs |
| --- | --- | --- |
| `ensure-intersight-context` | `platform_yaml` | `organization`, `placement_yaml` |
| `claim-to-saas` | `claim_targets_json`, `platform_yaml` | `deployment_yaml`, `organization`, `placement_yaml`, `credential_candidates_yaml`, `desired_credentials_json` |
| `claim-to-appliance` | `claim_targets_json`, `platform_yaml` | `deployment_yaml`, `organization`, `placement_yaml` |
| `normalize-claim-results` | `appliance_claim_results_json`, `saas_claim_results_json` | none |
| `reset-rack-password` | inventory-style rack and credential inputs | implementation-specific validation knobs |

### Claim-to-SaaS Rules

- endpoint claim readiness is refreshed inline during claim
- cached claim tokens should not be treated as durable execution inputs
- organization comes from direct input first, placement second

### Claim-to-Appliance Rules

- submission goes to `/appliance/DeviceClaims`
- workflow and `DeviceClaims` follow-up happens in one aggregate pass after all submissions

### Reset-Rack-Password Rules

`reset-rack-password` remains separate from the main claim flow.

It is responsible for:

- selecting IMC rack targets
- attempting manufacturing credential login
- resetting to the desired credential when required
- verifying the desired credential

It should be treated as a separate lifecycle step before prepare-and-claim, not as part of the main claim grain.

## Platform Rules

- keep platform context separate from inventory
- use references for credentials where possible
- derive SaaS versus appliance behavior from the Intersight endpoint
- PVA/appliance endpoints normalize internally to `/api/v1` when needed
- sandbox appliance testing may keep `validate_certs: false` hidden from customer-facing blueprint inputs

## Placement Rules

- `organization` is the main placement primitive currently used by reusable claim and context grains
- `resource_group` remains placement-specific and optional
- if `resource_group` is omitted, automation may use `organization`
- placement remains useful at orchestration level even when reusable grains take direct `organization`

## Inventory Rules

- keep inventory factual
- keep categories broad and stable
- keep solution meaning out of inventory
- use attributes for specialization
- do not mix management-plane platform data into inventory

### Allowed Categories

- `fabric_interconnect`
- `server`
- `storage`
- `ethernet_switch`
- `san_switch`

### Device Expectations

- FI-managed blades may omit `mgmt_ip`
- standalone rack servers should include `mgmt_ip`
- FI pair domains should be declared in `inventory.domains`
- for appliance claim purposes, a declared `fi_pair` is treated as one FI claim unit

## Blueprint-Level Current Inputs

The current blueprint still supports the broad orchestration flow and the reusable claim flow side by side.

### Current Blueprint Inputs

| Input | Purpose |
| --- | --- |
| `deployment_yaml` | Deployment boundary |
| `platform_yaml` | Intersight backend and API context |
| `placement_yaml` | Placement and organization defaults |
| `site_yaml` | Site-scoped operational defaults |
| `inventory_yaml` | Physical infrastructure facts |
| `solution_yaml` | Solution profile and delivery scope |
| `credential_candidates_yaml` | Endpoint credential candidates |
| `organization` | Direct organization input for reusable context/claim grains |
| `claim_targets_json` | Narrow target contract for the active claim backend |
| `validation_mode` | Strict vs live validation |
| `execution_intent` | Validate-only vs apply |

## Current Output Shapes

### Broad Model Outputs

Produced by `resolve-intersight-deployment-model`:

- `discovery_model_json`
- `discovery_summary_json`

Produced by `render-intersight-deployment-summary`:

- `discovery_report_json`
- `discovery_summary_markdown`

### Context and Claim Outputs

Produced by `ensure-intersight-context`:

- `context_result_json`

Produced by `claim-to-appliance`:

- `results_json`
- backend-specific counts and `batch_status`

Produced by `claim-to-saas`:

- `results_json`
- backend-specific counts and `batch_status`

Produced by `normalize-claim-results`:

- `normalized_claim_results_json`
- normalized summary counts and batch status

## Current Flow Summary

The current practical flow is:

1. resolve Intersight deployment model
2. render deployment/discovery summary
3. ensure Intersight organization context
4. run exactly one claim backend
   - SaaS or appliance/PVA
5. normalize claim results

Rack password reset remains intentionally separate and should run before claim when factory-default rack credentials are still present.

## Naming Conventions

### Grain Folder Names

Use `kebab-case`.

Examples:

- `resolve-intersight-deployment-model`
- `render-intersight-deployment-summary`
- `ensure-intersight-context`
- `claim-to-saas`
- `claim-to-appliance`
- `normalize-claim-results`
- `reset-rack-password`

### Blueprint Grain IDs

Use `snake_case`.

Examples:

- `resolve_intersight_deployment_model`
- `render_intersight_deployment_summary`
- `ensure_intersight_context`
- `claim_to_saas`
- `claim_to_appliance`
- `normalize_claim_results`

### Contract Naming

Prefer noun-based, reusable names.

Examples:

- `claim_targets_json`
- `results_json`
- `normalized_claim_results_json`

Avoid older action-biased names in reusable grain contracts such as:

- `prepared_targets_json`
- `ready_targets_json`

## Notes

- the current implementation is intentionally Intersight-specific
- backend-specific claim behavior lives in separate grains
- broad orchestration and narrow reusable-grain contracts now coexist by design
- documentation should prefer the current grain split over the earlier monolithic claim model
