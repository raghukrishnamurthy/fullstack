# Profile Template Async Pattern

## Purpose

Capture the common asynchronous lifecycle pattern that appears across
Intersight-managed profile families, especially:

- chassis profiles
- server profiles
- later profile-driven flows such as OS install adjacent operations

This note is intended to normalize the abstraction before deeper
implementation work continues.

## Why This Matters

Cisco and Qali both point toward templates as the preferred shared-object
model.

That means the practical control flow is usually not:

- create one fully independent profile per target and manage each in isolation

It is more often:

1. create a shared profile template
2. attach shared policies to the template
3. derive target-specific profiles from the template
4. reconcile template changes to the derived profiles
5. deploy only the derived profiles that actually need deployment

This creates a reusable pattern across profile families.

## Core Object Model

### Shared Source

- `*ProfileTemplate`

Examples:

- `chassis.ProfileTemplate`
- `server.ProfileTemplate`

### Derived Target

- `*Profile`

Examples:

- `chassis.Profile`
- `server.Profile`

### Target Association

Derived profiles may carry direct target binding, for example:

- `AssignedChassis`
- `AssignedServer`

## Common Lifecycle Pattern

The working reference pattern from Qali is:

1. create template
2. attach policies to template
3. derive profiles using `BulkMoCloner`
4. optionally push later template changes to derived profiles using
   `BulkMoMerger`
5. inspect each derived profile for pending-change state
6. deploy only the derived profiles that need deployment
7. wait for clean profile state

Useful references:

- [chassis_profile_template.py](/Users/rkrishn2/workspaces/qali/qa_tests/utils/api/lib/imm/managed_chassis/chassis_profile_template.py)
- [chassis_profile.py](/Users/rkrishn2/workspaces/qali/qa_tests/utils/api/lib/imm/managed_chassis/chassis_profile.py)
- [server_profile_template.py](/Users/rkrishn2/workspaces/qali/qa_tests/utils/api/lib/sars/server_profile_template.py)
- [profile.py](/Users/rkrishn2/workspaces/qali/qa_tests/utils/api/lib/sars/profile.py)

## Internal vs External Validation

### Internal Validation

Internal validation is used inside the provisioning phase when:

- the phase itself triggered the async action
- the phase expects the result within a manageable time window
- the object family exposes profile-state metadata

Internal validation should usually be:

- profile-state first
- workflow-aware when available

### External Validation

External validation is used when:

- convergence may take longer
- the object family does not expose stable workflow references
- later phases need a durable readiness contract

External validation should be based on final object state, not transient
workflow state.

## Profile State Abstraction

For profile families, the primary async signal should be:

- `ConfigContext.ConfigState`

And when available, also:

- `ConfigContext.ConfigStateSummary`
- `ConfigContext.InconsistencyReason`
- `ConfigChanges`
- `ConfigChangeDetails`
- `PolicyChangeDetails`

### Important Nuance

`ConfigState` alone is not always sufficient.

A profile may be:

- `Associated`
- `Assigned`

while still exposing pending or inconsistency information through other
fields.

So the reusable internal profile-state abstraction should consider:

1. `ConfigContext.ConfigState`
2. `ConfigContext.InconsistencyReason`
3. pending-change detail fields when present

## Working State Model

Based on Qali references, the meaningful profile states include:

- `Associated`
- `Assigned`
- `Not-assigned`
- `Pending-changes`
- `Inconsistent`
- `Out-of-sync`
- `Failed`
- sometimes transient `Validating`

### Practical Interpretation

- `Associated`
  - clean deployed success
- `Assigned`
  - target attached, deploy may still be needed
- `Not-assigned`
  - profile exists but target not attached
- `Pending-changes`
  - deploy required
- `Inconsistent`
  - activation, disruption, or drift condition exists
- `Out-of-sync`
  - drifted from intended state
- `Failed`
  - terminal failure
- `Validating`
  - transient state during policy/profile validation

## Pending-Change Driven Deploy

The important reusable rule is:

- do not blindly deploy every derived profile on every run
- inspect each derived profile
- deploy only the ones that are actually in a pending-change state

Qali’s chassis and server helpers both reinforce this pattern.

For a generalized implementation, pending deploy should be inferred from:

- `ConfigContext.ConfigState == Pending-changes`
or
- `InconsistencyReason` containing pending-change semantics

This is better than treating every assignment or template reconciliation as a
mandatory deploy.

## Workflow Usage

Workflow tracking is useful, but not universal.

### Use Workflow Signals When Available

- returned `WorkflowInfo`
- `RunningWorkflows`
- `ScheduledActions`

### Do Not Depend On Workflow IDs Universally

Not every object or action exposes a durable `WorkflowInfo` reference.

So the correct generalized rule is:

- object/profile state is the primary async contract
- workflow metadata is supplemental debug and handoff context

## Recommended Shared Abstractions

The implementation should eventually normalize around:

- `template_realization`
- `derived_profile_reconciliation`
- `profile_async_state_check`

### `template_realization`

Responsible for:

- creating the template
- attaching policies to the template
- exporting template identity

### `derived_profile_reconciliation`

Responsible for:

- deriving profiles for targets
- merging template updates into derived profiles
- resolving target assignment details

### `profile_async_state_check`

Responsible for:

- reading `ConfigContext`
- detecting pending changes
- deciding whether deploy is needed
- waiting for clean terminal profile state

## Immediate Guidance For Current Phases

### Chassis Resources

Chassis resource provisioning should move toward:

- shared `chassis.ProfileTemplate`
- shared policy attachment on the template
- derived `chassis.Profile` per chassis
- deploy only when derived profile state indicates pending changes

### Server Resources

Server profile provisioning should follow the same template pattern:

- shared `server.ProfileTemplate`
- derived `server.Profile`
- pending-change driven deploy and activation

### OS Install and Similar Flows

These likely remain profile-driven but may use workflow/task tracking more
heavily as an internal validator.

Even there, external validation should still rely on durable object state.

## Current Decision

The preferred direction is:

- use templates as the shared source object model
- use derived profiles as target objects
- use profile-state based internal validation
- use object-state based external validation
- use workflow information only as supplemental async context
