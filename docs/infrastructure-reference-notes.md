# Infrastructure Reference Notes

## Purpose

Capture the main product and implementation references used while shaping:

- `infrastructure-network-provisioning`
- `infrastructure domain validator`
- future `infrastructure-resource-provisioning`

This note is intentionally lightweight. It is a working reference index, not a
full design spec.

## Cisco Intersight Documentation

### Configure Views

- Fabric Interconnects
  - [Intersight Help - Configure Fabric Interconnects](https://intersight.com/help/saas/configure/fabric_interconnects)
- Unified Edge
  - [Intersight Help - Configure Unified Edge](https://intersight.com/help/saas/configure/unified_edge)
- Servers
  - [Intersight Help - Configure Servers](https://intersight.com/help/saas/configure/servers)

### Operate Views

- Servers
  - [Intersight Help - Operate Server](https://intersight.com/help/saas/operate/server)
- Chassis
  - [Intersight Help - Operate Chassis](https://intersight.com/help/saas/operate/chassis)
- Fabric Interconnects
  - [Intersight Help - Operate Fabric Interconnects](https://intersight.com/help/saas/operate/fabric_interconnects)
- Unified Edge
  - [Intersight Help - Operate Unified Edge](https://intersight.com/help/saas/operate/unified_edge)

### Checklists And Product Guides

- Chassis-focused checklist
  - [Cisco Intersight Managed Mode Checklist - UCS Chassis](https://cdn.intersight.com/components/an-hulk/1.0.11-20251212114743580/docs/cloud/data/resources/IMM/en/IMM_Checklist.pdf)
- Server-focused checklist
  - [Cisco Intersight Managed Mode Checklist - UCS Server](https://cdn.intersight.com/components/an-hulk/1.0.11-20250808063115446/docs/cloud/data/resources/IMM/en/IMM_Checklist.pdf)
- Workload Optimizer target guide
  - [Cisco Intersight Workload Optimizer User and Target Guide](https://cdn.intersight.com/components/an-hulk/1.0.11-20250919091156391/docs/cloud/data/resources/iwo/en/Cisco_Intersight_Workload_Optimizer_User_and_Target_Guide.pdf)

## Local Implementation References

### Domain Profile

- Tested domain profile deployment workspace
  - [/Users/rkrishn2/Documents/domain_profile](/Users/rkrishn2/Documents/domain_profile)
- Main deployment playbook
  - [playbook.yaml](/Users/rkrishn2/Documents/domain_profile/ansible/domain_profile_deployment/playbook.yaml)
- Domain policy catalog
  - [default.yaml](/Users/rkrishn2/Documents/domain_profile/catalog/domain_profile_policies/default.yaml)

### Qali

- Domain profile deployment workflow
  - [imm_domainprofile_deployment.py](/Users/rkrishn2/workspaces/qali/qa_tests/cicd/api/imm/imm_domainprofile_deployment.py)
- Domain profile policy workflow
  - [imm_domainprofile_policies.py](/Users/rkrishn2/workspaces/qali/qa_tests/cicd/api/imm/imm_domainprofile_policies.py)
- Chassis profile helper
  - [ucs_chassis_profiles_util.py](/Users/rkrishn2/workspaces/qali/qali-infra/qali/starship_gui/impl/profiles/ucs_chassis_profiles_util.py)
- Chassis utility/policy combinations
  - [ChassisUtils.py](/Users/rkrishn2/workspaces/qali/qa_tests/utils/sanity/api/intersight_utils/ChassisUtils.py)
- Chassis profile test flow
  - [chassis_profile.py](/Users/rkrishn2/workspaces/qali/qa_tests/user_stories/common_lab_tests/api/imm/managed_chassis/chassis_profile/chassis_profile.py)
- Chassis policy creation flow
  - [create_policies.py](/Users/rkrishn2/workspaces/qali/qa_tests/user_stories/common_lab_tests/api/imm/managed_chassis/chassis_profile/create_policies.py)
- Example chassis defaults and variants
  - [parameters_gershwin.py](/Users/rkrishn2/workspaces/qali/qa_tests/cicd/api/imm/gershwin/parameters_gershwin.py)
  - [parameters_excalibur.py](/Users/rkrishn2/workspaces/qali/qa_tests/cicd/api/imm/excalibur/parameters_excalibur.py)
- Device readiness workflow
  - [devicesreadiness.py](/Users/rkrishn2/intersightztp/devicesreadiness.py)

### Ansible Plugins

- Intersight power policy module
  - [intersight_power_policy.py](/Users/rkrishn2/ansible_plugins/intersight-ansible/plugins/modules/intersight_power_policy.py)
- Intersight thermal policy module
  - [intersight_thermal_policy.py](/Users/rkrishn2/ansible_plugins/intersight-ansible/plugins/modules/intersight_thermal_policy.py)
- Intersight domain-profile-style playbook reference
  - [intersight_domain_profile.yml](/Users/rkrishn2/ansible_plugins/intersight-ansible/playbooks/intersight_domain_profile.yml)

## Current Takeaways

- FI-side shared domain policy work belongs in `infrastructure-network-provisioning`.
- Chassis profile and later server-side policy work belongs in
  `infrastructure-resource-provisioning`.
- Validator phases should use onboarding inventory as expectation and live
  Intersight data as source of truth.
- Chassis-profile first cut is currently:
  - `Power`
  - `Thermal`
- Later chassis-profile candidates:
  - `IMC Access`
  - `SNMP`

## Useful Runtime Attributes To Revisit

### Fabric Interconnects

- `Serial`
- `Operability`
- `SwitchId`
- `DeviceMoId`
- `ManagementMode`

### Chassis

- `Serial`
- `OperState`
- `ConnectionStatus`
- `ManagementMode`
- `ChassisId`
- `Blades`
- `Ioms`

### Servers / Blades / Racks

- `Serial`
- `Lifecycle`
- `ManagementMode`
- `Presence`
- `OperPowerState`
- `InventoryParent`
- `EquipmentChassis`
- `SourceObjectType`
