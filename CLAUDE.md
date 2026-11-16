# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a cross-platform dotfiles repository managed with [chezmoi](https://www.chezmoi.io/), targeting **macOS** (Homebrew) and **Arch Linux + Hyprland** (pacman/AUR), with **Windows** (winget + PowerShell) support scaffolded but not yet tested on a real machine. There is no build/test suite — this is configuration, not application code. The only validation is applying the config and observing the resulting behavior of the tools it configures.

An `AGENTS.md` also exists at the repo root. Treat it as a secondary reference, not ground truth: several things it describes have since changed (see "Known drift from AGENTS.md/README" below) — prefer this file and the actual source when they disagree.

## Commands

```bash
# Preview changes chezmoi would make to the home directory
chezmoi diff

# Apply the dotfiles (the primary way to "run"/validate this repo)
chezmoi apply

# (Re)answer the per-machine questions (profile, provision) -> ~/.config/chezmoi/chezmoi.toml
chezmoi init

# Apply configs only, skipping every script (no packages, no sudo)
chezmoi apply --exclude scripts

# Re-run scripts that chezmoi thinks already ran
chezmoi state delete-bucket --bucket=scriptState   # run_once_
chezmoi state delete-bucket --bucket=entryState    # run_onchange_

# See what's skipped on this machine / render a template
chezmoi ignored
chezmoi execute-template < home/path/to/file.tmpl
# ...as another OS (also works for `managed`, `cat`, `ignored`)
chezmoi --override-data '{"chezmoi":{"os":"windows"}}' managed

# Validate Neovim config loads without error (vim.pack plugins must already be installed)
nvim --headless "+qa"

# Lint YAML config data
yamllint home/.chezmoidata/*.yaml

# Sync a checkout elsewhere back into the actual chezmoi source dir during dev
./scripts/sync-to-chezmoi.sh

# Rebuild Quickshell TypeScript (*.mts -> committed *.mjs) after editing any .mts
./scripts/build-quickshell-ts.sh          # --check fails if a committed .mjs is stale
```

There's no linter/formatter invocation wired into this repo itself; individual app configs (e.g. `home/dot_config/nvim/lua/hkamal/plugins/conform.lua`) configure formatters for files *managed by* those apps, not for the dotfiles repo itself.

## Commits

Commit in small logical batches, never one big commit, so the history reads well:
- **Message style:** one short line, lowercase, past tense, no body or prefix, e.g. `added wezterm config`, `removed unused scripts`, `fixed tmux cursor reset after nvim`, `switched fish prompt to macos style`.
- **Grouping:** one concern per commit. Moves/renames get their own commit first as pure renames (`git mv`, no content changes), then content edits in follow-up commits. Docs (CLAUDE.md/README) go in a separate commit at the end.
- **Staging:** stage paths explicitly (`git add -- <paths>`), not `git add -A` for everything. Watch for paths already staged by `git rm`/`git mv` — a plain `git commit` includes everything in the index, so check `git status` before each commit.

## Architecture

### Repo layout: `.chezmoiroot` = `home`

The repo root is a container; chezmoi's source state is `home/` (set by `.chezmoiroot`). **All paths in the rest of this file are relative to `home/` unless they start with `system/`, `scripts/` or `home/`.** Outside `home/`, chezmoi deploys nothing: `system/` (files installed outside `$HOME`), `scripts/` (repo tooling), and the docs. `chezmoi source-path` returns `<repo>/home`; `.chezmoi.workingTree` in templates is the repo root.

### App config vs system provisioning

The core design split:
- **App configuration** = dotfiles in `$HOME` (`dot_config/`, `dot_local/`, `AppData/`, `Documents/`, …). chezmoi's source path *is* the target path, so OS/role-specific configs can't be moved into per-OS folders — they're selected by `.chezmoiignore` instead, which is sectioned: always-ignored / scripts / unix-only (ignored on Windows) / windows-only / linux desktop (Hyprland, only when `os == linux` and `profile == desktop`).
- **System provisioning** = package installs, `/etc` files, systemd units, macOS `defaults`, `chsh`. Lives only in `.chezmoiscripts/provision/<os>/`, and the whole `provision/` tree is ignored unless the machine opted in (`provision = true`).

