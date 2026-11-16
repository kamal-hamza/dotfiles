# Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/), for
**macOS** (Homebrew), **Arch Linux + Hyprland** (pacman/AUR) and — prepared for —
**Windows** (winget, PowerShell).

The repo keeps two concerns apart:

- **App configuration** — dotfiles in `$HOME` (fish, nvim, zed, ghostty, git,
  tmux, Hyprland, quickshell, …). Always deployed; which ones depend on the OS and
  machine profile.
- **System provisioning** — installing packages, `/etc` files, systemd units,
  macOS defaults, the login shell. Opt-in per machine (`provision = true`), in
  `home/.chezmoiscripts/provision/`.

## Installation

```bash
# Install chezmoi (if not installed)
sh -c "$(curl -fsLS get.chezmoi.io)"

# Clone + answer the per-machine questions, then apply
chezmoi init --apply https://github.com/kamal-hamza/dotfiles.git
```

`chezmoi init` asks two questions once and stores the answers in
`~/.config/chezmoi/chezmoi.toml`:

| Setting     | Values               | Effect |
|-------------|----------------------|--------|
| `profile`   | `desktop` / `minimal` | `desktop` adds the Hyprland desktop configs and desktop packages (Linux). `minimal` = shell/editor/CLI configs only (default on WSL). |
| `provision` | `true` / `false`     | `true` lets chezmoi install packages and configure the system (uses sudo/admin). `false` = configs only. |

To change an answer later, edit `~/.config/chezmoi/chezmoi.toml` (or delete the
key and re-run `chezmoi init`). One-off "configs only" on a provisioned machine:
`chezmoi apply --exclude scripts`.

## Layout

```
.
├── .chezmoiroot              # "home": chezmoi's source state is home/, not the repo root
├── home/                     # ── everything chezmoi deploys / runs ──
│   ├── .chezmoi.toml.tmpl    # per-machine questions (profile, provision) + Windows interpreter
│   ├── .chezmoidata/         # data for templates (merged)
│   │   ├── packages-{darwin,arch,windows}.yaml
│   │   ├── system-arch.yaml  # systemd units to enable
│   │   ├── shell.yaml        # env vars / PATH / aliases for fish AND PowerShell
│   │   ├── tools.yaml        # install-lang definitions
│   │   └── 00-defaults.yaml  # safe fallbacks if `chezmoi init` hasn't run
│   ├── .chezmoiignore        # what to skip per OS / profile / provision
│   ├── .chezmoiscripts/
│   │   ├── provision/{darwin,linux,unix,windows}/   # only when provision = true
│   │   └── user/{unix,windows}/                     # always (per OS)
│   ├── .chezmoitemplates/    # shared template snippets (Python helpers)
│   ├── dot_config/           # ~/.config/* app configs
│   ├── dot_local/            # ~/.local/bin scripts etc.
│   ├── AppData/ Documents/   # Windows-only targets (Zed, PowerShell profile)
│   └── ...
├── system/                   # files installed OUTSIDE $HOME (e.g. /etc), never deployed by chezmoi
│   └── arch/{base,desktop}/etc/...
└── scripts/                  # repo tooling (quickshell TS build, sync), never deployed
```

## Provisioning

All provisioning scripts are Python, except one tiny bootstrap per OS that
installs Python itself (`00-bootstrap.sh` / `.ps1`). Order on `chezmoi apply`:

1. `00-bootstrap` — Xcode CLT + Homebrew / `python` via pacman / Python via winget
2. `10-packages` — from `packages-<os>.yaml` (re-runs when the list changes)
3. *(configs are written)*
4. `20-system-files`, `30-services` (Arch), `20-macos-defaults` (macOS)
5. `90-default-shell` — makes fish the login shell (macOS/Linux)

### Adding packages

Edit the right file, then `chezmoi apply`:

- macOS: `home/.chezmoidata/packages-darwin.yaml` (`taps`, `brews`, `casks`)
- Arch: `home/.chezmoidata/packages-arch.yaml` — `base` (every machine) or
  `desktop` (profile desktop), each with `pacman` and `aur`
- Windows: `home/.chezmoidata/packages-windows.yaml` (`winget` ids)

### System files (Arch)

Put the file at `system/arch/<base|desktop>/<absolute path>` — e.g.
`system/arch/desktop/etc/ly/config.ini` → `/etc/ly/config.ini`. It's installed
with sudo; the first overwrite keeps the original as `<file>.chezmoi-orig`.

## Shell

**fish** on macOS/Linux, **PowerShell 7** on Windows. Env vars, PATH and
aliases are defined once in `home/.chezmoidata/shell.yaml` and rendered into
both (`~/.config/fish/conf.d/10-env.fish`, `30-aliases.fish`, and the PowerShell
profile). Machine-specific env goes in untracked files managed by `dev-tool`
(`~/.config/fish/dev-tools/*.fish`). The old zsh config is still deployed as a
fallback.

## Configuration notes

- **Tmux**: `~/.tmux.conf`, prefix `Ctrl+s`; theme in `~/.config/tmux/themes/theme.tmux`
- **Ghostty**: `~/.config/ghostty/config`; palette in `themes/current`
- **Zed**: `home/dot_config/zed/` (Windows gets a copy under `AppData/Roaming/Zed`)

## Updating

```bash
chezmoi update        # git pull + apply
chezmoi init          # after the questions in .chezmoi.toml.tmpl change
```

## License

MIT
