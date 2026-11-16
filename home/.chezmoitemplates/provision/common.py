# ---- shared helpers (from home/.chezmoitemplates/provision/common.py) ------
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

# Windows consoles may default to a legacy code page; never crash on ✓/→.
for _stream in (sys.stdout, sys.stderr):
    if hasattr(_stream, "reconfigure"):
        _stream.reconfigure(encoding="utf-8", errors="replace")

_COLOR = sys.stdout.isatty() and "NO_COLOR" not in os.environ
def _c(code: str, text: str) -> str:
    return f"\033[{code}m{text}\033[0m" if _COLOR else text

def header(msg: str) -> None:
    bar = "═" * 60
    print(f"\n{_c('0;34', bar)}\n{_c('0;34', '  ' + msg)}\n{_c('0;34', bar)}", flush=True)

def info(msg: str) -> None:
    print(f"{_c('0;34', '→')} {msg}", flush=True)

def ok(msg: str) -> None:
    print(f"{_c('0;32', '✓')} {msg}", flush=True)

def warn(msg: str) -> None:
    print(f"{_c('1;33', '⚠')} {msg}", flush=True)

def err(msg: str) -> None:
    print(f"{_c('0;31', '✗')} {msg}", file=sys.stderr, flush=True)

def run(cmd: list, check: bool = True, quiet: bool = False, **kwargs) -> subprocess.CompletedProcess:
    """Run a command, echoing it first. quiet=True captures its output."""
    if not quiet:
        info("$ " + " ".join(str(c) for c in cmd))
    if quiet:
        kwargs.setdefault("capture_output", True)
        kwargs.setdefault("text", True)
    return subprocess.run([str(c) for c in cmd], check=check, **kwargs)

def succeeds(cmd: list) -> bool:
    return subprocess.run([str(c) for c in cmd], capture_output=True).returncode == 0

def dedupe(items) -> list:
    seen, out = set(), []
    for item in items or []:
        if item not in seen:
            seen.add(item)
            out.append(item)
    return out
# ---------------------------------------------------------------------------
