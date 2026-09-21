# singbox-rules

Public, credential-free routing rules for sing-box clients.

## Layout

- `source/*.json`: human-editable sing-box rule-set v5 source files.
- `compiled/*.srs`: client-consumed binary rule-sets.
- `compiled/proxy-services.srs`: stable aggregate used by client profiles.
- `scripts/build.sh`: validates and compiles all sources, builds the aggregate,
  then refreshes the China rule-sets.
- `.github/workflows/build-rules.yml`: builds on source changes and once daily.

`geosite-cn.srs` and `geoip-cn.srs` are mirrored from the official SagerNet
`sing-geosite` and `sing-geoip` `rule-set` branches. Their upstream licenses apply.
They are refreshed daily so clients need only this repository as a rule source.

Locally maintained service rule-sets currently include AI, GitHub, Google and
YouTube, Notion, research, X/Twitter, TikTok, Telegram, and Docker domains.
Every `source/*.json` file except `direct-cn.json` is automatically included in
`proxy-services.srs`. The individual compiled files remain available for
maintenance and debugging, while clients only depend on the stable aggregate.

## Update a rule

Edit the relevant file under `source/`, then commit and push. GitHub Actions
validates non-empty JSON sources, rejects duplicate rule entries, compiles every
category, generates a non-empty `proxy-services.srs`, and commits changed
binaries. A failed category prevents all new binaries from being published.
Clients check the fixed aggregate and China-rule URLs every 6 hours.

Never add node UUIDs, REALITY keys, subscription tokens, or private client
profiles to this repository.
