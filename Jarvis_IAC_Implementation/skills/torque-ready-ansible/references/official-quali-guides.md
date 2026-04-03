# Official Quali Torque Guides

Use these official references as the anchor for Torque behavior:

- [Torque Blueprint Automation Best Practices (PDF)](https://www.quali.com/wp-content/uploads/2026/03/torque-best-practices.pdf)
- [Writing Torque-Ready Ansible Playbooks (PDF)](https://www.quali.com/wp-content/uploads/2026/03/torque-ready-playbooks.pdf)

## Rules We Reuse Here
- Keep blueprints under top-level `blueprints/`.
- Let Torque generate inventory from the blueprint.
- Treat grain inputs as extra-vars.
- Use scalar `depends-on`.
- Keep output references on a real dependency chain.
- Avoid blueprint-side conditional routing when Torque template behavior is uncertain.
- Use `torque.collections.export_torque_outputs` on `localhost`.

## Secret Pattern
- Accept secrets as Torque params, inputs, or credentials.
- If a downstream helper expects env vars, convert resolved inputs into env vars inside a wrapper or orchestrator.
- Do not force the public Torque blueprint contract to rely on `env://...` unless that runtime behavior is already proven.
