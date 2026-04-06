#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

blueprints=(
  "blueprints/cisco-standalone-rack-reset-password.yaml"
  "blueprints/claim-devices-to-intersight.yaml"
  "blueprints/infrastructure-onboard-devices.yaml"
  "blueprints/infrastructure-network-provisioning.yaml"
)

for blueprint in "${blueprints[@]}"; do
  ruby -e "require 'yaml'; YAML.load_file('$blueprint')" >/dev/null
done

referenced_paths="$(
  ruby <<'RUBY'
require 'yaml'

def collect_paths(node, acc)
  case node
  when Hash
    node.each do |k, v|
      acc << v if k == 'path' && v.is_a?(String)
      collect_paths(v, acc)
    end
  when Array
    node.each { |item| collect_paths(item, acc) }
  end
end

Dir['blueprints/*.yaml'].sort.each do |blueprint|
  doc = YAML.load_file(blueprint)
  paths = []
  collect_paths(doc, paths)
  paths.each do |path|
    next unless path.start_with?('ansible/', 'assets/')
    puts path
  end
end
RUBY
)"

while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  if [[ ! -e "$path" ]]; then
    echo "missing blueprint referenced path: $path" >&2
    exit 1
  fi
done <<< "$referenced_paths"

echo "blueprint check ok"
