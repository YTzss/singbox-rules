#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$repo_dir/compiled"

for source_file in "$repo_dir"/source/*.json; do
  name="$(basename "$source_file" .json)"
  sing-box rule-set format "$source_file" >/dev/null
  sing-box rule-set compile --output "$tmp_dir/$name.srs" "$source_file"
done

curl --fail --silent --show-error --location --retry 3 \
  --output "$tmp_dir/geosite-cn.srs" \
  https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-geolocation-cn.srs
curl --fail --silent --show-error --location --retry 3 \
  --output "$tmp_dir/geoip-cn.srs" \
  https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs

for compiled_file in "$tmp_dir"/*.srs; do
  test -s "$compiled_file"
  install -m 0644 "$compiled_file" "$repo_dir/compiled/$(basename "$compiled_file")"
done

echo "Compiled $(find "$repo_dir/compiled" -maxdepth 1 -name '*.srs' | wc -l) rule-sets."
