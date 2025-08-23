#!/usr/bin/env bash

# Ask for a project to open with fzf or take in a path as a project
if [[ $# -eq 1 ]]; then
	selected=$1
else
	selected=$(find ~/Code ~/.local/share -mindepth 1 -maxdepth 2 -type d | fzf)
fi

# Check to see if anything was selected
if [[ -z $selected ]]; then
	exit 0
fi

# Get the name of the project
# project_name=$(basename "$selected" | tr . _)
project_name=${selected##*/}
project_name=${project_name//./_}

# Check to see if tmux is running
tmux_active=$(pgrep tmux)

# If tmux is not running then create a session
if [[ -z $TMUX ]] && [[ -z $tmux_active ]]; then
	tmux new-session -s $project_name -c $selected
	exit 0
fi

# Check to see if there is a tmux session with the current project
if ! tmux has-session -t=$project_name 2>/dev/null; then
	# Create a detached session to not mess with the current open session
	tmux new-session -ds $project_name -c $selected
fi

tmux attach -t $project_name
