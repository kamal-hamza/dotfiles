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

# Kill tmux session if it exists
if tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
  tmux kill-session -t "$PROJECT_NAME"
  echo "Killed tmux session '$PROJECT_NAME'."
fi

# Delete the folder
rm -rf "$PROJECT_PATH"
echo "Deleted project folder '$PROJECT_PATH'."
