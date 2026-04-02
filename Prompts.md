# Cisco Multi-Site Infrastructure Prompt Specification

## Purpose

Define a deterministic, reusable prompt specification for generating structured Infrastructure-as-Code outputs for Cisco-based infrastructure deployments across one or more sites.

This specification is intended for environments based on Cisco Intersight, UCS, Nexus, and MDS, and must support deployment patterns such as FlexPod, FlashStack, VAST Data, Oracle RAC, and similar integrated solutions.

## Assigned Role

Act as a Cisco infrastructure architect and automation expert.

The response must reflect strong architectural discipline, deterministic reasoning, and clear separation of functional areas.

## Objective

Generate a fully deterministic, policy-driven Infrastructure-as-Code solution that:

- supports one or more sites
- supports one or more solutions
- derives technical decisions from discovered facts and approved references
- separates physical infrastructure policy from higher-level solution policy
- produces outputs that can be executed consistently across environments

## Platforms in Scope

- Cisco Intersight
- Cisco UCS
- Cisco Nexus
- Cisco MDS

## Infrastructure Patterns and Solutions in Scope

The design must support infrastructure patterns such as:

- FlexPod
- FlashStack

And solutions such as:

- VAST Data
- Oracle RAC
- Nutanix
- OpenShift

Other Cisco-based solution patterns may also be supported if they follow the same data model and policy-selection logic.

## Architecture Principles

The generated solution must follow these principles:

- Deterministic output: the same validated inputs and references should produce the same results.
- Evidence-based derivation: model, role, and policy selection must be based on discovered facts, not assumptions.
- Site-aware execution: common logic may be reused, but outputs must remain scoped to the relevant site.
- Clear functional separation: outputs must be organized by the functional area that uses them.
- Layered policy design: physical port policy, onboarding policy, and solution policy must remain clearly separated.
- Idempotent behavior: outputs should be structured for repeatable, policy-driven execution.

## Multi-Site Execution Model

The input model must support one or more sites within the same overall design.

Each site may have its own:

- site name
- available infrastructure context
- infrastructure pattern hints
- Intersight organization
- Intersight resource group
- DNS configuration
- NTP configuration
- proxy settings
- Assist target
- PVA target
- inventory set
- onboarding path

Shared logic may be reused across sites, but all outputs must preserve site-specific boundaries.

## Inputs Model

Customer-provided data should be organized by input domain rather than by the person entering it.

Different teams or individuals may contribute to these domains, but the automation model must remain data-centric and hierarchical.

### Infrastructure Inputs

Infrastructure inputs describe the physical environment and device-facing details needed for discovery, onboarding, and physical policy selection.

Typical infrastructure inputs include:

- device inventory
- serial numbers
- categories
- peer relationships
- management IP information
- DNS
- NTP
- proxy
- physical connectivity hints
- optional exception-level port layout overrides when required

### Platform Inputs

Platform inputs describe control-plane and platform-management details, especially those related to Intersight and platform policy association.

Typical platform inputs include:

- Intersight organization
- resource group
- Assist information
- PVA information
- claim-related information
- credentials references
- pool definitions or pool references
- platform resource bindings
- optional exception-level platform overrides when required

### Solution Inputs

Solution inputs describe the logical solutions that consume a deployment and the server usage associated with each solution.

Typical solution inputs include:

- one or more solutions attached to the deployment
- solution intent and goal
- delivery scope
- logical grouping per solution
- server assignment model per solution
- server role assignment per solution
- server usage assignment per solution
- quantity and grouping of servers per logical role
- solution-specific requirements

## Scope Boundary

The automation scope must be explicitly bounded by delivery stage.

The supported delivery stages are:

- `onboarding`
- `network_infra_provisioning`
- `server_infra_provisioning`
- `os_provisioning`
- `app_provisioning`

Each solution attached to a deployment should declare the stage at which automation stops.

Examples:

- `onboarding`
  claim, discovery, baseline readiness, and handoff
- `network_infra_provisioning`
  network-side infrastructure provisioning on top of onboarding
- `server_infra_provisioning`
  server and profile provisioning on top of onboarding
- `os_provisioning`
  infrastructure automation plus OS installation and handoff
- `app_provisioning`
  later-layer application or platform installation beyond OS handoff

Current design intent:

- infrastructure automation and OS deployment are in scope
- application-admin workflows are not the primary current scope
- some solutions may intentionally stop at `onboarding`
- some solutions may stop at `network_infra_provisioning` or `server_infra_provisioning`
- some solutions may continue through `os_provisioning`

Examples of scope usage:

- standalone Nutanix infrastructure guidance may use `delivery_scope: onboarding`
- FlexPod foundation may use `delivery_scope: network_infra_provisioning` or `server_infra_provisioning`
- bare-metal solutions that include answer-file-driven OS install may use `delivery_scope: os_provisioning`

### Input Contribution Note

These input domains may be maintained by different roles or teams, but the automation engine should treat them as structured input domains rather than person-specific ownership boundaries.

## Input Specification

## Input Source Model

The automation engine must consume customer-provided data as one or more `input sources`.

An input source is the logical container used by automation to load deployment data, scoped defaults, and supporting metadata required for execution.

The automation engine should treat the input source as a hierarchical data structure, regardless of where it is hosted.

### Input Source Characteristics

An input source may contain:

- deployment-specific input data
- customer default data
- site-scoped defaults
- data-center-scoped defaults
- device inventory
- network and addressing inputs
- Intersight references
- credentials references
- pool definitions or pool references

### Input Source Locations

An input source may be hosted in different backends, such as:

- local filesystem
- remote HTTP server
- remote file server
- cloud object storage
- other structured remote repositories

The automation engine should resolve data using the same logical hierarchy regardless of storage location or transport method.

### Input Source Hierarchy

The customer-facing structure should be treated as a logical hierarchy, not necessarily a local directory on the automation host.

One possible representation is:

```text
input-source/
  global/
  sites/
  dcs/
  deployments/
    deployment_a/
    deployment_b/
```

This structure may be represented through directories and files, object prefixes, HTTP-served paths, or equivalent structured storage layouts.

