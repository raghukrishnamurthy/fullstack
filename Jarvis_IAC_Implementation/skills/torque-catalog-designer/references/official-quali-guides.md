# Official Quali Torque Guides

These are the external references to use when designing Torque catalog items and blueprints:

- [Torque Blueprint Automation Best Practices (PDF)](https://www.quali.com/wp-content/uploads/2026/03/torque-best-practices.pdf)
- [Writing Torque-Ready Ansible Playbooks (PDF)](https://www.quali.com/wp-content/uploads/2026/03/torque-ready-playbooks.pdf)

## What To Reuse
- top-level `blueprints/` repo layout
- blueprint as composite workflow, grains as reusable leaf units
- explicit dependency chains for cross-grain outputs
- user-facing inputs kept smaller than internal automation contracts
- Torque-native handling of params, inputs, and credentials

## Secret/Input Guidance
- Accept secrets as Torque inputs or credentials.
- Convert them to env vars only inside wrappers when a downstream tool requires env-backed values.
