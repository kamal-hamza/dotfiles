# ==============================================================================
#
#          Docker Image Runner for Windows PowerShell
#
#  Fuzzy-find a Docker image, choose a command, and run the container
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

# Step 1: Select a Docker image using fzf
Write-Host "Select a Docker image..." -ForegroundColor Cyan

$images = docker images --format "{{.Repository}}:{{.Tag}}"
$selectedImage = $images | fzf --height 40% --border --prompt="Select Docker Image > "

if ([string]::IsNullOrWhiteSpace($selectedImage)) {
  Write-Host "No image selected." -ForegroundColor Yellow
  exit 0
}

# Step 2: Provide common commands for selection
$commands = @(
  "bash"
  "sh"
  "ash"
  "zsh"
  "powershell"
  "cmd"
  "ls -la"
  "top"
  "ps aux"
)

$selectedCommand = $commands | fzf --height 40% --border --prompt="Select or type command > "

if ([string]::IsNullOrWhiteSpace($selectedCommand)) {
  Write-Host "No command provided." -ForegroundColor Yellow
  exit 0
}

# Step 3: Run the container
Write-Host ""
Write-Host "Executing: docker run -it --rm `"$selectedImage`" $selectedCommand" -ForegroundColor Green
Write-Host ""

docker run -it --rm $selectedImage $selectedCommand
