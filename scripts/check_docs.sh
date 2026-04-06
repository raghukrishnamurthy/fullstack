#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_paths=(
  "README.md"
  "CONTRIBUTING.md"
  "docs/README.md"
  "docs/getting-started.md"
  "docs/implementation-notes.md"
  "docs/catalog_ui.md"
  "docs/wiring-table.md"
  "docs/blueprint_test_inputs.md"
  "prompts/infrastructure-prompt-spec.md"
  "references/README.md"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "missing required path: $path" >&2
    exit 1
  fi
done

stale_patterns=(
  "Prompts\\.md"
  "Prompts_v2_Architecture\\.md"
  "references/intersightdocs/"
)

target_files=(
  "README.md"
  "CONTRIBUTING.md"
  "docs"
  "prompts"
  "references/README.md"
)

for pattern in "${stale_patterns[@]}"; do
  if rg -n "$pattern" "${target_files[@]}" >/dev/null 2>&1; then
    echo "stale reference found for pattern: $pattern" >&2
    exit 1
  fi
done

echo "docs check ok"
