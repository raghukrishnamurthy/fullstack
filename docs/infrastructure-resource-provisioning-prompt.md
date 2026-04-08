**Purpose**
Working implementation prompt for `infrastructure-resource-provisioning`.

```text
Implement and refine the `infrastructure-resource-provisioning` phase for Cisco Intersight IMM.

Goal:
Provision shared consumable infrastructure resources after network/domain foundation is ready and before solution-specific server-side provisioning begins.

Phase position:
1. onboarding
2. infrastructure-network-provisioning
3. infrastructure domain validator
4. infrastructure-resource-provisioning

Core rules:
- use onboarding inventory as the expected model
- use live Intersight data as the source of truth
- do not depend on previous phase outputs for correctness
- keep complex blueprint inputs JSON-first
- keep the code Torque-ready, but validate locally with plain Ansible first
- solution phases should consume shared resources from this phase instead of repeatedly mutating shared domain objects

Initial phase roadmap:
1. chassis profile provisioning
2. later CIMC / server-side resource provisioning
3. later shared logical network resource provisioning such as VLANs and VSANs

Current v1 implementation scope:
- chassis profile provisioning only

Current v1 chassis profile scope:
- chassis_power_policy
- chassis_thermal_policy

Current v1 bundle model:
- selected bundle ids:
  - default
  - recommended
- one shared Power policy per selected variant
- one shared Thermal policy per selected variant
- one shared chassis profile template per selected variant
- derive one chassis profile per discovered chassis from that template
- do not implement per-chassis overrides in v1

Current baseline values:
- default chassis power:
  - power_redundancy: Grid
  - power_save_mode: Enabled
  - dynamic_power_rebalancing: Enabled
  - extended_power_capacity: Enabled
  - power_allocation: 0
- recommended chassis power for current testing:
  - power_redundancy: N+1
  - power_save_mode: Enabled
  - dynamic_power_rebalancing: Enabled
  - extended_power_capacity: Enabled
  - power_allocation: 0
- default and recommended chassis thermal:
  - fan_control_mode: Balanced

Catalog shape:
- catalog/chassis_profile_profiles/<profile>.yaml
- catalog/chassis_profile_policies/<profile>/<policy>.yaml
- catalog/chassis_profile_policies/supported.yaml

Behavior for the first slice:
1. parse onboarding-style wrapped inputs
2. resolve Intersight credentials
3. discover live chassis targets from Intersight
4. resolve selected chassis profile bundle and policy values from catalog
5. realize shared chassis Power and Thermal policies
6. create or reconcile one shared chassis profile template
7. derive or reconcile one chassis profile per discovered chassis from that template
8. deploy only the derived profiles that actually need deployment
8. export readiness and realized state outputs

Important implementation guardrails:
- avoid recursive self-reference in Ansible facts
- keep discovery separate from realization
- prefer shared template and shared policy reuse over per-chassis policy sprawl
- only introduce per-chassis variance if a real requirement appears
- use explicit current-pass facts before constructing final summary objects
- use `ConfigContext.ConfigState` and `ConfigContext.InconsistencyReason` as the primary internal async signals for profile objects
- treat workflow information as supplemental only when it is exposed by the object/action

Success criteria:
- selected chassis profile variant resolves cleanly
- shared chassis Power and Thermal policies are realized correctly
- the shared chassis profile template is realized correctly
- all discovered chassis in scope receive the intended derived profile/policies
- reruns are no-op when profiles are already clean
- template-driven changes cause only the affected derived profiles to deploy
- outputs are suitable for later server-side resource work
```
