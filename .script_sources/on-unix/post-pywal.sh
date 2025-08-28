#!/bin/bash
# This script runs after pywal generates themes to handle app-specific tasks.

set -euo pipefail

# --- Zed Theme ---
ZED_THEMES_DIR="$HOME/.config/zed/themes"
SOURCE_THEME="$HOME/.cache/wal/pywal-zed-vesper.json"
DEST_THEME="$ZED_THEMES_DIR/pywal-theme.json"

# Ensure the destination directory exists
mkdir -p "$ZED_THEMES_DIR"

# Copy the file if the source exists
if [ -f "$SOURCE_THEME" ]; then
    cp "$SOURCE_THEME" "$DEST_THEME"
    echo "✅ Copied pywal theme to Zed themes directory."
fi

# --- Neovim Theme Reload ---
# Find all running Neovim instances and tell them to reload the theme.
# We suppress errors in case no instances are running.
echo "› Sending reload command to Neovim instances..."
for socket in $(find ${XDG_RUNTIME_DIR:-/tmp} -name "nvim*.sock" 2>/dev/null); do
    nvim --server "$socket" --remote-expr "vim.cmd('ReloadPywal')" &
done

# You can add other post-wal tasks here in the future
