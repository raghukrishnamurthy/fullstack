# Contributing

Use these repo conventions to keep the structure predictable:

- Put active implementation guides in `docs/`.
- Put canonical prompt specifications in `prompts/`.
- Put non-runtime source material in `references/`.
- Keep runnable sample inputs in `examples/`.
- Keep staged or packaged workflow assets in `assets/`.
- Keep user-facing blueprints in `blueprints/`.
- Keep reusable automation and grain logic in `ansible/`.

Documentation and contract guidance:

Naming conventions:

- Use `kebab-case` for repo paths and document file names under `blueprints/`, `ansible/`, `docs/`, `prompts/`, and `references/`.
- Keep executable helper scripts in `scripts/` as `snake_case` to match the current runner pattern.
- Use `snake_case` for blueprint input keys, exported output keys, structured payload fields, and grain identifiers shown inside YAML or JSON contracts.
- When one concept appears in both a file path and a data contract, keep the path `kebab-case` and the contract key `snake_case`.

- Prefer JSON-string blueprint inputs for Torque-facing nested payloads.
- Keep YAML-shaped contracts internal to automation layers unless a file-based input is clearly better.
- Use the repo root `README.md` as the entry point, and link out to `docs/README.md`, `prompts/`, and `references/` from there.

Generated and local-only files:

- Do not commit generated runtime outputs such as `torque-outputs.json` unless they are intentionally versioned fixtures.
- Keep vendor snapshots and large reference artifacts under `references/`.
- Avoid mixing in-progress local example edits with structural repo cleanup unless they are part of the same change.
- Run `./scripts/check_docs.sh` after moving or renaming top-level documentation paths.
