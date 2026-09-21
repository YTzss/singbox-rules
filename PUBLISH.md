# Published public repository

The public rules repository is:

`https://github.com/YTzss/singbox-rules`

The local `origin` points to this repository. To publish future local commits,
run:

```bash
cd /home/ubuntu/singbox-rules
git push origin main
```

In repository Settings → Actions → General, keep workflow permissions at
"Read and write permissions" so the workflow can commit refreshed `.srs`
files. The workflow also declares `contents: write`.

Do not make this repository private: client access should not require a PAT.
