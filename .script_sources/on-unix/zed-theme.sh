#!/bin/bash
# This script runs after pywal generates themes to handle app-specific tasks.

set -euo pipefail

# --- Zed Theme ---
ZED_THEMES_DIR="$HOME/.config/zed/themes"
SOURCE_THEME="$HOME/.cache/wal/colors-zed.json"
DEST_THEME="$ZED_THEMES_DIR/pywal.json"

# Ensure the destination directory exists
mkdir -p "$ZED_THEMES_DIR"

# Copy the file if the source exists
if [ -f "$SOURCE_THEME" ]; then
    cp "$SOURCE_THEME" "$DEST_THEME"
    echo "✅ Copied pywal theme to Zed themes directory."
fi

# You can add other post-wal tasks here in the future
