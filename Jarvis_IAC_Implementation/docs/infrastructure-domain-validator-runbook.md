**Purpose**
This runbook captures the current local validation path for
`infrastructure domain validator`.

Use it to:

- validate FI-domain inventory readiness after
  `infrastructure-network-provisioning`
- compare onboarding inventory expectations with live Intersight state
- debug readiness output without going through Torque first

**Current V1 Readiness Gate**
The current blocking object families are:

- Fabric Interconnects
- Chassis count / presence
- Blades

These families are observed but advisory in the current slice:

- FI-managed racks
- Standalone racks

**Live Truth**
- onboarding inventory is the expected model
- live Intersight data is the source of truth

The validator should not require previous phase outputs for correctness.

**Primary Inputs**
The playbook expects wrapped YAML strings for:

- `deployment_yaml`
- `platform_yaml`
- `placement_yaml`
- `inventory_yaml`
- optional `site_yaml`

Useful runtime controls:

- `validation_mode`
- `wait_for_readiness`
- `readiness_poll_interval`
- `readiness_max_attempts`
- `execution_intent`
- `lifecycle_action`

**Current Live Rules**
- FI
  - query `/network/Elements`
  - ready when `Operability == online`
- Chassis
  - query `/equipment/Chasses`
  - ready when discovered chassis count is at least expected chassis count
- Blade
  - query `/compute/PhysicalSummaries`
  - ready when `Lifecycle == Active`

Observed but nonblocking:

- standalone rack live sample shows `ManagementMode == IntersightStandalone`
- FI-managed rack blocking rule is deferred until more live samples are
  validated

**Outputs**
Top-level outputs:

- `phase_ready`
- `phase_status`
- `phase_readiness_json`

Supporting outputs:

- `validation_summary_json`
- `inventory_validation_json`
- `tac_handoff_json`

`inventory_validation_json` and `tac_handoff_json` should include:

- `blocking_scope`
- `advisory_scope`

**Local Run Example**
Example local run shape:

```bash
ANSIBLE_LOCAL_TEMP=/tmp/infrastructure-domain-validator \
ANSIBLE_REMOTE_TEMP=/tmp/infrastructure-domain-validator \
ansible-playbook \
  /Users/rkrishn2/Documents/Jarvis_IAC/Jarvis_IAC_Implementation/ansible/validate_infrastructure_domain_inventory/playbook.yaml \
  -e @/tmp/infrastructure-domain-validator-proof-vars.yaml
```

The proof vars file should contain direct or env-resolved Intersight
credentials plus the wrapped deployment/platform/placement/inventory/site YAML
inputs.

**Current Verified Result**
The validator has been exercised live against the AI Pod environment and now
correctly:

- matches FI serials from inventory
- matches blade serials from inventory
- compares expected chassis count against discovered chassis count

In the current proof path:

- FI and blades match successfully
- standalone racks may still appear as missing, but they do not block
  `phase_ready` in this first slice

**Implementation Notes**
- avoid recursive self-reference in Ansible facts
- build current-pass facts first, then assign `validator_summary`
- prefer explicit serial prefix/suffix filter construction over regex
  backreference forms for Intersight queries
- keep recursive polling in the included task flow, not in a task-local loop