Per-machine settings come from `.chezmoi.toml.tmpl` (rendered by `chezmoi init` into `~/.config/chezmoi/chezmoi.toml`, asked once via `promptChoiceOnce`/`promptBoolOnce`): `profile` (`desktop`|`minimal`; defaults to minimal on WSL) and `provision` (bool). `.chezmoidata/00-defaults.yaml` supplies the safe fallback (`minimal`, `false`) for a machine that hasn't re-run `chezmoi init` — config-file data overrides `.chezmoidata`. The config template also sets `[interpreters.py] command = "py"` on Windows.

### Scripts: `.chezmoiscripts/{provision,user}/<os>/`

`<os>` is `darwin`, `linux`, `windows`, or `unix` (= darwin + linux); `.chezmoiignore` drops the dirs that don't apply (`.chezmoiscripts/*/linux/**` etc. — ignore patterns match the script's target path, which keeps its subdirectories). `provision/` = needs sudo/admin, opt-in; `user/` = user-level, always runs (e.g. fisher plugin sync, Windows `XDG_CONFIG_HOME`).

All scripts are **Python**, except one bootstrap per OS that gets Python onto a fresh machine: `provision/{darwin,linux}/run_once_before_00-bootstrap.sh` (Xcode CLT + Homebrew / `pacman -S python`) and `provision/windows/run_once_before_00-bootstrap.ps1` (winget; exits 1 after installing so the user re-runs from a new terminal with `py` on PATH). Unix Python scripts use `#!/usr/bin/python3` (system Python, never a mise shim); on Windows the shebang is ignored and `.py` runs via `py -3`. Shared helpers (`header/info/ok/warn/err/run/succeeds/dedupe`) live in `.chezmoitemplates/provision/common.py` and are pulled in with `{{ template "provision/common.py" . }}` — scripts run from a temp dir, so they can't import a shared module. Data reaches Python as JSON: `json.loads(r'''{{ .packages.arch | toJson }}''')`; because the data is rendered into the script, `run_onchange_` scripts re-run whenever it changes. `system-files` embeds a sha256 of every file under `system/arch/` for the same reason. A template that renders empty is skipped (used by `user/unix/...fish-plugins` until fish exists).

Order on apply: `before_` scripts (alphabetical by full target path, so `00-bootstrap` < `10-packages`), then files, then `after_` scripts (`20-system-files`, `30-services`, `20-macos-defaults`, `90-default-shell`, `user/.../50-fish-plugins`). Package failures are reported but non-fatal so configs still apply.

### Central data drives templates

`.chezmoidata/*.yaml` files are merged (maps merge recursively, **lists replace**), so each list lives in exactly one file:
- `packages-darwin.yaml` (`packages.darwin.{taps,brews,casks}`), `packages-arch.yaml` (`packages.arch.{base,desktop}.{pacman,aur}` — `desktop` only installed for `profile == desktop`), `packages-windows.yaml` (`packages.windows.winget`).
- `system-arch.yaml` — `system.arch.{base,desktop}.{services,user_services}` systemd units.
- `shell.yaml` — `shell.env.{common,<os>}`, `shell.path.{common,<os>}`, `shell.aliases[]` (`name`, `cmd`, optional `os` list; `{args}` in `cmd` makes it a function). Rendered into fish (`dot_config/fish/conf.d/10-env.fish.tmpl`, `30-aliases.fish.tmpl`) **and** PowerShell (`Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`).

Adding a package, service, env var or alias means editing these YAML files, not the scripts/templates.

Files that belong outside `$HOME` go in `system/arch/<base|desktop>/<absolute path>` (e.g. `system/arch/desktop/etc/ly/config.ini`), installed by `provision/linux/run_onchange_after_20-system-files.py.tmpl` with `sudo install`, backing up the original once as `<file>.chezmoi-orig`.

### Shell: fish (macOS/Linux), PowerShell (Windows)

fish config is `dot_config/fish/`: `conf.d/00-homebrew.fish.tmpl` (renders empty off macOS), `05-colors.fish` (no syntax highlighting — everything `normal` except the grey autosuggestion; `functions/ls.fish` drops fish's `ls` color wrapper, fzf runs `--color=bw`; the look matches macOS Terminal), `10-env` and `30-aliases` (generated from `shell.yaml`), `20-tools.fish` (mise/zoxide/fzf), `15-ssh-agent.fish` (sets `SSH_AUTH_SOCK` on Linux unless already set: GNOME Keyring's `gcr-ssh-agent` — key passphrases saved in the login keyring that ly's `pam_gnome_keyring` unlocks — else OpenSSH's `ssh-agent.socket`; both user units come from `system-arch.yaml`), `90-dev-tools.fish`, plus `functions/` (prompt, `reload`, Tab = accept autosuggestion else complete via `__tab_accept_or_complete`, Alt+Tab = plain completion; Ctrl-R is fzf's own `fzf --fish` binding). Never manage `fish_variables` (ignored) and use `set -gx` / `fish_add_path -g` so nothing becomes a universal variable. Plugins: `fish_plugins` (fisher), synced by `.chezmoiscripts/user/unix/run_onchange_after_50-fish-plugins.py.tmpl`. The zsh config (`dot_zshenv`, `dot_config/zsh/`) is still deployed as a fallback and isn't generated from `shell.yaml`. GUI-session env vars belong in `dot_config/hypr/conf/envs.lua`, not the shell.

### Windows readiness

Unix-only targets (fish, zsh, tmux, `.local/bin`, `~/.config/zed`) are ignored on Windows; `AppData/`, `Documents/`, `.config/powershell/` are ignored elsewhere. XDG-aware apps (nvim, git, wezterm) reuse `dot_config/*` because `user/windows/run_once_after_10-xdg-config-home.py` sets `XDG_CONFIG_HOME=%USERPROFILE%\.config`. Zed ignores XDG on Windows, so `AppData/Roaming/Zed/*.tmpl` are one-line `{{ include "dot_config/zed/..." }}` copies — edit `dot_config/zed/`, never the AppData stubs. `.gitattributes` forces LF so a Windows checkout doesn't change file hashes (which would re-trigger `run_onchange_` scripts). None of the Windows pieces have been run on real Windows yet.

### Custom scripts + alias wiring

`dot_local/bin/executable_*` becomes `~/.local/bin/*` on apply (Unix only) — scripts for macOS **and** Linux. OS-specific scripts live in subfolders that are their own `PATH` entries: `dot_local/bin/linux/` → `~/.local/bin/linux/` (the Hyprland desktop scripts: mpd, audio, screenshots, music, bigpicture; deployed only for linux + profile desktop) and `dot_local/bin/darwin/` → `~/.local/bin/darwin/` (macOS-only; none yet). `.chezmoiignore` drops each folder elsewhere, and `shell.yaml` `path.linux`/`path.darwin` put it on `PATH`; the Hyprland session gets fish's login `PATH` through ly, so keybinds and quickshell find them by bare name (a newly added PATH dir needs a re-login to reach Hyprland). Each script that should be user-invocable needs an entry in `shell.aliases` in `.chezmoidata/shell.yaml` (with `os:` limiting it to where the script works); `dot_config/zsh/aliases.zsh` is the legacy zsh copy. Shared scripts: `create-project`/`delete-project` (`ccp`/`dcp`), `tmux-new` (`tt`). All scripts are **Python** (stdlib only, `#!/usr/bin/python3` so a mise-managed project Python can't break them; the music scripts still use `#!/usr/bin/env python3`). Shared helpers live in `dot_local/lib/scripts/common.py` (→ `~/.local/lib/scripts/`): output (`info/ok/warn/err/die`), `notify`, `run/output/succeeds/require`, `fzf`, `confirm`, `mpd_status`, `cycle_audio`, `screenshot`; importing it also installs an excepthook that turns failed commands into one-line errors. Scripts import it with `sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib" / "scripts"))` (`.parents[2]` from `bin/linux/`), like the music scripts do with `lib/music/musiclib.py`. Keep the command names (no `.py`) — keybinds, aliases and quickshell call them by name.

### Neovim: native `vim.pack`, not lazy.nvim

`dot_config/nvim` uses Neovim's **built-in** `vim.pack` plugin manager (Neovim 0.12+), not lazy.nvim. Each plugin file under `lua/hkamal/plugins/*.lua` calls `vim.pack.add({ "https://github.com/..." })` directly followed by its own `setup()`/config, and every file is `require`d in sequence from `lua/hkamal/plugins/init.lua` (order matters — e.g. theme plugins load first, colorscheme is applied at the end of that file via `hkamal.theme`, which persists the active colorscheme/`termguicolors` to `stdpath("state")`).

LSP servers use Neovim's native `vim.lsp.config`/`vim.lsp.enable` (0.11+), **not** `nvim-lspconfig`'s `setup()` API — `nvim-lspconfig` is only pulled in for its bundled `lsp/*.lua` server definitions and `schemastore.nvim`. Per-server overrides live in `dot_config/nvim/lsp/*.lua` (one file per server, returning a `vim.lsp.Config` table) and are wired up in `lua/hkamal/plugins/lspconfig.lua`, which also sets a shared `blink.cmp` capabilities config, a custom hover handler that folds cursor diagnostics into the hover float, and the `LspAttach` keymaps. `mason-tool-installer.lua` separately ensures the actual LSP/formatter/linter binaries are installed (Mason package names there won't always match the `vim.lsp.enable(...)` server names — e.g. `tailwindcss-language-server` vs `tailwindcss`).

When adding a new language: add its parser to `plugins/treesitter.lua`, add the LSP server name to `vim.lsp.enable({...})` and its Mason package to `mason-tool-installer.lua`, and add an `lsp/<name>.lua` file only if the defaults need overriding (root-dir resolution, `cmd`, `settings`, etc. — see `lsp/gopls.lua` for a nontrivial example).

### Hyprland config is Lua, not hyprlang

`dot_config/hypr/hyprland.lua` is the entrypoint and `require`s modules from `dot_config/hypr/conf/*.lua` (`execs`, `keymaps`, `monitors`, `envs`, `looks`, `animations`, `misc`) — this uses Hyprland's native Lua config support, not the traditional `.conf`/hyprlang format. `.luarc.json` points at `/usr/share/hypr/stubs` for LSP annotations of the Hyprland Lua API.

### Quickshell TypeScript (the one build step)

Non-trivial Quickshell logic is written in TypeScript: `home/dot_config/quickshell/**/*.mts` compiles to a sibling `*.mjs` ES module that QML imports directly (`import "Search.mjs" as Search` — Qt's QML engine supports `.mjs` modules natively). The generated `.mjs` is **committed** (with a "GENERATED ... do not edit" banner) so `chezmoi apply` never needs Node/TypeScript; the `.mts` sources and `tsconfig.json` are excluded from deployment in `.chezmoiignore`. Edit the `.mts`, run `scripts/build-quickshell-ts.sh` (it builds the *installed* chezmoi source, `$(chezmoi source-path)/dot_config/quickshell`) (pinned `typescript` via `bunx`), then apply. Currently this is just `modules/launcher/Search.mts`, the launcher's shared search/ranking engine.

### Theming: static, hardcoded, no switcher

There is no theme-switching system. Each app config just has its colors (the monochrome palette) hardcoded directly, as plain static files — no chezmoi templating, no `.chezmoidata` palette source, no `theme` command: `dot_config/rofi/theme.rasi`, `dot_config/mako/config`, `dot_config/waybar/style.css`, `dot_config/hypr/conf/looks.lua`, `dot_config/hypr/hyprlock.conf`, `dot_config/satty/config.toml`, `dot_config/wezterm/wezterm.lua` (macOS Terminal.app "Basic" look: SF Mono Nerd Font 11, `#1e1e1e` background, Terminal.app ANSI palette — not the monochrome palette), `dot_config/zed/settings.json` (plain `"theme"` key naming a Zed-bundled theme family), `dot_config/gtk-{3,4}.0/gtk.css`, `dot_config/tmux/themes/theme.tmux` (greys matching the WezTerm/Terminal.app look, not the monochrome palette; sourced by a pre-existing conditional `if-shell` hook in `dot_tmux.conf`, itself static and color-free), and `dot_config/git/config` (delta's diff/syntax colors plus git's native `[color "branch"/"diff"/"status"]` sections). To change the palette, hand-edit the hex values in each of these files directly — there's no single source of truth and no regeneration step. Neovim stays fully separate: it keeps its own working mechanism (`lua/hkamal/theme.lua`'s `~/.local/state/nvim/theme.txt`), set independently of everything above.

Wallpaper is set statically too, via `dot_config/hypr/hyprpaper.conf` (`hyprpaper`, started from `dot_config/hypr/conf/execs.lua`) — there is no live-switching wallpaper daemon.

### Secrets: Bitwarden

The repo holds no secret values. `.chezmoidata/secrets.yaml` lists `{name, item, field?}` entries (env var ← Bitwarden item's login password, or a custom `field`); `dot_config/fish/conf.d/private_40-secrets.fish.tmpl` renders them via chezmoi's `bitwarden`/`bitwardenFields` functions into `~/.config/fish/conf.d/40-secrets.fish` (0600, values single-quoted for fish). `.chezmoiignore` skips that file unless the vault is really unlocked (`BW_SESSION` set **and** `bw status` says `unlocked`, so a stale key never makes `bw` prompt for the master password) **and** the list is non-empty, so `chezmoi apply` with a locked vault leaves the existing file untouched instead of failing or blanking it. `functions/bwu.fish` logs in if needed, unlocks (`BW_SESSION`) and syncs; workflow: `bwu; and chezmoi apply`. `bitwarden-cli` + the desktop app are in all three package lists. Fish only for now (no PowerShell equivalent). SSH private keys come from Bitwarden too: `secrets.ssh_keys` maps `~/.ssh/<file>` → a secure note (in the vault's `chezmoi` folder) whose notes hold the key **verbatim, still passphrase-protected**, rendered by `private_dot_ssh/private_<file>.tmpl`; `.chezmoiignore` skips those files while the vault is locked. Because the bytes are unchanged, GNOME Keyring's agent (not Bitwarden's) keeps unlocking them with its saved passphrases. The `.pub` files and `~/.ssh/config` are plain repo files (the agent needs each `.pub` next to its key). Adding a key: store it as a secure note, add the map entry, a `private_<file>.tmpl` and the `.pub`.

### Dev-tools system (machine-specific, not tracked)

`dot_config/fish/dev-tools/*.fish.example` are committed templates for per-language shell env (Bun, .NET, Go, Node, Python). The active, machine-specific versions (`*.fish`, ignored via `.chezmoiignore`'s `.config/fish/dev-tools/*.fish`) are sourced by `conf.d/90-dev-tools.fish`; enable one by copying its `.example` (no helper script). PowerShell's equivalent is untracked `~/.config/powershell/dev-tools/*.ps1`.

## Known drift from AGENTS.md/README

Both docs predate several changes; when they conflict with the source tree, trust the source tree:
- Terminal is **WezTerm** (`dot_config/wezterm/wezterm.lua`, deployed on every OS); Ghostty was removed.
- Neovim plugin manager is **`vim.pack`** (native), not lazy.nvim (see above).
- The theme system they describe (Base16/flavours, dark/light toggle, `theme-gen`) has been removed entirely — see "Theming" above.
- `dot_pi/` (a Pi agent extension setup) has been removed from the working tree.
- The `dev-tool`, `install-lang`, `docker-run`/`docker-stop`, `man-tldr` and `font-switcher` scripts (and `tools.yaml`, `fonts.yaml`) have been removed.
- Source state moved under `home/` (`.chezmoiroot`); `packages.yaml` was split into `packages-<os>.yaml`; the top-level `run_*` shell scripts were replaced by Python scripts in `home/.chezmoiscripts/`; the login shell is fish, not zsh. AGENTS.md/README paths like `.chezmoidata/packages.yaml` or `dot_config/...` predate this.
