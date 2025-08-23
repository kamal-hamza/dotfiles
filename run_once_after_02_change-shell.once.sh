#!/bin/bash
# chezmoi: run_once
# Purpose: Change default shell to Zsh on macOS and Linux (Arch compatible)

set -euo pipefail

# Supported OS check
OS="$(uname)"
if [[ "$OS" != "Darwin" && "$OS" != "Linux" ]]; then
    echo "Skipping shell change: unsupported OS ($OS)."
    exit 0
fi

# Determine Zsh path based on OS
if [[ "$OS" == "Darwin" ]]; then
    DESIRED_SHELL="/bin/zsh"
elif [[ "$OS" == "Linux" ]]; then
    # On Linux, prefer /usr/bin/zsh if it exists, fallback to /bin/zsh
    if command -v zsh &>/dev/null; then
        DESIRED_SHELL="$(command -v zsh)"
    else
        echo "Zsh not found on Linux."
        exit 1
    fi
fi

# Check if desired shell is in /etc/shells
if ! grep -qx "$DESIRED_SHELL" /etc/shells; then
    echo "Adding $DESIRED_SHELL to /etc/shells."
    echo "$DESIRED_SHELL" | sudo tee -a /etc/shells
fi

# Change shell if not already set
if [[ "$SHELL" != "$DESIRED_SHELL" ]]; then
    echo "Changing shell for $USER to $DESIRED_SHELL."
    chsh -s "$DESIRED_SHELL" "$USER"
else
    echo "Shell already set to $DESIRED_SHELL."
fi
