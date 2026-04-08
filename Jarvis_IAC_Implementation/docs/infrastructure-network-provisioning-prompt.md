**Purpose**
Working implementation prompt for `infrastructure-network-provisioning`.

```text
Implement and refine the `infrastructure-network-provisioning` phase for Cisco Intersight IMM.

Goal:
Provision the shared FI-managed infrastructure network foundation needed before resource provisioning.

Scope:
- Current provider target is Intersight IMM domain behavior
- Support FI models:
  - UCS-FI-6454
  - UCS-FI-6536
  - UCS-FI-6652
  - UCS-FI-6664
- Use built-in named policy profiles for now
- Current exposed profile ids may be:
  - default
  - recommended
- Treat profile ids as names only, not hard-coded architecture semantics

Core rules:
- Intersight is the source of truth for live state
- Inventory is the expected starting model from onboarding
- Every phase after onboarding starts from inventory plus Intersight access
- Use live Intersight discovery before making provisioning decisions
- DNS and NTP should prefer `site.global_settings` when present
- Policy catalog provides fallback defaults only
- Naming comes from `name_prefix` plus fixed automation suffixes
- Keep complex blueprint inputs JSON-first
- Keep implementation shaped for future customer overrides, but do not implement override merge logic in v1

Current v1 policy scope:
- port_policy
- switch_control_policy
- system_qos_policy
- ntp_policy
- network_connectivity_policy

Current v1 port mapping scope:
- ethernet
- ethernet_fc

Behavior:
1. Resolve selected profile and model-aware defaults
2. Discover live FI/domain state from Intersight
3. Build effective model using live FI facts
4. Realize shared policies
5. Realize switch cluster profile and A/B switch profiles
6. Attach policy bucket
7. Assign discovered FIs
8. Deploy only when needed
9. Export readiness and realized state outputs

Current boundaries:
- built-in profiles only
- single-domain runtime path is acceptable for first working slice
- tagging is in scope architecturally but not implemented in v1
- teardown is deferred for coordinated lifecycle work later

Important implementation guardrails:
- avoid recursive self-reference in Ansible facts
- do not depend on stale helper var files during local reruns
- use explicit staged facts for current-pass calculations
- prefer explicit filter-string construction for Intersight queries
- keep the code Torque-ready, but validate locally with plain Ansible first

Success criteria:
- domain profile and switch profiles are created or reused correctly
- policy objects reflect site/global DNS and NTP when provided
- deploy reaches stable associated state
- outputs are suitable for the next validator phase
```
