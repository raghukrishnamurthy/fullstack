# Nested Blueprint Chaining Experiment

## Goal

Validate whether Torque can chain outputs across nested blueprints cleanly, especially when the nested child blueprint is backed by different grain types.

## Experiments

### 1. Ansible-backed child blueprint

Files:
- `blueprints/experiment-blueprint-chain-producer.yaml`
- `blueprints/experiment-blueprint-chain-consumer.yaml`
- `blueprints/experiment-blueprint-chain-parent.yaml`
- `blueprints/experiment-blueprint-chain-parent-producer-only.yaml`

Purpose:
- prove child blueprint execution
- test whether nested child blueprint outputs are materialized before being passed to another nested child or surfaced on the parent blueprint

Observed result:
- child blueprint executes
- parent references use the documented syntax
- nested child blueprint output values appear to surface as unresolved literals rather than resolved values

### 2. Shell-backed child blueprint

Files:
- `blueprints/experiment-blueprint-chain-producer-shell.yaml`
- `blueprints/experiment-blueprint-chain-parent-producer-only-shell.yaml`

Purpose:
- compare nested output behavior for a non-Ansible child blueprint

Observed result:
- shell grain ran, but the current output-export mechanism used in the experiment was not valid in Torque runtime
- this path is not yet a conclusive comparison

### 3. Terraform-backed child blueprint

Files:
- `assets/terraform/blueprint-chain-producer-tf/main.tf`
- `blueprints/experiment-blueprint-chain-producer-terraform.yaml`
- `blueprints/experiment-blueprint-chain-parent-producer-only-terraform.yaml`

Purpose:
- compare nested output materialization using the same pattern found in working sample repositories, where nested child blueprint outputs come from terraform grains

Expected result:
- if parent outputs resolve correctly here, the nested blueprint limitation is likely specific to ansible-backed child blueprint outputs
- if parent outputs still surface unresolved literals, the limitation is broader than ansible