### Input Source and Deployment Relationship

Each deployment should reference one or more input sources used during resolution.

A deployment may consume:

- its own deployment-specific input source
- one or more customer input scopes
- automation system defaults provided by the automation platform

### Input Source Resolution Intent

The purpose of the input source model is to ensure that:

- automation uses a consistent logical structure for all customer data
- customer data can be hosted in different storage backends
- deployments can inherit multiple applicable customer default scopes
- runtime resolution remains independent of physical storage implementation

## Ownership and Resolution Model

The design must clearly separate what is owned by the automation system from what is provided by the customer.

### Automation System Ownership

The automation system owns the default logic required to interpret inputs and generate outputs.

This typically includes:

- catalog structure and baseline catalog content
- supported solution definitions
- policy mappings
- model-to-policy mappings
- profile selection logic
- validation logic
- execution logic

These defaults are part of the automation platform and are not required to be exposed as part of the customer input-source hierarchy.

### Customer Ownership

The customer provides one or more input sources used by the automation engine during deployment resolution.

Customer-provided data may include:

- infrastructure inputs
- platform inputs
- solution inputs
- reusable customer defaults
- deployment-specific data
- environment-specific resources such as pools and credentials
- optional exception overrides when required

### Deployment as the Execution Unit

A `deployment` is the infrastructure unit of execution used by the automation engine.

Each deployment should reference:

- one or more customer input sources
- the relevant site context
- the relevant deployment context
- any applicable customer input scopes

The deployment is the point at which customer-provided infrastructure data, platform data, and one or more attached solutions are resolved into effective inputs for planning, onboarding, configuration, deployment, and validation.

### Customer Input Scopes

Customer-provided input data may exist at multiple levels of specificity.

Examples include:

- customer-global inputs
- site-scoped inputs
- data-center-scoped inputs
- deployment-specific inputs

Not every deployment must use all scopes, but the automation engine should support multiple matching customer scopes for a single deployment.

### Resolution Precedence

For a given deployment, effective input resolution should follow this order:

1. deployment-specific input data
2. data-center-scoped customer inputs when applicable
3. site-scoped customer inputs when applicable
4. customer-global inputs
5. automation system defaults

The most specific matching input should take precedence over broader defaults.

### Resolution Behavior

The automation engine should:

- load the deployment input source
- identify the applicable customer scopes
- merge customer-provided data according to precedence
- apply automation system defaults only when customer-provided data does not supply the required values
- preserve traceability for derived values and resolved selections

### Resolution Outcome

The result of resolution should be an effective deployment view that contains:

- resolved infrastructure inputs
- resolved platform inputs
- resolved solution inputs
- resolved catalog selections
- effective policy and profile mappings
- any unresolved dependencies or missing required inputs

### Illustrative Deployment Input Source

The following example is illustrative only. It is intended to validate structure and flow, not to define final field names.

Suggested naming goals for this structure:

- keep top-level domains aligned to `infrastructure_inputs`, `platform_inputs`, and `solution_inputs`
- use `input_sources` for external source references
- use `solutions` to describe logical consumers on top of the deployment
- use `server_assignments` inside each solution to describe how servers are consumed
- treat pools, credentials, and site/platform resources as primary deployment inputs
- treat policy overrides as optional exception mechanisms rather than the default operating model

```yaml
deployment:
  id: sjc01-infra-prod
  site: sjc01
  dc: dc1
  pattern: infrastructure_foundation
  infrastructure_pattern: converged_ucs
  environment: production

  input_sources:
    deployment: https://inputs.example.com/deployments/sjc01-infra-prod/
    site_defaults: https://inputs.example.com/sites/sjc01/
    dc_defaults: https://inputs.example.com/dcs/dc1/
    global_defaults: https://inputs.example.com/defaults/global/

  infrastructure_inputs:
    dns:
      servers:
        - 10.10.10.10
        - 10.10.10.11
    ntp:
      servers:
        - 10.20.20.10
        - 10.20.20.11
    proxy:
      enabled: false
    devices:
      - id: fi-a
        serial: FCH000000A1
        category: fabric_interconnect
        mgmt_ip: 192.168.10.11
        peer: fi-b
      - id: fi-b
        serial: FCH000000B1
        category: fabric_interconnect
        mgmt_ip: 192.168.10.12
        peer: fi-a
      - id: blade-01
        serial: FOX00000001
        category: blade
        parent: fi-a
      - id: nexus-a
        serial: FDO00000001
        category: nexus
        mgmt_ip: 192.168.20.11

  platform_inputs:
    intersight:
      organization: customer-org-a
      resource_group: rg-sjc01-prod
      assist:
        enabled: true
        endpoint: https://assist.example.com
      pva:
        enabled: false
    credentials:
      fi_admin: vault://customer/fi-admin
      nxos_admin: vault://customer/nxos-admin
      intersight_api: vault://customer/intersight-api
    pools:
      ip_pool: ip-pool-sjc01-prod
      mac_pool: mac-pool-sjc01-prod
      uuid_pool: uuid-pool-sjc01-prod

  solution_inputs:
    solutions:
      - name: oracle_rac
        goal: high_availability_database
        delivery_scope: server_infra_provisioning
        server_assignments:
          - role: compute
            usage_type: controller
            count: 2
          - role: compute
            usage_type: solution_specific
            count: 2
        logical_groups:
          - name: rac_cluster
            members:
              - blade-01
              - blade-02
      - name: vast_data
        goal: shared_storage_services
        delivery_scope: os_provisioning
        server_assignments:
          - role: storage
            usage_type: default
            count: 2
        logical_groups:
          - name: storage_cluster
            members:
              - blade-03
              - blade-04
```

## Optional Input Normalization

The solution may normalize and digest raw input before policy selection or output generation begins when ordering information, component lists, or incomplete inventory data are available.

This step is optional and should be used when it improves inventory normalization, site association, or solution inference.

### Input Digestion Objectives

When used, the digestion process must:

