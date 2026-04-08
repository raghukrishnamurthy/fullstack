# realize_infrastructure_network_policies

Policy realization grain for `infrastructure-network-provisioning`.

This grain creates or reconciles the initial shared physical/domain policy set:

- `port_policy`
- `switch_control_policy`
- `system_qos_policy`
- `ntp_policy`
- `network_connectivity_policy`

The current implementation assumes a single FI-pair domain per deployment while
the broader multi-domain realization model is still being refined.
