#!/usr/bin/python3
# =============================================================================
# Make fish the login shell (macOS + Linux)
# =============================================================================
# Runs after packages are installed. Registers fish in /etc/shells if needed,
# then `sudo chsh` (works with or without a terminal, via sudo's normal
# password prompt or SUDO_ASKPASS). Re-runs only if this file changes.
# =============================================================================
import os
import pwd
import shutil
import subprocess
import sys
from pathlib import Path


def find_fish():
    for candidate in ("/opt/homebrew/bin/fish", "/usr/local/bin/fish", "/usr/bin/fish", shutil.which("fish")):
        if candidate and Path(candidate).is_file():
            return candidate
    return None


def main() -> int:
    fish = find_fish()
    if not fish:
        print("✗ fish is not installed - not changing the login shell", file=sys.stderr)
        return 1

    shells = Path("/etc/shells").read_text().split()
    if fish not in shells:
        print(f"→ Adding {fish} to /etc/shells")
        subprocess.run(["sudo", "tee", "-a", "/etc/shells"], input=fish + "\n", text=True,
                       stdout=subprocess.DEVNULL, check=True)

    current = pwd.getpwuid(os.getuid()).pw_shell
    if current == fish:
        print(f"✓ Login shell is already {fish}")
        return 0
    print(f"→ Changing login shell: {current} -> {fish}")
    user = pwd.getpwuid(os.getuid()).pw_name
    subprocess.run(["sudo", "chsh", "-s", fish, user], check=True)
    print("✓ Done - takes effect on your next login")
    return 0


sys.exit(main())
