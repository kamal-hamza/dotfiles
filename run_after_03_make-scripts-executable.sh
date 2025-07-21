#!/bin/sh

# This script ensures all files in the ~/.config/scripts directory are executable.
# It is intended to be run by chezmoi automatically after 'chezmoi apply'.

# The directory where your scripts are located in the target system.
SCRIPT_DIR="$HOME/.config/scripts"

# Check if the directory exists to avoid errors.
if [ -d "$SCRIPT_DIR" ]; then
    # Find all files within the directory and add the executable permission (+x).
    # The '-type f' ensures we only target files, not directories.
    find "$SCRIPT_DIR" -type f -exec chmod +x {} \;
    echo "Made all scripts in $SCRIPT_DIR executable."
else
    # Print a warning if the directory doesn't exist, but don't fail.
    echo "Warning: Script directory $SCRIPT_DIR not found."
fi
