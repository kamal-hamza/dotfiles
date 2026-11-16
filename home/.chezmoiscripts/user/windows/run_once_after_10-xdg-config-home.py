# =============================================================================
# Windows: point XDG_CONFIG_HOME at %USERPROFILE%\.config
# =============================================================================
# Lets XDG-aware tools (Neovim, git, bat, ...) read the same ~/.config/* files
# chezmoi deploys on macOS/Linux, instead of needing AppData copies. Sets a
# persistent *user* environment variable (no admin) if it isn't set yet; new
# terminals pick it up. Apps that ignore XDG on Windows (e.g. Zed) get their
# files under AppData/ in the source state instead.
# =============================================================================
import os
import subprocess
import sys
from pathlib import Path

target = str(Path.home() / ".config")
current = os.environ.get("XDG_CONFIG_HOME")
if current:
    print(f"✓ XDG_CONFIG_HOME already set ({current})")
    sys.exit(0)
print(f"→ setx XDG_CONFIG_HOME {target}")
sys.exit(subprocess.run(["setx", "XDG_CONFIG_HOME", target]).returncode)
