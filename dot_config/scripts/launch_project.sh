#!/bin/bash

# -----------------------------------------------------
# Rofi Project Launcher
# -----------------------------------------------------
# Description: This script finds project directories and uses Rofi to select one.
# It then opens the selected project in wezterm (with tmux) and Zed,
# each on their designated workspace.
#
# Author: Gemini
# -----------------------------------------------------

# --- Configuration ---
# Set the directory where you store all your projects.
# The script will search for subdirectories inside this path.
PROJECTS_DIR="~/Projects"

# --- Script Logic ---
# Expand the tilde (~) to the full home directory path.
eval PROJECTS_DIR="$PROJECTS_DIR"

# Check if the projects directory exists.
if [ ! -d "$PROJECTS_DIR" ]; then
    notify-send "Project Launcher Error" "Directory not found: $PROJECTS_DIR"
    exit 1
fi

# Find all directories one level deep within the PROJECTS_DIR.
# We then use `basename` to show only the folder name in Rofi, not the full path.
# This makes the menu look cleaner.
selected_project=$(find "$PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d | xargs -I {} basename {} | rofi -dmenu -i -p "Select Project" -theme ~/.cache/wal/colors-rofi-dark.rasi)

# If the user cancelled Rofi (e.g., by pressing Esc), the script should exit.
if [ -z "$selected_project" ]; then
    exit 0
fi

# Reconstruct the full path to the selected project directory.
selected_path="$PROJECTS_DIR/$selected_project"

# Kill any existing tmux server to ensure a clean start for the new session.
# This prevents errors and cleans up the previous project's terminal environment.
tmux kill-server >/dev/null 2>&1
sleep 0.1 # Give a moment for the server to shut down cleanly.

# Use hyprctl to dispatch the commands.
# The --batch flag allows us to send multiple commands at once efficiently.
hyprctl --batch "\
    dispatch exec [workspace 1 silent] wezterm start -- tmux new-session -s \"$selected_project\" -c \"$selected_path\"; \
    dispatch exec [workspace 2 silent] zed \"$selected_path\""

# Optional: Focus the editor workspace after launching.
# hyprctl dispatch workspace 2
