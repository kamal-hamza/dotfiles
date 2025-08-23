#Requires -Modules fzf

# Define paths to search for projects
$SearchPaths = @(
    "$env:USERPROFILE\Code",
    "$env:USERPROFILE\.config",
    "$env:USERPROFILE\Scripts",
    "$env:USERPROFILE\.local\share"
)

# Check if a path was passed as an argument
if ($args.Count -eq 1) {
    $Selected = $args[0]
}
else {
    # Find directories in the search paths and pipe to fzf
    $Selected = Get-ChildItem -Path $SearchPaths -Directory -Depth 1 -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty FullName |
                fzf
}

# Exit if nothing was selected
if ([string]::IsNullOrWhiteSpace($Selected)) {
    exit 0
}

# Get the project name and replace dots with underscores
$ProjectName = (Split-Path -Path $Selected -Leaf).Replace('.', '_')

# Check if we're already in WezTerm
if ($env:WEZTERM_PANE) {
    # Check if a tab with this project already exists
    $existingTab = wezterm cli list --format json | ConvertFrom-Json | Where-Object { $_.cwd -eq "file://$Selected" } | Select-Object -First 1

    if ($existingTab) {
        # Switch to existing tab
        wezterm cli activate-tab --tab-id $existingTab.tab_id
        Write-Host "Switched to existing tab for '$ProjectName'."
    }
    else {
        # Create new tab
        wezterm cli spawn --cwd $Selected
        Write-Host "Created new tab for '$ProjectName'."
    }
}
else {
    # Not in WezTerm, start a new instance
    Start-Process wezterm -ArgumentList "start", "--cwd", "$Selected"
    Write-Host "Started WezTerm in '$Selected'."
}