- normalize raw inventory records
- associate devices to the correct site
- associate devices to the correct deployment context where possible
- separate known values from derived values
- identify missing data that must be resolved through discovery
- infer likely solution context from ordering information and component PIDs
- preserve evidence trails for any inferred classification

### Ordering Information

Input may include ordering information that contains a list of devices or components associated with a deployment.

Ordering information may include:

- sales order or order identifier
- site association
- device list
- component list
- product identifiers
- part numbers
- PID values
- quantity
- bundle or solution packaging hints

This ordering information should be treated as a planning input and correlation source, not as final proof of runtime device role.

### Device List Digestion

When ordering information provides a list of devices, the digestion process should:

- normalize each device into a canonical inventory record
- associate serial numbers, management IPs, peer relationships, and category hints where available
- identify whether the record represents a physical device, logical device, or component
- correlate the device record with live discovery targets

### PID-Based Solution Inference

Ordering PID information may be used to infer likely solution context.

Examples of solution context include:

- FlexPod
- FlashStack
- VAST Data
- Oracle RAC
- other supported integrated solution patterns

PID-based inference must follow these rules:

- use ordering PIDs to infer probable deployment or solution family
- treat inferred solution type as a planning hypothesis until validated against the full device and component set
- do not use PID inference alone to derive runtime device role
- preserve the evidence used for the inferred solution classification

### Input Digestion Outputs

When input digestion is used, it should produce structured outputs such as:

- normalized site inventory
- normalized device inventory
- normalized logical device inventory
- ordering-to-device correlation
- PID-to-solution inference
- known values versus derived values
- unresolved fields requiring live discovery
- confidence or evidence notes for inferred solution classification

### Site Inputs

Each site definition may include:

- site name
- organization
- resource group
- DNS settings
- NTP settings
- proxy settings
- Assist endpoint information
- PVA endpoint information
- device inventory
- logical device groupings

### Device Inventory Inputs

Each device record may include:

- serial number
- optional model
- device type hint
- category
- management IP
- peer serial for paired devices
- credentials reference

### Logical Device Inputs

Logical groupings may include:

- management IPs
- serials
- category
- credentials reference
- peer relationship metadata
- manufacturing default credentials when explicitly required

## Discovery and Evidence Model

The design must assume that not all values are known up front.

The following values must be treated as derived values:

- model
- role
- reachability
- peer validation status

These values must be derived from valid evidence such as:

- live device query
- serial-based lookup
- management IP discovery
- parent-device discovery
- Intersight API results

Operator hints may guide discovery, but must not be treated as final authority for derived values.

## Reference Inputs

Use the following references as authoritative inputs for policy selection:

- Recommended Port Mappings for Fabric Interconnects (64XX, 65XX, 66XX)
- Recommended Device Connections Settings
- Cisco Validated Designs for Port Policies

## Catalog Model

The automation data model should be organized around three major areas:

- `baselines/`
- `catalog/`
- `inputs/`

This keeps automation-owned baseline data separate from selectable catalog content and customer-provided deployment data.

### Catalog Design Principles

- Use `baselines/` for automation-owned baseline definitions and reusable policy data.
- Use `catalog/` for selectable mappings, intent definitions, and policy-selection content.
- Use `inputs/` for customer-provided deployment data and scoped overrides.
- Use YAML as the primary format across all three areas.
- Keep the structure simple and implementation-friendly.

### Recommended Structure

```text
baselines/
  fi_models/
  port_layouts/
  domain_policies/
  server_profiles/

catalog/
  solution_intents/
  server_profile_policies/
  validation_checks/

inputs/
  global/
  sites/
  deployments/
```

### Area Meanings

#### Baselines

The `baselines/` area should contain automation-owned baseline data.

Examples include:

- FI model defaults
- recommended port layouts by platform or model
- reusable domain policy definitions
- reusable server profile definitions
- hardware-specific supported ranges and constraints

#### Catalog

The `catalog/` area should contain selectable automation data.

Examples include:

- solution intent mappings
- server profile policy selections
- validation definitions

#### Inputs

The `inputs/` area should contain customer-provided data.

Examples include:

- global customer defaults
- site-scoped customer data
- deployment-specific data
- credentials references
- inventory and addressing inputs
- domain policy override references
- port layout overrides
- override references

### Practical Mapping

The current and recommended practical mapping looks like this:

- `baselines/fi_models`
  model-based FI defaults and supported ranges
- `baselines/port_layouts`
  recommended port layouts by FI, Nexus, MDS, or other networking platforms
- `baselines/domain_policies`
  baseline domain onboarding policy definitions
- `catalog/solution_intents`
  solution intent mappings and solution-key resolution
- `catalog/server_profile_policies`
  selection logic for solution, server role, and usage type
- `catalog/validation_checks`
  validation and checkpoint definitions
- `inputs`
  customer deployment inputs and scoped defaults

### Platform-Conditional Usage

Automation should only use the areas that apply to the discovered infrastructure platform.

- If the deployment contains Fabric Interconnect-managed infrastructure, automation may use:
  - `baselines/fi_models`
  - `baselines/port_layouts` for FI layouts
  - `baselines/domain_policies`
  - FI and domain onboarding logic

- If the deployment does not contain Fabric Interconnects, automation must not require or apply FI/domain-specific logic.

Examples of deployments that may skip FI/domain-specific logic:

- standalone rack-server deployments
- server-profile-only deployments
- solution deployments that rely on standalone server assignment and profile activation without UCS domain onboarding

### YAML Entry Model

Each YAML file should contain one or more entries with selector-based applicability.

Typical selectors may include:

- `solution`
- `model`
- `server_role`
- `usage_type`
- `device_role`
- `site`
- `deployment`

Example structure:

```yaml
entries:
  - name: fi_6536_flexpod_uplink_mapping
    selectors:
      solution: flexpod
      model: UCS-FI-6536
    value:
      port_map:
        - port: "1/1"
          role: uplink
        - port: "1/2"
          role: uplink
    source: cisco_default
```

### Catalog Selector Rules

Within the relevant catalog area and entry type, selectors should be used to choose the correct content:

