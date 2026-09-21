# singbox-rules

Public, credential-free routing rules for sing-box clients.

## Layout

- `source/*.json`: human-editable sing-box rule-set v5 source files.
- `compiled/*.srs`: client-consumed binary rule-sets.
- `scripts/build.sh`: validates and compiles all sources, then refreshes the China rule-sets.
- `.github/workflows/build-rules.yml`: builds on source changes and once daily.

`geosite-cn.srs` and `geoip-cn.srs` are mirrored from the official SagerNet
`sing-geosite` and `sing-geoip` `rule-set` branches. Their upstream licenses apply.
They are refreshed daily so clients need only this repository as a rule source.

## Update a rule

Edit the relevant file under `source/`, then commit and push. GitHub Actions
validates every JSON file with stable sing-box, compiles all `.srs` files, and
commits changed binaries. Clients check the `compiled/` raw URLs every 6 hours.

Never add node UUIDs, REALITY keys, subscription tokens, or private client
profiles to this repository.
