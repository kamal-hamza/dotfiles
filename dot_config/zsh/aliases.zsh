# =============================================================================
# Script Aliases Configuration
# =============================================================================
# This file defines aliases for custom scripts in ~/.local/bin
#
# How to add a new script alias:
# 1. Add your script to: ~/.local/share/chezmoi/dot_local/bin/
#    Name it: executable_scriptname
# 2. Add an alias below
# 3. Run: chezmoi apply
# 4. Your script is now available!
#
# Example:
#   alias mycommand="scriptname"
# =============================================================================

# Add your script aliases below:

# Project management
alias ccp="create-project"   # Create a new project with template
alias dcp="delete-project"   # Delete a project and its tmux session

# Tmux session management
alias tt="tmux-new"          # Quick tmux session switcher

# Docker management
alias dr="docker-run"        # Run Docker container interactively
alias ds="docker-stop"       # Stop running Docker containers

# Theme management
alias theme-gen="theme-gen"  # Generate theme configs for all apps
alias theme="theme-switch"   # Switch between light/dark themes

# Documentation
alias m="man-tldr"           # Interactive man page search with tldr

# History search
alias h="fzf-history"        # Advanced fuzzy history search