- `solution` defines architectural and workload context
- `model` defines hardware-specific applicability
- `server_role` defines workload or function-specific behavior
- `usage_type` defines how that role is used within the selected solution
- `device_role` defines physical attachment or operational role when needed

Not every catalog entry requires all selectors, but required selectors must be present before a policy is chosen.

### Data Classification

Each catalog entry should distinguish between:

- metadata
- selectors
- rendered values

Metadata describes the entry itself, such as:

- `name`
- `source`
- `description`
- `priority`
- `owner`

Selectors define when the entry applies, such as:

- `site`
- `deployment`
- `solution`
- `model`
- `server_role`
- `usage_type`
- `device_role`

Rendered values define the actual output content used by the selected catalog area, such as:

- port maps
- device connection settings
- policy sets
- workflow steps
- validation checks
- runbook instructions

### Overlay and Precedence Rules

Effective policy resolution should follow this order:

1. deployment-scoped `inputs/`
2. site-scoped `inputs/`
3. global `inputs/`
4. matching `catalog/` entries
5. matching `baselines/` entries

If no applicable entry is found, the output should identify the missing catalog path or missing selector rather than inventing a value.

### Resolution Algorithm

Catalog resolution should follow this sequence:

1. Identify the target site.
2. Identify the target deployment within that site.
3. Load deployment, site, and global inputs.
4. Select the relevant catalog area.
5. Select the relevant catalog entry type.
6. Apply selectors such as `solution`, `model`, `server_role`, and `usage_type`.
7. Choose the most specific applicable entry.
8. If no specific match exists, fall back according to precedence.
9. If no valid fallback exists, report the missing dependency explicitly.

### Catalog Usage Rules

- Catalog lookup must begin with scope and ownership resolution.
- After scope resolution, lookup must select the correct catalog area.
- Within that catalog area, lookup must select the correct `entry type`.
- Within that entry type, selectors such as `solution`, `model`, and `server_role` must determine applicability.
- If a required selector is missing, the output must identify the dependency and avoid unsupported assumptions.

### Example Repository Tree

```text
baselines/
  fi_models/
    ucs_fi_6454.yaml
    ucs_fi_6536.yaml
    ucs_fi_6652.yaml
    ucs_fi_6664.yaml
  port_layouts/
    fi/
      default.yaml
    nexus/
      default.yaml
  domain_policies/
    domain_profile_default.yaml
  server_profiles/
    compute_default.yaml

catalog/
  solution_intents/
    catalog-map.yaml
    flexpod.yaml
    virtualization_foundation.yaml
    ai_pod.yaml
  server_profile_policies/
    default.yaml
  validation_checks/
    default.yaml

inputs/
  global/
  sites/
    sjc01/
  deployments/
    sjc01-infra-converged-prod/
      inventory.yaml
      deployment.yaml
      platform.yaml
      solution.yaml
      pools.yaml
      domain_policy.yaml
      port_layout.yaml
```

### Example YAML: `inputs/deployments/sjc01-infra-converged-prod/deployment.yaml`

```yaml
deployment:
  id: sjc01-infra-converged-prod
  site: sjc01
  dc: dc1
  pattern: infrastructure_foundation
  infrastructure_pattern: converged_ucs
  environment: production
```

### Example YAML: `inputs/deployments/sjc01-infra-converged-prod/inventory.yaml`

```yaml
devices:
  - id: fi-a
    serial: FCH000000A1
    category: fabric_interconnect
    mgmt_ip: 192.168.10.11
    peer: fi-b
  - id: fi-b
    serial: FCH000000B1
    category: fabric_interconnect
    mgmt_ip: 192.168.10.12
    peer: fi-a
  - id: blade-01
    serial: FOX00000001
    category: blade
    parent: fi-a
  - id: nexus-a
    serial: FDO00000001
    category: nexus
    mgmt_ip: 192.168.20.11

notes:
  - Deployment inventory provides the physical device set used for discovery and onboarding.
```

### Example YAML: `inputs/deployments/sjc01-infra-converged-prod/platform.yaml`

```yaml
intersight:
  organization: customer-org-a
  resource_group: rg-sjc01-prod
  assist:
    enabled: true
    endpoint: https://assist.example.com
  pva:
    enabled: false

credentials:
  fi_admin: vault://customer/fi-admin
  nxos_admin: vault://customer/nxos-admin
  intersight_api: vault://customer/intersight-api

notes:
  - Platform input provides organization, appliance access, and credential references.
```

### Example YAML: `inputs/deployments/sjc01-infra-converged-prod/pools.yaml`

```yaml
pools:
  ip_pool: ip-pool-sjc01-prod
  mac_pool: mac-pool-sjc01-prod
  uuid_pool: uuid-pool-sjc01-prod

notes:
  - Pool inputs provide environment-specific resources consumed during deployment.
```

### Example YAML: `inputs/deployments/sjc01-infra-converged-prod/solution.yaml`

```yaml
solutions:
  - name: oracle_rac
    goal: high_availability_database
    delivery_scope: server_infra_provisioning
    server_assignments:
      - role: compute
        usage_type: controller
        count: 2
      - role: storage
        usage_type: default
        count: 2
    logical_groups:
      - name: rac_cluster
        members:
          - blade-01
          - blade-02
      - name: database_storage
        members:
          - blade-03
          - blade-04

notes:
  - Solution input defines one or more solutions on top of the converged infrastructure deployment.
```

### Optional Exception Example: `inputs/deployments/sjc01-infra-converged-prod/port_layout.yaml`

```yaml
layout_source:
  platform: fi
  model: UCS-FI-6536
  baseline: default

port_layout:
  uplink_port_channels:
    - name: customer-uplink-pc
      pc_id: 110
      member_ports:
        - "1/33"
        - "1/34"
      admin_speed: Auto
      fec: Auto

notes:
  - Optional exception input used only when the baseline port layout must be adjusted.
```

### Optional Exception Example: `inputs/deployments/sjc01-infra-converged-prod/domain_policy.yaml`

```yaml
policy_source:
  baseline: domain_profile_default

domain_policy_overrides:
  ntp:
    servers:
      - ntp1.customer.example.com
      - ntp2.customer.example.com

notes:
  - Optional exception input used only when selected baseline domain policy values must be changed.
```

