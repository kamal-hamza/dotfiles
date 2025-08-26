#!/bin/bash
#
# man-tldr.sh - Interactively find and display man pages, preferring tldr.
#
# This script lets you fuzzy-find a man page using fzf. If a tldr page
# for the selected command exists, it will be displayed. Otherwise, it
# falls back to the traditional man page.
#
# Dependencies:
#   - fzf: A command-line fuzzy finder.
#   - tldr: A client for simplified and community-driven man pages.

# Ensure fzf and tldr are installed.
if ! command -v fzf &> /dev/null || ! command -v tldr &> /dev/null; then
    echo "Error: This script requires 'fzf' and 'tldr' to be installed." >&2
    echo "Please install them to continue." >&2
    exit 1
fi

# 1. Get a list of all man pages, redirecting errors to /dev/null to hide warnings.
# 2. Pipe the list into fzf for interactive selection.
# 3. Use awk and sed to extract just the command name.
selected_cmd=$(apropos . 2>/dev/null | fzf --prompt="Man Page Search: " \
                               --cycle \
                               --bind "tab:down,shift-tab:up" \
                               | awk '{print $1}' | sed 's/(.*//')

# Exit gracefully if the user cancelled fzf (e.g., by pressing Esc).
if [ -z "$selected_cmd" ]; then
    echo "No command selected."
    exit 0
fi

# Check if a tldr page exists for the selected command.
if tldr "${selected_cmd}" &> /dev/null; then
    # If tldr page exists, display it.
    echo "TLDR page found for '${selected_cmd}'. Displaying:"
    tldr "${selected_cmd}"
else
    # Otherwise, display the standard man page.
    echo "No TLDR page found for '${selected_cmd}'. Displaying man page:"
    man "${selected_cmd}"
fi
