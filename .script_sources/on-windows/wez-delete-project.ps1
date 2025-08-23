#Requires -Modules fzf

# Define the root directory for projects
$CodeFolder = "$env:USERPROFILE\Code"

# Find and select a project to delete
$ProjectPath = Get-ChildItem -Path $CodeFolder -Directory -Depth 1 |
               Select-Object -ExpandProperty FullName |
               fzf --prompt="Select a project to delete: "

if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
    Write-Host "No project selected."
    exit 1
}

# Get the project name
$ProjectName = Split-Path -Path $ProjectPath -Leaf

# Confirm deletion
$Confirm = Read-Host -Prompt "Are you sure you want to delete '$ProjectName' at '$ProjectPath'? (y/N)"
if ($Confirm -ne 'y') {
    Write-Host "Cancelled."
    exit 0
}

# Close WezTerm tabs with a matching working directory
if ($env:WEZTERM_PANE) {
    # Get list of all tabs, convert from JSON, and find matches
    $tabsToClose = wezterm cli list --format json | ConvertFrom-Json | Where-Object { $_.cwd -eq "file://$ProjectPath" }

    foreach ($tab in $tabsToClose) {
        wezterm cli close-tab --tab-id $tab.tab_id
        Write-Host "Closed WezTerm tab $($tab.tab_id) in '$ProjectPath'."
    }
}

# Delete the folder
Remove-Item -Path $ProjectPath -Recurse -Force
Write-Host "Deleted project folder '$ProjectPath'."
