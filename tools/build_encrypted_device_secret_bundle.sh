#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <bundle-dir> <output.enc> <bundle-key>" >&2
  exit 1
fi

bundle_dir="$1"
output_path="$2"
bundle_key="$3"

if [[ ! -d "$bundle_dir" ]]; then
  echo "bundle dir not found: $bundle_dir" >&2
  exit 1
fi

tmp_archive="$(mktemp /tmp/device-secret-bundle.XXXXXX.tar.gz)"
trap 'rm -f "$tmp_archive"' EXIT

tar -C "$bundle_dir" -czf "$tmp_archive" .
openssl enc -aes-256-cbc -pbkdf2 -pass "pass:${bundle_key}" -in "$tmp_archive" -out "$output_path"
echo "$output_path"
