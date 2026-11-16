# =============================================================================
# Windows bootstrap - the only non-Python provisioning script on Windows.
# Installs Python (and the `py` launcher the .py scripts run with, see
# [interpreters.py] in home/.chezmoi.toml.tmpl) via winget.
# Runs once (per content) before anything else, only when provision = true.
# =============================================================================
$ErrorActionPreference = 'Stop'

if (Get-Command py -ErrorAction SilentlyContinue) {
    Write-Host "✓ python (py launcher)"
    exit 0
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found - install 'App Installer' from the Microsoft Store, then re-run: chezmoi apply"
    exit 1
}

Write-Host "→ Installing Python via winget..."
winget install --id Python.Python.3.13 --exact --silent --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# chezmoi's own process won't see the new PATH, so the .py scripts that follow
# can't find `py` yet. Fail on purpose: this script isn't recorded as done,
# and the next `chezmoi apply` (from a NEW terminal) passes the check above.
Write-Warning "Python installed. Open a new terminal and run 'chezmoi apply' again."
exit 1