### Server Profile Catalog Model

Server profile policies should be organized to support multiple profiles beneath a common `server_role`.

Each `server_role` may contain:

- one or more `usage_type` values
- an optional `allowed_models` list
- one or more named profiles
- a `default` profile or default profile selector

This allows one role family to support several deployment-specific or function-specific profiles without flattening everything into a single list.

### Server Role Structure

Server profile catalog entries should support a flexible hierarchy in which:

- `server_role` defines the broad functional family
- `usage_type` defines how that role is consumed within the selected solution
- `default` provides the fallback profile for the role when no more specific subtype applies

The exact role names and usage names should be customer- and solution-driven, not hardcoded by the framework.

Illustrative examples may include:

- a storage-oriented role used differently in VAST Data and DDN
- a compute-oriented role used differently in Nutanix and other solution patterns
- a GPU-oriented role used differently for training and inference

These examples are only intended to show the structure of the catalog model. They must not be treated as a fixed or exhaustive taxonomy.

### Server Profile Selection Rules

- Server profile selection must begin with `server_role`.
- If present, `usage_type` must refine the selection beneath that role.
- If `allowed_models` is present, the discovered server model must match one of the listed models.
- If `allowed_models` is not present, the entry is unrestricted by model.
- A role should always be able to resolve to a `default` profile when no more specific type applies.
- Solution, model, and site selectors may further refine the selected profile when required.
- If multiple profiles match, the most specific applicable profile should win.
- If no specific profile matches, the role-level `default` must be used if defined.
- The framework must not assume a universal predefined list of server roles or usage types.

### Example YAML: `catalog/server_profile_policies/default.yaml`

```yaml
entries:
  - name: nutanix_compute_profiles
    selectors:
      solution: nutanix
      server_role: compute
    allowed_models:
      - UCSX-210C-M7
      - UCSX-210C-M6
    profiles:
      default:
        policy_set:
          bios_policy: nutanix-compute-default-bios
          boot_policy: nutanix-compute-default-boot
          lan_connectivity_policy: nutanix-compute-default-lan
      management:
        policy_set:
          bios_policy: nutanix-compute-management-bios
          boot_policy: nutanix-compute-management-boot
          lan_connectivity_policy: nutanix-compute-management-lan
      controller:
        policy_set:
          bios_policy: nutanix-compute-controller-bios
          boot_policy: nutanix-compute-controller-boot
          lan_connectivity_policy: nutanix-compute-controller-lan
      automation:
        policy_set:
          bios_policy: nutanix-compute-automation-bios
          boot_policy: nutanix-compute-automation-boot
          lan_connectivity_policy: nutanix-compute-automation-lan
    source: automation_catalog

  - name: vast_storage_profiles
    selectors:
      solution: vast_data
      server_role: storage
    allowed_models:
      - UCSC-C240-M7
      - UCSC-C245-M8
    profiles:
      default:
        policy_set:
          bios_policy: vast-storage-default-bios
          boot_policy: vast-storage-default-boot
          san_connectivity_policy: vast-storage-default-san
    source: automation_catalog

  - name: ddn_storage_profiles
    selectors:
      solution: ddn
      server_role: storage
    profiles:
      default:
        policy_set:
          bios_policy: ddn-storage-default-bios
          boot_policy: ddn-storage-default-boot
          san_connectivity_policy: ddn-storage-default-san
    source: automation_catalog

  - name: ai_gpu_profiles
    selectors:
      solution: ai_platform
      server_role: gpu
    allowed_models:
      - UCSC-C480-M7
      - UCSC-C885A-M8
    profiles:
      default:
        policy_set:
          bios_policy: gpu-default-bios
          boot_policy: gpu-default-boot
          lan_connectivity_policy: gpu-default-lan
      training:
        policy_set:
          bios_policy: gpu-training-bios
          boot_policy: gpu-training-boot
          lan_connectivity_policy: gpu-training-lan
      inference:
        policy_set:
          bios_policy: gpu-inference-bios
          boot_policy: gpu-inference-boot
          lan_connectivity_policy: gpu-inference-lan
    source: automation_catalog

```

### Example Resolution Flow for Server Profiles

The following example shows how deployment input can drive catalog resolution for server profile policy selection.

Example deployment input:

```yaml
solution_inputs:
  solutions:
    - name: nutanix
      server_assignments:
        - role: compute
          usage_type: controller
          count: 2
    - name: vast_data
      server_assignments:
        - role: storage
          usage_type: default
          count: 2
    - name: ai_platform
      server_assignments:
        - role: gpu
          usage_type: training
          count: 4
```

Example catalog match behavior:

- `solution=nutanix`, `role=compute`, and `usage_type=controller` resolves to `nutanix_compute_profiles -> profiles.controller`
- `solution=vast_data` and `role=storage` resolves to `vast_storage_profiles -> profiles.default`
- `solution=ai_platform`, `role=gpu`, and `usage_type=training` resolves to `ai_gpu_profiles -> profiles.training`
- when `allowed_models` is present, the discovered model must be in that list before the entry is valid
- when `allowed_models` is omitted, no model allow-list check is enforced for that entry

Example resolved outcome:

```yaml
resolved_server_profiles:
  - role: compute
    solution: nutanix
    usage_type: controller
    selected_profile: nutanix_compute_profiles.controller
    policy_set:
      bios_policy: nutanix-compute-controller-bios
      boot_policy: nutanix-compute-controller-boot
      lan_connectivity_policy: nutanix-compute-controller-lan

  - role: storage
    solution: vast_data
    usage_type: default
    selected_profile: vast_storage_profiles.default
    policy_set:
      bios_policy: vast-storage-default-bios
      boot_policy: vast-storage-default-boot
      san_connectivity_policy: vast-storage-default-san

  - role: gpu
    solution: ai_platform
    usage_type: training
    selected_profile: ai_gpu_profiles.training
    policy_set:
      bios_policy: gpu-training-bios
      boot_policy: gpu-training-boot
      lan_connectivity_policy: gpu-training-lan
```

