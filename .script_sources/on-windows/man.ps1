<#
.SYNOPSIS
    Interactively find and display command help, preferring tldr pages.

.DESCRIPTION
    This script lets you fuzzy-find a PowerShell command using fzf. If a tldr page
    for the selected command exists, it will be displayed. Otherwise, it
    falls back to the built-in Get-Help documentation.

.NOTES
    Dependencies:
    - fzf: A command-line fuzzy finder. (e.g., choco install fzf)
    - tldr: A client for tldr pages. (e.g., pip install tldr, npm install -g tldr)
#>

# Ensure fzf and tldr are installed and available in the PATH.
if (-not (Get-Command fzf -ErrorAction SilentlyContinue) -or -not (Get-Command tldr -ErrorAction SilentlyContinue)) {
    Write-Error "This script requires 'fzf' and 'tldr' to be installed and in your PATH."
    exit 1
}

# 1. Get a list of all available commands (Cmdlets, Functions, Applications).
# 2. Select only the 'Name' property.
# 3. Pipe the list into fzf for interactive selection.
$selected_cmd = Get-Command | Select-Object -ExpandProperty Name | fzf --prompt="Command Search: " --cycle --bind "tab:down,shift-tab:up"

# Exit gracefully if the user cancelled fzf (e.g., by pressing Esc).
if ([string]::IsNullOrEmpty($selected_cmd)) {
    Write-Output "No command selected."
    exit 0
}

# Check if a tldr page exists for the selected command by checking its exit code.
# We redirect all output streams (*>) to null to suppress any messages during this check.
tldr $selected_cmd *>$null

# $LASTEXITCODE holds the exit code of the last native program that was run.
if ($LASTEXITCODE -eq 0) {
    # If tldr exits with 0 (success), the page exists. Display it.
    Write-Host "TLDR page found for '$selected_cmd'. Displaying:" -ForegroundColor Green
    tldr $selected_cmd
} else {
    # If tldr exits with a non-zero status, the page doesn't exist.
    # Display the standard PowerShell help.
    Write-Host "No TLDR page found for '$selected_cmd'. Displaying PowerShell help:" -ForegroundColor Yellow
    Get-Help $selected_cmd
}
