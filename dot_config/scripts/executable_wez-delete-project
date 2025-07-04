#!/usr/bin/env bash

# Find all project folders inside ~/Code subdirectories
PROJECT_PATH=$(find ~/Code -mindepth 2 -maxdepth 2 -type d | fzf --prompt="Select a project to delete: ")

if [[ -z "$PROJECT_PATH" ]]; then
  echo "No project selected."
  exit 1
fi

# Extract project name from path
PROJECT_NAME=$(basename "$PROJECT_PATH")

# Confirm deletion
read -rp "Are you sure you want to delete '$PROJECT_NAME' at '$PROJECT_PATH'? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Cancelled."
  exit 0
fi

# Close WezTerm tabs with matching working directory
# Note: WezTerm doesn't have a direct equivalent to tmux sessions,
# but we can close tabs that are in the project directory
if [[ -n "$WEZTERM_PANE" ]]; then
  # Get list of all tabs and their working directories
  wezterm cli list --format json | jq -r '.[] | select(.cwd == "'"$PROJECT_PATH"'") | .tab_id' | while read -r tab_id; do
    if [[ -n "$tab_id" ]]; then
      wezterm cli close-tab --tab-id "$tab_id"
      echo "Closed WezTerm tab in '$PROJECT_PATH'."
    fi
  done
fi

# Delete the folder
rm -rf "$PROJECT_PATH"
echo "Deleted project folder '$PROJECT_PATH'."
