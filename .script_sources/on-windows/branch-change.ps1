<#
.SYNOPSIS
    Interactively find and check out a git branch using fzf.

.DESCRIPTION
    This script lists all local and remote branches, lets you fuzzy-find one
    with fzf, and then checks it out. A preview window shows the latest
    commits of the highlighted branch.

.NOTES
    Dependencies:
    - fzf: A command-line fuzzy finder.
    - git: The version control system.
#>

# Ensure fzf and git are installed and available in the PATH.
if (-not (Get-Command fzf -ErrorAction SilentlyContinue) -or -not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "This script requires 'fzf' and 'git' to be installed and in your PATH."
    exit 1
}

# Ensure we are in a git repository.
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: Not a git repository."
    exit 1
}

# 1. Start fetching the latest remote branches in the background.
#    This allows the fzf menu to appear instantly without waiting for the network.
#    The branch list will be up-to-date on the *next* run.
Start-Job -ScriptBlock { git fetch --prune *> $null } | Out-Null

# 2. Get all local and remote branches that are currently known.
#    - We format the output to show the branch name and the last commit date.
#    - We also use Sort-Object -Unique to remove duplicates.
$all_branches = git for-each-ref --format='%(refname:short)|%(committerdate:relative)' refs/heads refs/remotes | ForEach-Object {
    $_ -replace 'origin/', ''
} | Sort-Object -Unique

# 3. Use fzf to select a branch.
#    - The preview command needs to be handled carefully in PowerShell.
#      We use 'bash -c' to execute the git log command within a bash-like shell
#      to ensure consistent parsing of the placeholder {}.
$preview_command = "bash -c ""git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%h %s (%an, %ar)' -n 10 $(echo {} | cut -d'|' -f1)"""
$selected_branch_line = $all_branches | fzf --height=50% --reverse `
    --prompt="Checkout Branch: " `
    --header="Branch | Last Commit" `
    --preview=$preview_command `
    --nth=1 --delimiter='|'

# Exit if no branch was selected.
if ([string]::IsNullOrEmpty($selected_branch_line)) {
    Write-Output "No branch selected."
    exit 0
}

# 4. Extract just the branch name from the selected line.
$selected_branch = $selected_branch_line.Split('|')[0]

# 5. Checkout the selected branch.
git checkout $selected_branch
