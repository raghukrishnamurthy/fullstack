# Cisco Infrastructure Prompt Specification

## Purpose

Define the canonical deterministic prompt specification for generating structured Infrastructure-as-Code outputs for Cisco-based infrastructure deployments.

This specification separates:

- infrastructure onboarding
- solution profile
- extension
- delivery scope

The model must allow infrastructure to be discovered, validated, claimed, and onboarded based on declared or discovered devices first, without requiring the deployment to be labeled as FlexPod, FlashStack, Nutanix, AI Pod, VAST Data, Secure AI Factory, or similar at the infrastructure-input stage.

## Reference Files

Use the following files as reference examples for customer-provided input structure and example values:

- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/inputs/deployments/sjc01-infra-converged-prod/deployment.yaml`
- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/inputs/deployments/sjc01-infra-converged-prod/platform.yaml`
- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/inputs/deployments/sjc01-infra-converged-prod/inventory.yaml`
- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/inputs/deployments/sjc01-infra-converged-prod/pools.yaml`
- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/inputs/deployments/sjc01-infra-converged-prod/solution.yaml`
- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/inputs/deployments/sjc01-infra-standalone-prod/deployment.yaml`
- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/inputs/deployments/sjc01-infra-standalone-prod/platform.yaml`
- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/inputs/deployments/sjc01-infra-standalone-prod/inventory.yaml`
- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/inputs/deployments/sjc01-infra-standalone-prod/solution.yaml`
- `/Users/rkrishn2/Documents/Jarvis_IAC/references/model-examples/catalog/solution_intents/catalog-map.yaml`

These files are reference examples, not proof that the current schema is final.

## Assigned Role

Act as a Cisco infrastructure architect and automation expert.

The response must reflect deterministic reasoning, evidence-based derivation, strong separation of concerns, and clear distinction between infrastructure facts, solution profile, extension, and delivery scope.

## Objective

Generate a deterministic, policy-driven Infrastructure-as-Code solution that:

- supports one or more sites
- supports one or more infrastructure groupings
- supports one primary solution profile per deployment
- derives infrastructure behavior from devices and topology
- derives solution behavior from catalog-selected or customer-selected solution profile
- separates infrastructure onboarding from higher-layer solution behavior
- preserves repeatable outputs across environments

## Core Model

The design must separate four layers:

1. inventory facts
2. solution profile
3. extension
4. delivery scope

### Inventory Facts

Inventory facts describe what physically exists or how it is connected.

Examples include:

- fabric interconnects
- servers
- storage systems
- Ethernet switches
- SAN switches
- serial numbers
- management IP addresses
- peer relationships
- parent relationships
- hardware attributes

Inventory facts are the primary basis for infrastructure onboarding and infrastructure classification.

### Solution Profile

A solution profile describes the intended integrated deployment profile.

A solution profile may imply:

- expected device composition
- baseline infrastructure behavior
- base software or OS direction
- policy and catalog defaults
- validated deployment expectations

Examples include:

- `flexpod`
- `flashstack`
- `nutanix`
- `vast_data`
- `ai_pod`
- `secure_ai_factory`

### Extension

An extension is an optional higher-layer platform or software construct applied on top of a base solution profile.

Examples include:

- `openshift`
- `kubernetes`
- `slurm`
- `nvidia_ai_enterprise`
- `oracle_rac`

### Delivery Scope

Delivery scope defines how far automation should proceed.

Examples include:

- `onboarding`
- `network_infra_provisioning`
- `server_infra_provisioning`
- `os_provisioning`
- `platform_provisioning`
- `app_provisioning`

## Customer Launch Input Model

The customer launch input model is the user-facing contract exposed through Torque or another catalog workflow.

It should be minimal, guided, and business-friendly.

A catalog item may implicitly provide:

- default solution profile
- default extension
- default delivery scope
- workflow selection
- default policy behavior
- default validation behavior

The customer should provide only deployment-specific values required for the run.

## Automation Execution Input Model

The automation execution input model is the fully resolved contract consumed by blueprints, grains, Terraform, Ansible playbooks, APIs, and downstream orchestration.

It may combine:

- customer launch inputs
- deployment-scoped inputs
- site-scoped defaults
- global defaults
- catalog-selected defaults
- baseline defaults
- resolved references
- derived infrastructure classification
- resolved policy and workflow selections

The execution model must preserve separation between inventory facts, solution profile, extension, and delivery scope.

## Infrastructure Classification Rules

Infrastructure classification must be derived from evidence, not unsupported labels.

The automation engine should determine infrastructure shape from:

- device categories present
- serial-number-resolved device types when available
- management-plane reachability context
- FI presence or absence
- FI peer relationships
- server parent relationships
- attached storage devices
- attached network devices
- topology hints
- platform-management context

Examples of derived infrastructure classifications include:

- `standalone_rack_servers`
- `standalone_gpu_cluster`
- `fi_managed_compute_domain`
- `converged_compute_network_storage`
- `storage_attached_compute`
- `mixed_mode_infrastructure`

These are infrastructure facts, not solution profiles.

If evidence is incomplete, the automation engine should preserve the observed facts, identify missing evidence, and avoid unsupported assumptions.

## Solution Profile and Extension Rules

Solution profile and extension are higher-level intent layers applied on top of inventory facts and infrastructure classification.

They must not replace or distort physical infrastructure facts.

### Solution Profile Rule

Use `solution.profile` for the primary integrated deployment profile.

### Extension Rule

Use `solution.extension` for the primary optional higher-layer addition.

The current model uses a single `solution.extension` value.

It does not require an `extensions:` list at this time.

## Single Solution Model

The current model uses a single `solution:` object.

The selected `solution.profile` defines the primary integrated deployment profile for the deployment.

The model does not require a multi-solution `solutions:` list at this time.

Variants within a selected solution profile should be represented as solution-specific parameters rather than separate solution entries.

Examples include:

- Nutanix hypervisor choice
- profile-specific deployment mode
- implementation-specific variant selection

Example:

```yaml
solution:
  profile: nutanix
  delivery_scope: os_provisioning
  parameters:
    hypervisor: ahv
