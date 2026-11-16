#!/bin/sh
# =============================================================================
# macOS bootstrap - the only non-Python provisioning script on macOS.
# Gets the machine to the point where the Python scripts can run:
#   1. Xcode Command Line Tools (provides /usr/bin/python3 and git)
#   2. Homebrew
# Runs once (per content) before anything else, only when provision = true.
# =============================================================================
set -eu

if ! xcode-select -p >/dev/null 2>&1; then
    echo "→ Installing Xcode Command Line Tools (finish the dialog that opens)..."
    xcode-select --install || true
    until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi
echo "✓ Xcode Command Line Tools"

if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
    echo "→ Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
echo "✓ Homebrew"
