#Requires -Modules fzf

# Define the root directory for projects
$CodeFolder = "$env:USERPROFILE\Code"

# Find all project folders inside ~\Code subdirectories using fzf
# -Depth 1 is like -mindepth 2 -maxdepth 2
$ProjectPath = Get-ChildItem -Path $CodeFolder -Directory -Depth 1 |
               Select-Object -ExpandProperty FullName |
               fzf --prompt="Select a project to delete: "

if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
    Write-Host "No project selected."
    exit 1
}

# Extract project name from path. Split-Path -Leaf is like basename.
$ProjectName = Split-Path -Path $ProjectPath -Leaf

# Confirm deletion
$Confirm = Read-Host -Prompt "Are you sure you want to delete '$ProjectName' at '$ProjectPath'? (y/N)"
if ($Confirm -ne 'y') {
    Write-Host "Cancelled."
    exit 0
}

# NOTE: Tmux is not available on Windows. Session killing logic is removed.

# Delete the folder. -Recurse is like -r, -Force handles permissions/hidden files.
Remove-Item -Path $ProjectPath -Recurse -Force
Write-Host "Deleted project folder '$ProjectPath'."
