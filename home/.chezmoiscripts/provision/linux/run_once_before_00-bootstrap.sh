#!/bin/sh
# =============================================================================
# Linux bootstrap - the only non-Python provisioning script on Linux.
# Installs /usr/bin/python3 so the Python provisioning scripts can run.
# Runs once (per content) before anything else, only when provision = true.
# =============================================================================
set -eu

if [ -x /usr/bin/python3 ]; then
    echo "✓ python3"
    exit 0
fi

if command -v pacman >/dev/null 2>&1; then
    echo "→ Installing python (pacman)..."
    sudo pacman -S --needed --noconfirm python
else
    echo "✗ No supported package manager found (only pacman/Arch is supported)." >&2
    echo "  Install python3 manually, then re-run: chezmoi apply" >&2
    exit 1
fi
