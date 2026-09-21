#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$repo_dir/compiled"

shopt -s nullglob
source_files=("$repo_dir"/source/*.json)
if ((${#source_files[@]} == 0)); then
  echo "No source rule-sets found." >&2
  exit 1
fi

proxy_source_files=()
all_rule_entries="$tmp_dir/all-rule-entries.tsv"
: >"$all_rule_entries"

for source_file in "${source_files[@]}"; do
  name="$(basename "$source_file" .json)"

  jq -e '
    type == "object" and
    .version == 5 and
    (.rules | type == "array" and length > 0)
  ' "$source_file" >/dev/null
  sing-box rule-set format "$source_file" >/dev/null
  sing-box rule-set compile --output "$tmp_dir/$name.srs" "$source_file"

  jq -r --arg source "$name" '
    .rules[] |
    to_entries[] |
    select(.key == "domain" or
           .key == "domain_suffix" or
           .key == "domain_keyword" or
           .key == "domain_regex" or
           .key == "ip_cidr") |
    .key as $kind |
    .value[]? |
    select(type == "string" and length > 0) |
    [$kind, ascii_downcase, $source] | @tsv
  ' "$source_file" >>"$all_rule_entries"

  if [[ "$name" != "direct-cn" ]]; then
    proxy_source_files+=("$source_file")
  fi
done

duplicate_rules="$tmp_dir/duplicate-rules.txt"
cut -f1,2 "$all_rule_entries" | sort | uniq -d >"$duplicate_rules"
if [[ -s "$duplicate_rules" ]]; then
  echo "Duplicate rule entries found:" >&2
  cat "$duplicate_rules" >&2
  exit 1
fi

if ((${#proxy_source_files[@]} == 0)); then
  echo "No proxy service source rule-sets found." >&2
  exit 1
fi

proxy_services_source="$tmp_dir/proxy-services.json"
jq -s '{version: 5, rules: [.[].rules[]]}' \
  "${proxy_source_files[@]}" >"$proxy_services_source"
jq -e '.rules | type == "array" and length > 0' \
  "$proxy_services_source" >/dev/null
sing-box rule-set format "$proxy_services_source" >/dev/null
sing-box rule-set compile \
  --output "$tmp_dir/proxy-services.srs" \
  "$proxy_services_source"
test -s "$tmp_dir/proxy-services.srs"

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

echo "Proxy service categories: ${proxy_source_files[*]##*/}"
echo "Compiled $(find "$repo_dir/compiled" -maxdepth 1 -name '*.srs' | wc -l) rule-sets."
