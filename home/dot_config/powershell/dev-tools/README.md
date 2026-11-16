# Development tool configuration (PowerShell)

Machine-specific environment for development tools on Windows. Every `*.ps1`
file here is dot-sourced (alphabetically) by the PowerShell profile and is
**not tracked by chezmoi** (`.chezmoiignore` ignores
`.config/powershell/dev-tools/*.ps1`).

```powershell
# go.ps1
$env:GOPATH = "$HOME\go"
$env:PATH = "$env:GOPATH\bin;$env:PATH"
```

Env that every machine needs belongs in `.chezmoidata/shell.yaml` instead.
