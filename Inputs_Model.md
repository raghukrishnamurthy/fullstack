# Inputs Model

## Purpose

Define the customer-facing and automation-facing input contract for the Cisco infrastructure onboarding and solution-profile model.

This document provides the stable input structure used by customer input files, catalog launch flows, and downstream automation.

## Input Design Principles

- keep physical facts separate from higher-level intent
- keep platform-management endpoints separate from infrastructure inventory
- keep solution role assignment separate from device classification
- keep delivery scope separate from both inventory facts and solution profile
- keep customer-facing launch inputs simpler than automation execution inputs
- use stable file and wrapper conventions across the model

## Input File Wrapper Convention

Each input file should use a single top-level wrapper key matching the domain name of the file.

Examples:

- `deployment.yaml` -> `deployment:`
- `platform.yaml` -> `platform:`
- `placement.yaml` -> `placement:`
- `inventory.yaml` -> `inventory:`
- `solution.yaml` -> `solution:`
- `pools.yaml` -> `pools:`
- `overrides.yaml` -> `overrides:`
- `references.yaml` -> `references:`

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
  extension: openshift
  delivery_scope: platform_provisioning
```

## Customer Input Domains

Customer-provided data should be organized into these domains:

- `deployment`
- `platform`
- `placement`
- `inventory`
- `pools`
- `solution`
- `overrides`
- `references`

### Deployment Domain

Defines the execution boundary.

Typical fields:

- deployment ID
- site
- environment
- optional customer or tenant metadata

### Platform Domain

Defines management-plane and control-plane context.

Typical fields:

- Intersight endpoint
- credential references
- Assist context
- SaaS or PVA control-plane behavior

### Placement Domain

Defines where discovered or declared inventory should land inside Intersight.

Typical fields:

- organization
- resource group
- reuse behavior for existing organization or resource group
- optional naming controls

### Inventory Domain

Defines physical infrastructure facts.

Typical fields:

- device ID
- serial number
- category
- management IP
- peer relationships
- parent relationships
- hardware attributes

### Pools Domain

Defines reusable allocatable resource references.

Typical fields:

- IP pool references
- MAC pool references
- UUID pool references
- WWPN pool references
- other resource pools when required

### Solution Domain

Defines the intended integrated deployment profile and optional higher-layer additions.

Typical fields:

- solution profile
- extension
- goal
- server assignments
- delivery scope
- optional solution-specific parameters

### Overrides Domain

Defines explicit customer exceptions.

### References Domain

Defines pointers to customer-managed or externally hosted values.

## Deployment Input Contract

The deployment contract defines the deployment scope without encoding infrastructure classification, solution profile, extension, or delivery behavior.

### Required Fields

- `deployment.id`
- `deployment.site`
- `deployment.environment`

### Optional Fields

- `deployment.name`
- `deployment.customer`
- `deployment.tenant`
- `deployment.description`
- `deployment.tags`

### Example

```yaml
deployment:
  id: sjc01-ai-prod
  site: sjc01
  environment: production
```

## Platform Input Contract

The platform contract defines the management-plane and control-plane context used to validate, claim, onboard, and manage the deployment.

### Typical Sections

- `platform.intersight`
- `platform.intersight.credentials`
- `platform.intersight.assists`
- `platform.settings`

### Example

```yaml
platform:
  intersight:
    endpoint: https://intersight.com/api/v1

    credentials:
      api_key_id_ref: env://INTERSIGHT_API_KEY_ID
      api_private_key_ref: env://INTERSIGHT_API_PRIVATE_KEY

    assists:
      - id: assist-01
        enabled: true
        endpoint: https://assist-01.example.com
```

### Platform Rules

- keep platform context separate from inventory
- keep Assist helpers under `platform.intersight.assists`
- use references for credentials where possible
- derive SaaS versus PVA behavior from the Intersight endpoint unless an override is required

## Placement Input Contract

The placement contract defines where onboarding places discovered or declared inventory inside Intersight.

### Typical Sections

- `placement.intersight.organization`
- `placement.intersight.resource_group`
- `placement.intersight.policy`
- `placement.intersight.naming`

### Example

```yaml
placement:
  intersight:
    organization: ai-prod

    policy:
      reuse_existing_organization: true
      reuse_existing_resource_group: false