### Concrete Example: VAST Data

The following example uses the VAST reference repository as a concrete pattern for deployment data and automation-owned profile logic.

Reference repository:

- [vast-intersight-profile-automation README](https://github.com/anildhim/vast-intersight-profile-automation/blob/main/README.md)
- [group_vars/all.yml](https://github.com/anildhim/vast-intersight-profile-automation/blob/main/group_vars/all.yml)

#### Example YAML: `inputs/deployments/sjc01-infra-standalone-prod/deployment.yaml`

```yaml
deployment:
  id: sjc01-infra-standalone-prod
  site: sjc01
  pattern: infrastructure_foundation
  infrastructure_pattern: standalone_ucs
  environment: production
```

#### Example YAML: `inputs/deployments/sjc01-infra-standalone-prod/inventory.yaml`

```yaml
devices:
  - id: vast-node-01
    serial: WZP2949ACF2
    category: rack_server
  - id: vast-node-02
    serial: WZP2949ACF1
    category: rack_server
  - id: vast-node-03
    serial: WZP2949ACDC
    category: rack_server
  - id: vast-node-04
    serial: WZP2949ACDB
    category: rack_server
  - id: vast-node-05
    serial: WZP2949ACF9
    category: rack_server

notes:
  - This inventory mirrors the serial-driven node set used in the VAST reference automation.
```

#### Example YAML: `inputs/deployments/sjc01-infra-standalone-prod/platform.yaml`

```yaml
intersight:
  organization: default
  organization_description: Organisation for VAST
  create_organization_if_missing: true
  include_default_organization: true
  target_platform: Standalone

credentials:
  api_key_id_ref: env://INTERSIGHT_API_KEY_ID
  private_key_path_ref: env://INTERSIGHT_API_PRIVATE_KEY_PATH

notes:
  - This follows the standalone organization-first pattern used by the VAST reference repository.
```

#### Example YAML: `inputs/deployments/sjc01-infra-standalone-prod/solution.yaml`

```yaml
solutions:
  - name: vast_data
    goal: node_assignment_and_profile_deployment
    delivery_scope: os_provisioning
    server_assignments:
      - role: storage
        usage_type: default
        members:
          - vast-node-01
          - vast-node-02
          - vast-node-03
          - vast-node-04
          - vast-node-05

notes:
  - This solution consumes the standalone rack-server deployment as a VAST Data node group.
```

#### Example YAML: `catalog/server_profile_policies/default.yaml`

```yaml
entries:
  - name: vast_standalone_storage_profiles
    selectors:
      solution: vast_data
      server_role: storage
      usage_type: default
    allowed_models:
      - Cisco UCS C225 M8
    profiles:
      default:
        policy_set:
          bios_policy: auto-vast-bios
          boot_policy: auto-vast-bootorder
          power_policy: auto-vast-power
          ipmi_policy: auto-vast-ipmi
          local_user_policy: auto-vast-localuser
          serial_over_lan_policy: auto-vast-sol
          virtual_kvm_policy: auto-vast-vkvm
          storage_policy: auto-vast-storage
        template:
          name: auto-vast-template
          target_platform: Standalone
    source: automation_catalog

notes:
  - The policy names and template name match the VAST reference automation repository.
  - Because `allowed_models` is present, only discovered servers matching `Cisco UCS C225 M8` are valid for this entry.
```

### Concrete Example: FlexPod with Oracle RAC

The following example shows how the same model can represent a FlexPod infrastructure deployment with Oracle RAC as a solution on top of that deployment.

Reference examples:

- [FlexPod Datacenter with Oracle 19c RAC on Cisco UCS and NetApp AFF](https://www.cisco.com/c/en/us/td/docs/unified_computing/ucs/UCS_CVDs/flexpod_oracle_ucs_m5.html)
- [FlexPod Datacenter with Oracle 21c RAC on Cisco UCS X-Series M7 and NetApp AFF900](https://www.cisco.com/c/en/us/td/docs/unified_computing/ucs/UCS_CVDs/flexpod_oracle_xseries_m7.html)

#### Example YAML: `inputs/deployments/sjc01-infra-converged-prod/deployment.yaml`

```yaml
deployment:
  id: sjc01-infra-converged-prod
  site: sjc01
  pattern: infrastructure_foundation
  infrastructure_pattern: flexpod
  environment: production
```

#### Example YAML: `inputs/deployments/sjc01-infra-converged-prod/inventory.yaml`

```yaml
devices:
  - id: fi-a
    serial: FCH000001A1
    category: fabric_interconnect
    mgmt_ip: 192.168.10.11
    peer: fi-b
  - id: fi-b
    serial: FCH000001B1
    category: fabric_interconnect
    mgmt_ip: 192.168.10.12
    peer: fi-a
  - id: nexus-a
    serial: FDO000001A1
    category: nexus
    mgmt_ip: 192.168.20.11
  - id: nexus-b
    serial: FDO000001B1
    category: nexus
    mgmt_ip: 192.168.20.12
  - id: mds-a
    serial: SAL000001A1
    category: mds
    mgmt_ip: 192.168.30.11
  - id: mds-b
    serial: SAL000001B1
    category: mds
    mgmt_ip: 192.168.30.12
  - id: ucsx-node-01
    serial: FOX00000101
    category: compute_server
    parent: fi-a
  - id: ucsx-node-02
    serial: FOX00000102
    category: compute_server
    parent: fi-b
  - id: netapp-aff-a
    serial: NA000001A1
    category: storage_array
  - id: netapp-aff-b
    serial: NA000001B1
    category: storage_array

notes:
  - This inventory represents a FlexPod-style infrastructure footprint with UCS, FI, Nexus, MDS, and NetApp storage.
```

#### Example YAML: `inputs/deployments/sjc01-infra-converged-prod/platform.yaml`

```yaml
intersight:
  organization: flexpod-prod
  resource_group: rg-flexpod-sjc01
  assist:
    enabled: true
    endpoint: https://assist.example.com

credentials:
  fi_admin: vault://customer/flexpod/fi-admin
  nxos_admin: vault://customer/flexpod/nxos-admin
  mds_admin: vault://customer/flexpod/mds-admin
  intersight_api: vault://customer/flexpod/intersight-api

notes:
  - Platform input defines the Intersight control-plane context for the FlexPod deployment.
```

#### Example YAML: `inputs/deployments/sjc01-infra-converged-prod/solution.yaml`

```yaml
solutions:
  - name: oracle_rac
    goal: high_availability_database
    delivery_scope: server_infra_provisioning
    server_assignments:
      - role: compute
        usage_type: controller
        members:
          - ucsx-node-01
          - ucsx-node-02
      - role: storage
        usage_type: default
        members:
          - netapp-aff-a
          - netapp-aff-b
    logical_groups:
      - name: rac_cluster
        members:
          - ucsx-node-01
          - ucsx-node-02
      - name: database_storage
        members:
          - netapp-aff-a
          - netapp-aff-b

notes:
  - The deployment is the FlexPod infrastructure.
  - Oracle RAC is modeled as a solution consuming compute and storage resources from that deployment.
```

#### Example YAML: `catalog/server_profile_policies/default.yaml`

```yaml
entries:
  - name: oracle_rac_flexpod_compute_profiles
    selectors:
      solution: oracle_rac
      server_role: compute
      usage_type: controller
    allowed_models:
      - UCSX-210C-M7
      - UCSX-210C-M6
      - UCSB-B200-M5
    profiles:
      default:
        policy_set:
          bios_policy: flexpod-oracle-rac-compute-bios
          boot_policy: flexpod-oracle-rac-compute-boot
          lan_connectivity_policy: flexpod-oracle-rac-compute-lan
          san_connectivity_policy: flexpod-oracle-rac-compute-san
    source: automation_catalog

notes:
  - This example shows Oracle RAC as a solution on top of FlexPod infrastructure.
  - Because the deployment includes Fabric Interconnect-managed infrastructure, FI model, port layout, and domain policy logic may also apply.
```

### Concrete Example: AI Pod

The following example shows how the model represents a GPU-focused infrastructure deployment using an AI pod infrastructure pattern, with infrastructure automation stopping at OS handoff.

#### Example YAML: `inputs/deployments/sjc01-infra-ai-prod/deployment.yaml`

```yaml
deployment:
  id: sjc01-infra-ai-prod
  site: sjc01
  pattern: infrastructure_foundation
  infrastructure_pattern: ai_pod
  environment: production
```

#### Example YAML: `inputs/deployments/sjc01-infra-ai-prod/inventory.yaml`

```yaml
devices:
  - id: gpu-node-01
    serial: FCHAI000001
    category: gpu_server
    mgmt_ip: 192.168.50.11
  - id: gpu-node-02
    serial: FCHAI000002
    category: gpu_server
    mgmt_ip: 192.168.50.12
  - id: gpu-node-03
    serial: FCHAI000003
    category: gpu_server
    mgmt_ip: 192.168.50.13
  - id: gpu-node-04
    serial: FCHAI000004
    category: gpu_server
    mgmt_ip: 192.168.50.14
  - id: nexus-ai-a
    serial: FDOAI000001
    category: nexus
    mgmt_ip: 192.168.60.11
  - id: nexus-ai-b
    serial: FDOAI000002
    category: nexus
    mgmt_ip: 192.168.60.12

notes:
  - This inventory represents a standalone or rack-based AI pod footprint with GPU-capable servers and data-center networking.
```

#### Example YAML: `inputs/deployments/sjc01-infra-ai-prod/platform.yaml`

```yaml
intersight:
  organization: ai-prod
  resource_group: rg-ai-sjc01

credentials:
  server_admin: vault://customer/ai/server-admin
  nxos_admin: vault://customer/ai/nxos-admin
  intersight_api: vault://customer/ai/intersight-api

notes:
  - Platform input provides the control-plane context for the AI pod deployment.
```

#### Example YAML: `inputs/deployments/sjc01-infra-ai-prod/pools.yaml`

```yaml
pools:
  ip_pool: ip-pool-sjc01-ai
  uuid_pool: uuid-pool-sjc01-ai

notes:
  - Pool inputs provide environment-specific resources consumed during AI pod deployment.
```

#### Example YAML: `inputs/deployments/sjc01-infra-ai-prod/solution.yaml`

```yaml
solutions:
  - name: ai_training
    goal: gpu_training_infrastructure
    delivery_scope: os_provisioning
    os_hint: rocky_linux
    server_assignments:
      - role: gpu
        usage_type: training
        members:
          - FCHAI000001
          - FCHAI000002
          - FCHAI000003
          - FCHAI000004

notes:
  - This solution models only the infrastructure and OS handoff needed for AI training nodes.
  - NVIDIA stack and higher-layer application deployment are later extensions.
```

#### Example YAML: `catalog/server_profile_policies/default.yaml`

```yaml
entries:
  - name: ai_training_gpu_profiles
    selectors:
      solution: ai_training
      server_role: gpu
      usage_type: training
    allowed_models:
      - UCSC-C480-M7
      - UCSC-C885A-M8
    profiles:
      default:
        policy_set:
          bios_policy: ai-training-gpu-bios
          boot_policy: ai-training-gpu-boot
          lan_connectivity_policy: ai-training-gpu-lan
          storage_policy: ai-training-gpu-storage
        os_profile:
          os_hint: rocky_linux
          deployment_method: answer_file_orchestrated
    source: automation_catalog

notes:
  - This example keeps AI automation at the infrastructure and OS handoff layer.
  - Application and NVIDIA software stack installation are not part of this first-phase example.
```

## Reference Application Rules

Apply references using the following policy boundaries:

- Use Fabric Interconnect model references to determine recommended physical port mappings.
- Use device connection references to determine recommended connection settings for attached endpoint types.
- Use Cisco Validated Designs to determine physical-level port policy guidance.
- Do not use the physical port policy layer to define VLANs or VSANs.
- Keep VLAN, VSAN, QoS, and workload-specific behavior in the solution policy layer.

## Core Rules

1. Query the device or Intersight API to determine:
   - model
   - role
   - reachability
   - peer relationship where applicable

2. Bind every successfully claimed device to the correct Intersight organization and resource group for its site.

3. Use derived model and role to select:
   - Domain Profile physical port mapping based on FI model
   - device connection settings based on connected device role
   - physical port policies based on Cisco Validated Designs
   - server profile policy recommendations based on solution, server role, and usage type
   - solution-layer recommendations based on solutions attached to the deployment

4. Do not derive model or role from unsupported assumptions.

5. Keep physical infrastructure policy separate from higher-level solution policy.

6. Support multi-site and multi-fabric execution using a shared input model and site-specific outputs.

7. Flag any unreachable or partially discovered device explicitly in the outputs.

## Onboarding Assumptions

The solution must support onboarding scenarios in which:

- only serial numbers, management IPs, and device-type hints are initially available
- management IP may be missing for devices discovered through a parent system
- Intersight organization is already known
- resource group may be known per site
- Assist or PVA targets may be available
- input may provide a subnet to scan rather than a fixed list of IPs

## Phase Model

### 1. Plan

Generate a master YAML plan that captures:

- site context
- deployment context
- serial number
- management IP
- organization
- resource group
- device inventory
- logical device relationships
- Assist or PVA paths
- inputs required for later policy selection

The Plan phase must prepare the data required to support later reference-driven decisions, especially Fabric Interconnect model and device role.

### 2. Onboard

Prepare and claim devices by:

- validating bootstrap prerequisites such as IP, DNS, NTP, and proxy
- claiming devices into Intersight
- binding devices to the correct organization and resource group
- deploying Assist or PVA paths where needed
- validating onboarded state against the plan

### 3. Configure

Translate abstract intent into platform-specific configuration by:

- applying server, fabric, and network policies using derived model and role
- applying FI model-based physical port mappings
- applying physical-level port policies
- keeping VLAN and VSAN logic outside the FI physical mapping layer

### 4. Deploy

Generate execution artifacts such as:

- Terraform snippets for Intersight
- Ansible playbooks for Nexus
- Ansible playbooks for MDS
- ordered execution dependencies
- per-site deployment outputs

### 5. Validate and Operate

Generate validation and operations content such as:

- onboarding completeness checks
- VLAN consistency checks
- NTP synchronization checks
- firmware compliance checks
- physical policy consistency checks
- Day-2 operations guidance
- scaling workflows

## Output Requirements

### Master YAML Plan

The master YAML plan must include:

- input serial number and management IP
- site context
- deployment context
- derived model and role
- organization and resource group mapping
- onboarding path

### Functional Outputs

#### Infrastructure Outputs

- CLI-oriented preparation guidance
- Ansible-oriented preparation guidance
- physical connectivity guidance
- physical port policy guidance

#### Platform Outputs

- Terraform outputs
- API-based outputs for SaaS or PVA workflows
- claim workflows
- organization and resource group mappings
- domain policy outputs
- server profile outputs

#### Solution Outputs

- validation scripts
- runbooks
- CI/CD-oriented workflow guidance
- site-specific operational checks

## Required Mappings

The generated solution must clearly show:

- mapping from the master plan to functional outputs
- mapping from functional area to catalog entry selection
- mapping from FI model to recommended port mapping
- mapping from connected device role to recommended device connection settings
- mapping from solution to solution-layer recommendations

## Constraints

- All derived values must be based on valid evidence, not unsupported assumptions.
- Unreachable devices must be clearly identified.
- Multi-site and multi-fabric best practices must be preserved.
- Physical FI policy guidance must remain separate from VLAN, VSAN, QoS, and workload-specific policy definitions.

## Expected Outcome

The final result should behave like a repeatable architecture-to-automation specification that can drive planning, onboarding, configuration, deployment, and operational validation for Cisco infrastructure across different sites and deployment patterns.

## Glossary

- `Deployment`
  The infrastructure unit of execution used by the automation engine. A deployment represents the infrastructure boundary against which inputs, catalog selections, and automation outputs are resolved.

- `Infrastructure Pattern`
  An automation hint that tells the platform which infrastructure-style defaults or deployment behavior to prefer, such as `flexpod`, `standalone_ucs`, or other supported patterns. It is not the deployment identity itself.

- `Input Source`
  A logical source of customer-provided data consumed by the automation engine. An input source may be hosted on local or remote storage and may contain deployment data, defaults, inventory, credentials references, and metadata.

- `Solution`
  A logical solution context that consumes part of a deployment and guides policy and catalog selection, such as VAST Data, Oracle RAC, Nutanix, DDN, OpenShift, or similar supported patterns.

- `Infrastructure Inputs`
  Customer-provided inputs related to physical inventory, device facts, addressing, connectivity context, and optional physical-level overrides.

- `Platform Inputs`
  Customer-provided inputs related to Intersight and other platform-management context, such as organization, resource group, Assist, PVA, and claim-related information.

- `Solution Inputs`
  Customer-provided inputs related to the logical solutions attached to a deployment, including solution goals, workload grouping, server assignments, usage, and other solution-specific requirements.

- `Functional Area`
  The output area used to organize catalog entries and rendered outputs. Current areas include infrastructure, platform, and solution.

- `Catalog`
  The structured set of YAML-based entries used by the automation engine to resolve recommended mappings, policy selections, workflow content, and rendered outputs.

- `Automation System Defaults`
  The baseline logic, references, catalog content, policy mappings, and model/profile logic owned by the automation platform and used as fallback during resolution.

- `Customer Overrides`
  Customer-provided scoped data that refines or overrides broader defaults for a deployment.

- `Server Role`
  The broad logical role assigned to a server or server family for policy selection, such as compute, storage, or GPU.

- `Usage Type`
  The way a server role is used within a given solution, such as controller, management, automation, training, inference, or other customer-defined usage patterns.

- `Selectors`
  The matching attributes used to determine whether a catalog entry applies, such as solution, model, server role, usage type, site, or deployment.

- `Rendered Values`
  The output content produced after catalog selection, such as port maps, policy references, validation steps, runbooks, or workflow instructions.
