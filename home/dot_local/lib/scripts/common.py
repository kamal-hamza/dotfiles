"""Shared helpers for the Python scripts in ~/.local/bin.

Import from a script with:

    sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib" / "scripts"))
    from common import ...

Standard library only; scripts run with the system /usr/bin/python3.
Output is plain text (no colors), matching the minimal terminal look.
"""
from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
from collections.abc import Iterable, Sequence


# ── errors ──────────────────────────────────────────────────────────────────
# A failed command (check=True) or a missing program ends the script with a
# one-line message instead of a traceback; Ctrl-C exits quietly.
def _excepthook(kind, exc, tb):
    if isinstance(exc, subprocess.CalledProcessError):
        detail = (exc.stderr or "").strip().splitlines() if isinstance(exc.stderr, str) else []
        cmd = exc.cmd if isinstance(exc.cmd, str) else " ".join(map(str, exc.cmd))
        err(f"'{cmd}' failed (exit {exc.returncode})" + (f": {detail[-1]}" if detail else ""))
        sys.exit(exc.returncode or 1)
    if isinstance(exc, FileNotFoundError) and exc.filename and os.sep not in str(exc.filename):
        err(f"'{exc.filename}' is not installed")
        sys.exit(127)
    if isinstance(exc, KeyboardInterrupt):
        print(file=sys.stderr)
        sys.exit(130)
    sys.__excepthook__(kind, exc, tb)


sys.excepthook = _excepthook


# ── output ──────────────────────────────────────────────────────────────────
def info(msg: str) -> None:
    print(f"→ {msg}", file=sys.stderr)


def ok(msg: str) -> None:
    print(f"✓ {msg}", file=sys.stderr)


def warn(msg: str) -> None:
    print(f"! {msg}", file=sys.stderr)


def err(msg: str) -> None:
    print(f"✗ {msg}", file=sys.stderr)


def die(msg: str, code: int = 1) -> None:
    err(msg)
    sys.exit(code)


def notify(title: str, body: str = "", urgency: str = "normal", *, app: str | None = None,
           replace: str | None = None) -> None:
    """Desktop notification via notify-send (silently skipped if missing).

    `replace` is a key: notifications sharing it replace each other instead of
    stacking (mako/dunst x-canonical-private-synchronous hint).
    """
    if not have("notify-send"):
        return
    cmd = ["notify-send", "-u", urgency]
    if app:
        cmd += ["-a", app]
    if replace:
        cmd += ["-h", f"string:x-canonical-private-synchronous:{replace}"]
    subprocess.run([*cmd, title, body], check=False)


# ── processes ───────────────────────────────────────────────────────────────
def have(cmd: str) -> bool:
    return shutil.which(cmd) is not None


def require(*cmds: str, gui: bool = False) -> None:
    """Exit with an error if any command is missing (as a notification if gui)."""
    for cmd in cmds:
        if not have(cmd):
            if gui:
                notify("Error", f"{cmd} not found", "critical")
            die(f"'{cmd}' is required but not installed.")


def run(cmd: Sequence[str], *, check: bool = True, quiet: bool = False,
        **kwargs) -> subprocess.CompletedProcess:
    """Run a command (no shell). quiet=True discards stdout and stderr."""
    if quiet:
        kwargs.setdefault("stdout", subprocess.DEVNULL)
        kwargs.setdefault("stderr", subprocess.DEVNULL)
    return subprocess.run(list(cmd), check=check, **kwargs)


def output(cmd: Sequence[str], *, check: bool = True) -> str:
    """Run a command and return its stdout (stderr kept for the error message)."""
    return subprocess.run(list(cmd), check=check, text=True, capture_output=True).stdout


def succeeds(cmd: Sequence[str]) -> bool:
    try:
        return run(cmd, check=False, quiet=True).returncode == 0
    except FileNotFoundError:
        return False


# ── interaction ─────────────────────────────────────────────────────────────
def fzf(items: Iterable[str], *args: str, multi: bool = False) -> list[str]:
    """Pick from items with fzf. Returns the chosen lines ([] if cancelled)."""
    cmd = ["fzf", *args] + (["--multi"] if multi else [])
    proc = subprocess.run(cmd, input="\n".join(items), text=True, stdout=subprocess.PIPE)
    return [line for line in proc.stdout.splitlines() if line]


def confirm(prompt: str) -> bool:
    """y/N prompt; anything but y/Y (or EOF / Ctrl-C) is no."""
    try:
        return input(f"{prompt} [y/N] ").strip().lower() == "y"
    except (EOFError, KeyboardInterrupt):
        print()
        return False


# ── mpd ─────────────────────────────────────────────────────────────────────
def mpd_status() -> dict[str, str]:
    """Flags from the last line of `mpc status` (volume, repeat, random,
    single, consume). Notifies and exits if mpc is missing or MPD is down."""
    require("mpc", gui=True)
    proc = subprocess.run(["mpc", "status"], text=True, capture_output=True)
    if proc.returncode != 0:
        notify("MPD Error", "MPD daemon is not running", "critical")
        die("MPD daemon is not running")
    last = proc.stdout.strip().splitlines()[-1] if proc.stdout.strip() else ""
    return dict(re.findall(r"(\w+):\s*(\S+)", last))


# ── screenshots ─────────────────────────────────────────────────────────────
def screenshot(area: bool) -> None:
    """grim (optionally a slurp-selected area) -> satty for annotation; satty
    saves to ~/Pictures/Screenshots and copies with wl-copy."""
    import datetime
    from pathlib import Path

    save_dir = Path.home() / "Pictures" / "Screenshots"
    save_dir.mkdir(parents=True, exist_ok=True)
    grim = ["grim"]
    if area:
        sel = subprocess.run(["slurp"], text=True, stdout=subprocess.PIPE)
        if sel.returncode != 0 or not sel.stdout.strip():
            sys.exit(0)  # selection cancelled
        grim += ["-g", sel.stdout.strip()]
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    shot = subprocess.run([*grim, "-"], stdout=subprocess.PIPE, check=True).stdout
    subprocess.run(["satty", "--filename", "-", "--copy-command", "wl-copy",
                    "--output-filename", str(save_dir / f"screenshot-{stamp}.png")],
                   input=shot, check=True)


# ── audio ───────────────────────────────────────────────────────────────────
def cycle_audio(kind: str) -> None:
    """Make the next sink ("sink") or source ("source") the default, move
    every running stream onto it, and notify its name. Uses pactl names
    throughout (pipewire-pulse); monitor sources are skipped."""
    import json

    devices = [d for d in json.loads(output(["pactl", "-f", "json", "list", f"{kind}s"]))
               if not d["name"].endswith(".monitor")]
    if not devices:
        notify("Audio", f"No audio {kind}s found", "critical")
        sys.exit(1)
    names = [d["name"] for d in devices]
    current = output(["pactl", f"get-default-{kind}"]).strip()
    new = devices[(names.index(current) + 1) % len(devices)] if current in names else devices[0]

    run(["pactl", f"set-default-{kind}", new["name"]])
    streams = "sink-inputs" if kind == "sink" else "source-outputs"
    for line in output(["pactl", "list", "short", streams]).splitlines():
        run(["pactl", f"move-{streams[:-1]}", line.split()[0], new["name"]], check=False, quiet=True)
    notify("Audio Output" if kind == "sink" else "Audio Input", new.get("description") or new["name"],
           replace=f"audio-{kind}")