```

## Solution Goal Rule

The current model may include an optional `solution.goal` field.

`solution.goal` provides additional descriptive or workflow-guidance intent for the selected solution profile.

It is a secondary field.

It must not replace `solution.profile`, `solution.extension`, `solution.delivery_scope`, or `solution.parameters`.

## Delivery Scope Rules

Delivery scope defines the automation boundary for a deployment.

It tells the automation system how far execution should proceed for the selected solution profile and optional extension.

The same deployment may have:

- the same inventory
- the same infrastructure classification
- the same solution profile
- the same extension

but a different delivery scope.

This means delivery scope must remain a separate field.

A catalog blueprint may:

- fix delivery scope implicitly
- offer delivery scope as a user-selectable value
- restrict supported delivery scopes for a given solution profile
- apply defaults based on the selected offering

If delivery scope is fixed by the catalog item, the customer does not need to provide it again.

## Output Requirements

Automation outputs must remain structured, deterministic, and clearly separated by function.

Outputs should reflect the distinction between:

- infrastructure facts and onboarding results
- platform-management outputs
- solution-profile-driven outputs
- extension-driven outputs
- delivery-scope-driven outputs

The resulting output set should remain organized around these areas:

- deployment outputs
- infrastructure outputs
- platform outputs
- solution outputs
- extension outputs
- delivery-scope outputs

Outputs should clearly show:

- which values came directly from customer inputs
- which values came from catalog defaults
- which values were derived from inventory or topology
- which values were selected from baselines or mappings
- which outputs were omitted because of delivery-scope boundaries

## Recommended Data Structure

The automation data model should remain organized around three major areas:

- `baselines/`
- `catalog/`
- `inputs/`

### Area Meanings

- `baselines/`
  automation-owned reusable baseline content
- `catalog/`
  selectable solution and extension logic
- `inputs/`
  customer-provided deployment data and customer-scoped defaults

### Recommended Logical Structure

```text
baselines/
  fi_models/
  port_layouts/
  domain_policies/
  server_profiles/
  infrastructure_classification/

catalog/
  solution_profiles/
  extensions/
  server_profile_policies/
  validation_checks/
  workflow_maps/

inputs/
  global/
  sites/
  deployments/
```

### Deployment-Level Input Structure

A deployment-level input bundle may contain files such as:

```text
inputs/
  deployments/
    <deployment-id>/
      deployment.yaml
      platform.yaml
      inventory.yaml
      pools.yaml
      solution.yaml
      overrides.yaml
      references.yaml
```

Not every deployment must use every file.

The automation engine should support partial bundles and scoped inheritance when the workflow allows it.

## Glossary

### Deployment

The unit of execution that defines the scope of a run.

### Inventory Facts

The physical and topological facts that describe what infrastructure exists.

### Infrastructure Classification

A derived description of the physical infrastructure shape based on inventory facts, topology, and approved references.

### Platform Context

The management-plane and control-plane context used to operate, validate, claim, or provision the deployment.

### Solution Profile

The primary integrated deployment profile that describes the intended base solution outcome.

### Extension

An optional higher-layer platform or software construct applied on top of a base solution profile.

### Delivery Scope

The automation boundary that defines how far execution should continue for the selected solution profile and optional extension.

### Customer Launch Input Model

The user-facing input contract exposed through Torque or another catalog workflow.

### Automation Execution Input Model

The fully resolved, automation-ready contract consumed by blueprints, grains, Terraform, Ansible, APIs, and downstream orchestration.

## End-to-End Example

```yaml
deployment:
  id: sjc01-ai-prod
  site: sjc01
  environment: production

platform:
  intersight:
    organization: ai-prod
    resource_group: rg-sjc01-ai

inventory:
  devices:
    - id: gpu-node-01
      serial: ABC123
      category: server
      attributes:
        form_factor: rack
        accelerator_profile: gpu
    - id: gpu-node-02
      serial: ABC124
      category: server
      attributes:
        form_factor: rack
        accelerator_profile: gpu
    - id: leaf-a
      serial: N9K001
      category: ethernet_switch

solution:
  profile: secure_ai_factory
  extension: openshift
  goal: gpu_platform_deployment
  delivery_scope: platform_provisioning
```

Interpretation:

- inventory facts describe the actual devices
- infrastructure classification is derived from those facts
- `secure_ai_factory` describes the intended integrated solution profile
- `openshift` is an optional higher-layer extension
- `platform_provisioning` defines how far automation should proceed