```

### Placement Rules

- `organization` is required
- `resource_group` is optional
- if `resource_group` is omitted, automation should use `organization`
- default behavior is create-if-not-present
- reuse behavior should be controlled with explicit booleans
- naming controls are optional

## Inventory Input Contract

The inventory contract defines the physical infrastructure facts for a deployment.

It is the primary source of truth for device presence, identity, topology, and derived infrastructure classification.

### Core Section

- `inventory.devices`
- `inventory.defaults`
- `inventory.domains`

### Example

```yaml
inventory:
  defaults:
    server_management_type: standalone

  devices:
    - id: fi-a
      serial: FCH000001A1
      category: fabric_interconnect
      mgmt_ip: 192.168.10.11
      peer: fi-b

    - id: node-01
      serial: FOX00000101
      category: server
      parent: fi-a
      attributes:
        form_factor: blade

  domains:
    - domain_id: domain-01
      type: fi_pair
      members:
        - fi-a
        - fi-b
      summary:
        chassis_count: 1
        blade_count: 4
```

### Inventory Rules

- keep inventory factual
- keep categories broad and stable
- keep solution meaning out of inventory
- use attributes for specialization
- use solution assignments for functional role
- do not mix service endpoints into inventory
- explicit child blade entries are optional when a domain summary is sufficient for early validation

## Device Category Taxonomy

Use a small set of top-level device categories.

### Allowed Categories

- `fabric_interconnect`
- `server`
- `storage`
- `ethernet_switch`
- `san_switch`

### Taxonomy Rules

- keep categories broad
- use attributes for specialization
- do not encode solution profile or workload role into category names

## Device Input Contract

Each device entry must represent a physical infrastructure fact.

A device entry must describe what the device is, not what role it plays in a specific solution.

### Required Fields

Each device should include:

- `id`
- `category`

Each device should also include at least one usable identity field such as:

- `serial`
- `mgmt_ip`

### Optional Fields

- `serial`
- `mgmt_ip`
- `peer`
- `parent`
- `location`
- `attributes`

### Common Attribute Examples

- `form_factor`
- `management_type`
- `accelerator_profile`
- `vendor`
- `model`
- `rack_location`

### Example

```yaml
inventory:
  devices:
    - id: gpu-01
      serial: GPU123
      category: server
      mgmt_ip: 192.168.10.21
      attributes:
        form_factor: rack
        accelerator_profile: gpu
        vendor: cisco
        model: ucs-c480
```

### Category-Specific Expectations

- FI-managed blades may be represented with serials and `management_type: fi_managed` and do not require `mgmt_ip`
- standalone or IMM-managed rack servers should include `mgmt_ip`
- `parent` is optional and may be discovered later

## Inventory Domain Contract

Inventory domains describe declared infrastructure groupings used for validation, discovery scoping, and later naming.

### Example

```yaml
inventory:
  domains:
    - domain_id: domain-01
      type: fi_pair
      members:
        - fi-a
        - fi-b
      summary:
        chassis_count: 1
        blade_count: 4
```

### Domain Rules

- `domain_id` should be stable and unique within the deployment
- `type` describes the declared grouping, such as `fi_pair`
- `members` references device IDs from `inventory.devices`
- `summary` is optional and may describe declared contents such as chassis or blade counts
- domains support early validation even when some managed child devices are discovered later

## Pools Input Contract

The pools contract defines reusable allocatable resource references used by provisioning and policy workflows.

Pools should be organized by pool type and then by usage name.

### Example

```yaml
pools:
  ip:
    mgmt: ip-pool-sjc01-mgmt
    os: ip-pool-sjc01-os
    storage: ip-pool-sjc01-storage

  mac:
    default: mac-pool-sjc01

  uuid:
    default: uuid-pool-sjc01

  wwpn:
    default: wwpn-pool-sjc01
```

### Pools Rules

- organize pools by type first
- use named usage keys within each pool family
- support multiple pools within the same family
- keep pool references independent from specific solution logic

## Solution Input Contract

The solution contract describes the intended base deployment profile, optional extension, delivery scope, and device-role assignments.

The current model uses a single `solution:` object.

### Core Fields

- `solution.profile`
- `solution.extension`
- `solution.goal`
- `solution.delivery_scope`
- `solution.server_assignments`
- `solution.parameters`

### Example

```yaml
solution:
  profile: secure_ai_factory
  extension: openshift
  goal: gpu_platform_deployment
  delivery_scope: platform_provisioning
  server_assignments:
    - role: control_plane
      members:
        - node-01
        - node-02
        - node-03
    - role: worker
      usage_type: gpu
      members:
        - gpu-node-01
        - gpu-node-02
