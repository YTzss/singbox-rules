# Publish this public repository

The server currently has no authenticated GitHub CLI. After authenticating as
the existing GitHub owner, run:

```bash
cd /home/ubuntu/singbox-rules
gh auth login
gh repo create moli20050328-opsa/singbox-rules --public --source=. --remote=origin --push
```

In repository Settings → Actions → General, keep workflow permissions at
"Read and write permissions" so the workflow can commit refreshed `.srs`
files. The workflow also declares `contents: write`.

Do not make this repository private: client access should not require a PAT.
