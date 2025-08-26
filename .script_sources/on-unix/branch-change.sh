#!/bin/bash
#
# git-fuzzy-checkout.sh - Interactively find and check out a git branch.
#
# This script lists all local and remote branches, lets you fuzzy-find one
# with fzf, and then checks it out. A preview window shows the latest
# commits of the highlighted branch.
#
# Dependencies:
#   - fzf: A command-line fuzzy finder.
#   - git: The version control system.

# Ensure fzf and git are installed.
if ! command -v fzf &> /dev/null || ! command -v git &> /dev/null; then
    echo "Error: This script requires 'fzf' and 'git' to be installed." >&2
    exit 1
fi

# Ensure we are in a git repository.
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

# 1. Start fetching the latest remote branches in the background.
#    This allows the fzf menu to appear instantly without waiting for the network.
#    The branch list will be up-to-date on the *next* run.
git fetch --prune &> /dev/null &

# 2. Get all local and remote branches that are currently known.
#    - 'git for-each-ref' is a safe way to list branches.
#    - We format the output to show the branch name and the last commit date.
#    - We also sort -u to remove duplicates that can appear if a local branch
#      tracks a remote one.
all_branches=$(git for-each-ref --format='%(refname:short)|%(committerdate:relative)' refs/heads refs/remotes | sed 's|origin/||' | sort -u)

# 3. Use fzf to select a branch.
#    - --preview: Shows the last 10 commits of the selected branch.
#    - --nth=1: Makes fzf search only the branch name (the first field).
#    - --delimiter='|': Sets the field separator.
selected_branch=$(echo "$all_branches" | fzf --height=50% --reverse \
    --prompt="Checkout Branch: " \
    --header="Branch | Last Commit" \
    --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%h %s (%an, %ar)' -n 10 $(echo {} | cut -d'|' -f1)" \
    --nth=1 --delimiter='|' | cut -d'|' -f1)

# Exit if no branch was selected.
if [ -z "$selected_branch" ]; then
    echo "No branch selected."
    exit 0
fi

# 4. Checkout the selected branch.
git checkout "$selected_branch"
