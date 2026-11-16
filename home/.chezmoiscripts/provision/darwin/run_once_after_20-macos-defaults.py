#!/usr/bin/python3
# =============================================================================
# macOS system preferences
# =============================================================================
# Runs once per content: edit this file to re-apply it on the next
# `chezmoi apply` (or: chezmoi state delete-bucket --bucket=scriptState).
# Each entry is a `defaults` argument list; failures are reported, not fatal.
# =============================================================================
import subprocess
import sys
from pathlib import Path

D = "NSGlobalDomain"
DOCK = "com.apple.dock"
FINDER = "com.apple.finder"
TRACKPAD = "com.apple.driver.AppleBluetoothMultitouch.trackpad"

DEFAULTS = [
    # --- Appearance: dark mode, pink accent, no auto light/dark switching
    ["write", D, "AppleInterfaceStyle", "-string", "Dark"],
    ["write", D, "AppleAccentColor", "-int", "6"],
    ["write", D, "AppleInterfaceStyleSwitchesAutomatically", "-bool", "false"],
    # --- Dock: small, right side, auto-hide fast, no recents/suggested apps
    ["write", DOCK, "tilesize", "-int", "36"],
    ["write", DOCK, "orientation", "-string", "right"],
    ["write", DOCK, "show-recents", "-bool", "false"],
    ["write", DOCK, "autohide", "-bool", "true"],
    ["write", DOCK, "autohide-delay", "-float", "0.0"],
    ["write", DOCK, "autohide-time-modifier", "-float", "0.4"],
    # --- Keyboard: fastest key repeat
    ["write", D, "KeyRepeat", "-int", "2"],
    ["write", D, "InitialKeyRepeat", "-int", "10"],
    # --- Finder: path bar, no POSIX path in title, list view
    ["write", FINDER, "ShowPathbar", "-bool", "true"],
    ["write", FINDER, "_FXShowPosixPathInTitle", "-bool", "false"],
    ["write", FINDER, "FXPreferredViewStyle", "-string", "Nlsv"],
    # --- Trackpad: tap to click, secondary click bottom-right corner
    ["write", TRACKPAD, "Clicking", "-bool", "true"],
    ["-currentHost", "write", D, "com.apple.mouse.tapBehavior", "-int", "1"],
    ["write", D, "com.apple.mouse.tapBehavior", "-int", "1"],
    ["write", TRACKPAD, "TrackpadCornerSecondaryClick", "-int", "2"],
    ["write", TRACKPAD, "TrackpadRightClick", "-bool", "true"],
    ["-currentHost", "write", D, "com.apple.trackpad.trackpadCornerClickBehavior", "-int", "1"],
    ["-currentHost", "write", D, "com.apple.trackpad.enableSecondaryClick", "-bool", "true"],
    # --- Menu bar: battery percentage
    ["write", "com.apple.controlcenter", "BatteryShowPercentage", "-bool", "true"],
    # --- Hot corners: all disabled
    ["write", DOCK, "wvous-tl-corner", "-int", "0"],
    ["write", DOCK, "wvous-tr-corner", "-int", "0"],
    ["write", DOCK, "wvous-bl-corner", "-int", "0"],
    ["write", DOCK, "wvous-br-corner", "-int", "0"],
    # --- Fonts: light font smoothing
    ["-currentHost", "write", "-g", "AppleFontSmoothing", "-int", "1"],
]


def main() -> int:
    print("→ Applying macOS defaults")
    # Dark mode via System Events applies immediately; the defaults key above is the fallback.
    subprocess.run(["osascript", "-e",
                    'tell application "System Events" to tell appearance preferences to set dark mode to true'],
                   capture_output=True)
    failed = 0
    for args in DEFAULTS:
        if subprocess.run(["defaults", *args], capture_output=True).returncode != 0:
            failed += 1
            print(f"⚠ defaults {' '.join(args)} failed", file=sys.stderr)
    # Apply list view to existing Finder windows too
    for plist in (Path.home() / "Library/Preferences").glob("com.apple.finder.plist"):
        subprocess.run(["defaults", "write", str(plist), "FXPreferredViewStyle", "-string", "Nlsv"],
                       capture_output=True)
    for app in ("Dock", "Finder", "SystemUIServer"):
        subprocess.run(["killall", app], capture_output=True)
    print(f"✓ macOS defaults applied ({len(DEFAULTS) - failed}/{len(DEFAULTS)})")
    return 0


sys.exit(main())
