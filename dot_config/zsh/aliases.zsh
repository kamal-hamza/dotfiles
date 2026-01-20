# =============================================================================
# Script Aliases Configuration
# =============================================================================
# This file defines aliases for custom scripts in ~/.local/bin
# 
# How to add a new script alias:
# 1. Add your script to: ~/.local/share/chezmoi/scripts/
#    Name it: executable_scriptname.sh (or .py, .rb, etc.)
# 2. Add an alias below
# 3. Run: chezmoi apply
# 4. Your script is now available!
#
# Example:
#   alias mycommand="scriptname.sh"
# =============================================================================

# Add your script aliases below:

# Project management
alias ccp="create-project.sh"   # Create a new project with template
alias dcp="delete-project.sh"   # Delete a project and its tmux session

# Tmux session management
alias tt="tmux-new.sh"          # Quick tmux session switcher

# Docker management
alias dr="docker-run.sh"        # Run Docker container interactively
alias ds="docker-stop.sh"       # Stop running Docker containers

# Theme management
alias theme-gen="theme-gen.py"  # Generate theme configs for all apps
alias theme="theme-switch.sh"   # Switch between light/dark themes

# Documentation
alias m="man-tldr.sh"           # Interactive man page search with tldr