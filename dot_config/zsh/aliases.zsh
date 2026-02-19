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

# =============================================================================
# Git Aliases
# =============================================================================
alias g="git"
alias gs="git status"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline --graph --decorate"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gba="git branch -a"
alias gm="git merge"
alias gr="git rebase"
alias gst="git stash"
alias gstp="git stash pop"

# =============================================================================
# File Listing Aliases
# =============================================================================
# macOS uses -G, Linux uses --color=auto
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias ls="ls -G"
else
  alias ls="ls --color=auto"
fi
alias l="ls -lh"
alias la="ls -lAh"
alias ll="ls -lh"
alias lt="ls -lhtr"
alias lsize="ls -lhS"

# =============================================================================
# Directory Navigation
# =============================================================================
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# =============================================================================
# Utility Aliases
# =============================================================================
alias c="clear"
alias reload="source ~/.config/zsh/.zshrc"
alias path='echo $PATH | tr ":" "\n"'
alias ports="netstat -tulanp"
alias mkdir="mkdir -pv"
alias grep="grep --color=auto"
alias df="df -h"
alias du="du -h"
alias free="free -h"

# =============================================================================
# Play Aliases
# =============================================================================

# base
alias p="play"

# transport
alias pp="play pause"
alias pr="play resume"
alias pn="play skip"
alias pP="play prev"
alias prs="play restart"
alias ps="play stop"

# info
alias pi="play status"
alias pl="play list"
alias pql="play qlist"

# search / index
alias pf="play search"
alias px="play index"

# queue management
alias pqa="play queue add"
alias pqr="play queue remove"
alias pqc="play queue clear"
alias pqls="play queue list"

# repeat
alias prt="play repeat track"
alias prp="play repeat playlist"
alias pro="play repeat off"

# seek
alias pseek="play seek"
alias pfw="play seek +30"
alias pbw="play seek -10"

# shuffle
alias psh="play --shuffle"

# =============================================================================
# Script Aliases
# =============================================================================

# Language tools installation
alias itool="install-lang"

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

# Font management
alias font="font-switcher"  # Interactive font selector with fzf
