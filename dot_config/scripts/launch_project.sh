#!/bin/bash

# -----------------------------------------------------
# Rofi Project Launcher
# -----------------------------------------------------
# Description: This script finds project directories across multiple root paths
# and uses Rofi to select one. It then opens the selected project in wezterm
# and Zed on their designated workspaces.
#
# --- Configuration ---
# Add all parent directories where your projects are stored.
# The script will search for subdirectories inside each of these paths.
PROJECT_DIRS=(
    "$HOME/Code"
    "$HOME/.config"
    "$HOME/.local/share"
)

# --- Script Logic ---

# Use an associative array to map project basenames to their full paths.
# This prevents conflicts if projects in different directories share the same name.
declare -A project_paths

# Use 'find' to locate all subdirectories (projects) in the defined project directories.
# The output is piped into a 'while' loop to populate the associative array.
while IFS= read -r dir; do
    basename=$(basename "$dir")
    # Store the full path with the folder name as the key.
    project_paths["$basename"]="$dir"
done < <(find "${PROJECT_DIRS[@]}" -mindepth 1 -maxdepth 1 -type d)

# Check if any projects were found.
if [ ${#project_paths[@]} -eq 0 ]; then
    notify-send "Project Launcher Error" "No projects found in the specified directories."
    exit 1
fi

# Get the list of project names (the keys of the array) and pipe them to Rofi.
selected_project=$(printf "%s\n" "${!project_paths[@]}" | rofi -dmenu -i -p "Select Project" -theme ~/.cache/wal/colors-rofi-dark.rasi)

# If the user cancelled Rofi, exit gracefully.
if [ -z "$selected_project" ]; then
    exit 0
fi

# Retrieve the full path from our array using the selected project name.
selected_path="${project_paths[$selected_project]}"

# --- Launch Commands ---

# Kill any existing tmux server to ensure a clean start for the new session.
tmux kill-server >/dev/null 2>&1
sleep 0.1 # Give a moment for the server to shut down cleanly.

# Use hyprctl to dispatch the commands to specific workspaces.
# The --batch flag sends all commands at once for efficiency.
hyprctl --batch "\
    dispatch exec [workspace 1 silent] wezterm start -- tmux new-session -s \"$selected_project\" -c \"$selected_path\"; \
    dispatch exec [workspace 2 silent] zed \"$selected_path\""
