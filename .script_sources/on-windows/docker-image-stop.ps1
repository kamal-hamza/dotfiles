# ==============================================================================
#
#          Docker Container Stop Script for Windows PowerShell
#
#  Interactively select and stop running Docker containers using fzf
#  Supports multi-selection
#  Requires: fzf (via chocolatey/scoop), Docker Desktop
#
# ==============================================================================

# Check dependencies
if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
  Write-Host "Error: 'fzf' not found. Install via: choco install fzf" -ForegroundColor Red
  exit 1
}

if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host "Error: 'docker' not found. Install Docker Desktop" -ForegroundColor Red
  exit 1
}

# Get the list of running containers
Write-Host "Select containers to stop..." -ForegroundColor Cyan

$psOutput = docker ps --format "table {{.ID}}`t{{.Image}}`t{{.Names}}`t{{.Status}}"

if ([string]::IsNullOrWhiteSpace($psOutput) -or $psOutput -eq "CONTAINER ID`tIMAGE`tNAMES`tSTATUS") {
  Write-Host "No running containers found." -ForegroundColor Yellow
  exit 0
}

$selected = $psOutput | fzf --height 40% --border --multi --header-lines=1 --prompt="Select containers to STOP > "

if ([string]::IsNullOrWhiteSpace($selected)) {
  Write-Host "No containers selected." -ForegroundColor Yellow
  exit 0
}

# Extract container IDs from selected lines
$containerIds = $selected -split "`n" | ForEach-Object {
  ($_ -split "`t")[0]
} | Where-Object { $_ -ne "" -and $_ -ne "CONTAINER ID" }

if ($containerIds.Count -eq 0) {
  Write-Host "No valid container IDs extracted." -ForegroundColor Yellow
  exit 0
}

# Stop the selected containers
Write-Host ""
Write-Host "Stopping the following containers:" -ForegroundColor Green
$containerIds | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
Write-Host ""

foreach ($id in $containerIds) {
  docker stop $id
}

Write-Host ""
Write-Host "✓ Containers stopped successfully" -ForegroundColor Green