```

### Solution Rules

- use a single `solution:` object
- use a single `solution.extension`
- use `solution.parameters` for profile-specific variants
- keep `solution.goal` optional
- keep solution meaning out of inventory

## Solution-Side Server Assignment Contract

Server role is defined in the solution layer, not in the inventory device entry.

### Assignment Fields

Each assignment entry may include:

- `role`
- `members`
- `usage_type`
- `policy_profile`
- `notes`

### Validation Rules

The automation system should validate that:

- each assignment member exists in inventory
- the role is valid for the selected solution profile
- conflicting role assignments are rejected unless explicitly allowed

### Example

```yaml
solution:
  profile: vast_data
  delivery_scope: os_provisioning
  server_assignments:
    - role: storage
      members:
        - vast-node-01
        - vast-node-02
        - vast-node-03
        - vast-node-04
        - vast-node-05
```

## References Input Rule

References should normally remain embedded in the domain that owns them.

Use `references.yaml` only for shared or externalized references that do not naturally belong to a single domain.

### Preferred Rule

- keep platform credential references in `platform.credentials`
- keep pool references in `pools`
- keep inventory-specific external references near inventory
- use `references.yaml` only for cross-domain or external shared references

### Example

```yaml
references:
  inventory_bundle: s3://customer-a/site1/deployment1/
  shared_vault_namespace: vault://customer-a/prod/
```

## Overrides Input Rule

Overrides should normally remain embedded in the domain that owns them.

Use `overrides.yaml` only for explicit deployment-level exceptions.

### Preferred Rule

- keep domain-local overrides in their owning domain
- use `overrides.yaml` only for true exceptions to normal baseline or catalog-driven behavior

### Example

```yaml
overrides:
  port_layout:
    fi-a:
      "1/1": uplink
      "1/2": storage
  validation:
    skip_reachability_check: true
```

## Minimum Required Fields by Workflow Stage

Different workflow stages require different minimum inputs.

The automation system should validate only the fields required for the requested workflow path and delivery scope.

### Stage 1: Inventory Classification

Minimum required inputs:

- `deployment.id`
- `deployment.site`
- `deployment.environment`

For each device:

- `id`
- `category`
- at least one of:
  - `serial`
  - `mgmt_ip`

### Stage 2: Onboarding and Discovery

Minimum required inputs:

- deployment scope fields
- device identity sufficient for the onboarding method
- platform context required by the onboarding workflow
- required Assist or equivalent platform helpers
- required credential references

### Stage 3: Infrastructure Provisioning

Minimum required inputs:

- deployment scope fields
- required topology relationships
- required platform context
- solution profile when policy selection depends on it
- required pool references

### Stage 4: OS Provisioning

Minimum required inputs:

- deployment scope fields
- inventory with required server identity
- platform context
- `solution.profile`
- `solution.delivery_scope`
- `solution.server_assignments`

### Stage 5: Platform or Application Provisioning

Minimum required inputs:

- deployment scope fields
- inventory
- platform context
- `solution.profile`
- `solution.extension` when applicable
- `solution.delivery_scope`
- `solution.server_assignments`
- extension-specific parameters when required

## Inventory Input Modes

The model should support more than one inventory input mode.

### Declared Inventory Mode

Customer or ordering systems provide explicit inventory input.

This mode is best when strong early validation matters.

### Scan Inventory Mode

Customer provides discovery targets and automation builds the effective inventory.

This mode is best when the customer does not want to enumerate systems manually.

Both modes should normalize into the same effective inventory structure before solution-profile validation proceeds.

## Scan Input Contract

The scan input contract defines discovery targets used to build inventory when the customer does not want to provide a fully declared inventory file.

### Example

```yaml
scan:
  targets:
    - type: single
      endpoint: 10.29.135.101
      management_type_hint: fi

    - type: single
      endpoint: 10.29.135.102
      management_type_hint: fi

    - type: range
      start_ip: 10.29.135.106
      end_ip: 10.29.135.109
      management_type_hint: standalone
```

### Scan Rules

- scan mode is an alternative input path, not a different architecture
- scan results must normalize into the common inventory model
- scan input should stay discovery-focused and should not include solution semantics
