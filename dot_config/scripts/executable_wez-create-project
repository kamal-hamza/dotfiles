#!/usr/bin/env bash

# Prompt for project name
read -rp "Project Name: " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: Project name cannot be empty."
  exit 1
fi

# Select a parent folder from ~/Code using fzf
TARGET_DIR=$(find ~/Code -type d -mindepth 1 -maxdepth 1 | fzf --prompt="Select parent folder: ")
if [[ -z "$TARGET_DIR" ]]; then
  echo "No directory selected."
  exit 1
fi

# Create the project folder
PROJECT_PATH="$TARGET_DIR/$PROJECT_NAME"
if [[ -d "$PROJECT_PATH" ]]; then
  echo "Directory '$PROJECT_PATH' already exists."
else
  mkdir -p "$PROJECT_PATH"
  echo "Created project folder at: $PROJECT_PATH"
fi

# Open the project in a new WezTerm tab/window
# Check if we're already in WezTerm
if [[ -n "$WEZTERM_PANE" ]]; then
  # We're in WezTerm, create a new tab
  wezterm cli spawn --new-tab --cwd "$PROJECT_PATH" --label "$PROJECT_NAME"
  echo "Created new WezTerm tab '$PROJECT_NAME'."
else
  # Not in WezTerm, start a new instance
  wezterm start --cwd "$PROJECT_PATH" &
  echo "Started WezTerm in '$PROJECT_PATH'."
fi
