#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

bash ./scripts/check_docs.sh
bash ./scripts/check_blueprints.sh

echo "repo check ok"
