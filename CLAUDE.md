# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a cross-platform dotfiles repository managed with [chezmoi](https://www.chezmoi.io/), targeting **macOS** (Homebrew) and **Arch Linux + Hyprland** (pacman/AUR). There is no build/test suite — this is configuration, not application code. The only validation is applying the config and observing the resulting behavior of the tools it configures.

An `AGENTS.md` also exists at the repo root. Treat it as a secondary reference, not ground truth: several things it describes have since changed (see "Known drift from AGENTS.md/README" below) — prefer this file and the actual source when they disagree.

## Commands

```bash
# Preview changes chezmoi would make to the home directory
chezmoi diff

# Apply the dotfiles (the primary way to "run"/validate this repo)
chezmoi apply

# Re-run onchange/once scripts that chezmoi thinks already ran
chezmoi state delete-bucket --bucket=scriptState

# Validate Neovim config loads without error (vim.pack plugins must already be installed)
nvim --headless "+qa"

# Lint YAML config data
yamllint .chezmoidata/*.yaml

# Install language toolchains defined in .chezmoidata/tools.yaml
install-lang python go rust   # etc.

# Sync a checkout elsewhere back into the actual chezmoi source dir during dev
./scripts/sync-to-chezmoi.sh
```

There's no linter/formatter invocation wired into this repo itself; individual app configs (e.g. `dot_config/nvim/lua/hkamal/plugins/conform.lua`) configure formatters for files *managed by* those apps, not for the dotfiles repo itself.

## Architecture

### chezmoi source-state conventions

Standard chezmoi naming applies throughout: `dot_foo` → `~/.foo`, `executable_foo` → `foo` with `+x`, `private_foo` → mode 600, `*.tmpl` → Go-templated before writing. `run_once_*` / `run_onchange_*` scripts are lifecycle hooks — `run_onchange_01_{arch,darwin}-install-packages.sh.tmpl` re-run automatically whenever their templated content (which embeds `.chezmoidata/packages.yaml`) changes, so editing the package list is enough to trigger a reinstall on next `chezmoi apply`. `.chezmoiignore` conditionally excludes Linux/Hyprland-only paths (`dot_config/hypr`, `waybar`, `rofi`, `mpd`, `ncmpcpp`, `cava`, `mako`, `satty`, `quickshell`, `scripts/linux`) when `.chezmoi.os != "linux"`.

### Central data drives templated scripts

`.chezmoidata/packages.yaml` and `.chezmoidata/tools.yaml` are the source of truth consumed by Go templates elsewhere:
- `packages.yaml` (`packages.darwin.{taps,brews,casks}` / `packages.arch.{pacman,aur}`) is read by `run_onchange_01_*-install-packages.sh.tmpl` to install system packages per-OS.
- `tools.yaml` defines per-language install "steps" (mise, brew, cargo, go_install, npm_global, uv_tool, etc., with `depends_on` chains) consumed by `dot_local/bin/executable_install-lang`.

Adding a package or language tool means editing these YAML files, not the shell scripts.

### Custom scripts + alias wiring

`dot_local/bin/executable_*` becomes `~/.local/bin/*` on apply. Each script that should be user-invocable needs a matching alias added in `dot_config/zsh/aliases.zsh` (documented convention, see the header comment there) — `theme` is the one exception, since it's already a bare command name with no alias needed. Key scripts: `theme` (theme switching — see below), `create-project`/`delete-project` (GitHub-template project scaffolding, aliased `ccp`/`dcp`), `dev-tool` (manages machine-specific env files, see below), `install-lang`, `font-switcher`, `man-tldr` (aliased `m`), `tmux-new` (aliased `tt`).

### Neovim: native `vim.pack`, not lazy.nvim

`dot_config/nvim` uses Neovim's **built-in** `vim.pack` plugin manager (Neovim 0.12+), not lazy.nvim. Each plugin file under `lua/hkamal/plugins/*.lua` calls `vim.pack.add({ "https://github.com/..." })` directly followed by its own `setup()`/config, and every file is `require`d in sequence from `lua/hkamal/plugins/init.lua` (order matters — e.g. theme plugins load first, colorscheme is applied at the end of that file via `hkamal.theme`, which persists the active colorscheme/`termguicolors` to `stdpath("state")`).

LSP servers use Neovim's native `vim.lsp.config`/`vim.lsp.enable` (0.11+), **not** `nvim-lspconfig`'s `setup()` API — `nvim-lspconfig` is only pulled in for its bundled `lsp/*.lua` server definitions and `schemastore.nvim`. Per-server overrides live in `dot_config/nvim/lsp/*.lua` (one file per server, returning a `vim.lsp.Config` table) and are wired up in `lua/hkamal/plugins/lspconfig.lua`, which also sets a shared `blink.cmp` capabilities config, a custom hover handler that folds cursor diagnostics into the hover float, and the `LspAttach` keymaps. `mason-tool-installer.lua` separately ensures the actual LSP/formatter/linter binaries are installed (Mason package names there won't always match the `vim.lsp.enable(...)` server names — e.g. `tailwindcss-language-server` vs `tailwindcss`).

When adding a new language: add its parser to `plugins/treesitter.lua`, add the LSP server name to `vim.lsp.enable({...})` and its Mason package to `mason-tool-installer.lua`, and add an `lsp/<name>.lua` file only if the defaults need overriding (root-dir resolution, `cmd`, `settings`, etc. — see `lsp/gopls.lua` for a nontrivial example).

### Hyprland config is Lua, not hyprlang

`dot_config/hypr/hyprland.lua` is the entrypoint and `require`s modules from `dot_config/hypr/conf/*.lua` (`execs`, `keymaps`, `monitors`, `envs`, `looks`, `animations`, `misc`) — this uses Hyprland's native Lua config support, not the traditional `.conf`/hyprlang format. `.luarc.json` points at `/usr/share/hypr/stubs` for LSP annotations of the Hyprland Lua API.

### Theming: Omarchy-style, chezmoi-native

Theme switching is modeled on [Omarchy](https://github.com/basecamp/omarchy)'s architecture, adapted to use chezmoi's own templating instead of a separate renderer (no flavours/matugen/pywal dependency). Each theme is one palette file, `.chezmoidata/themes/<name>.yaml`, under a shared `themes:` top key — chezmoi deep-merges every file under `.chezmoidata/` that shares a top-level key, so all theme files land in one `.themes.<name>` map automatically. `.chezmoidata/theme.yaml`'s single `theme: "<name>"` key selects the active one. Adding a theme is just adding one new `.chezmoidata/themes/<name>.yaml` file — no template or script changes needed.

Themed app configs are chezmoi `.tmpl` files that open with `{{- $t := index .themes .theme -}}` and reference `$t.background.bg` etc. (see `.chezmoidata/themes/monochrome.yaml` for the full key schema): `dot_config/rofi/theme.rasi.tmpl`, `dot_config/mako/config.tmpl`, `dot_config/waybar/style.css.tmpl`, `dot_config/hypr/conf/looks.lua.tmpl`, `dot_config/hypr/hyprlock.conf.tmpl`, `dot_config/satty/config.toml.tmpl`, `dot_config/ghostty/themes/current.tmpl` (referenced by a permanently-static `theme = current` line in `dot_config/ghostty/config`), `dot_config/zed/settings.json.tmpl` (templates only the `"theme"` key, naming a Zed-bundled theme family), `dot_config/gtk-{3,4}.0/gtk.css.tmpl` (both thin wrappers around the shared `.chezmoitemplates/gtk-colors.css` snippet — chezmoi's mechanism for reusable template fragments, included via `{{ template "gtk-colors.css" . }}`), `dot_config/tmux/themes/theme.tmux.tmpl` (sourced by a pre-existing conditional `if-shell` hook in `dot_tmux.conf`, which itself stays static and color-free), and `dot_config/git/config.tmpl` (delta's diff/syntax colors plus git's native `[color "branch"/"diff"/"status"]` sections — the delta feature block is always named `"theme"`, same stable-target-name pattern as Ghostty's `themes/current`). Each theme's `apps.wallpaper` key names a file under the (unthemed, always-deployed) top-level `wallpapers/` dir. `ncmpcpp` and `cava` are intentionally out of scope — their config formats don't support arbitrary hex colors. Neovim also stays out of this templating system: it keeps its own working mechanism (`lua/hkamal/theme.lua`'s `~/.local/state/nvim/theme.txt`), and each theme's `apps.nvim_colorscheme` key just names one of the already-installed colorscheme plugins for the switch script to write there.

`dot_local/bin/executable_theme` is the switch script (`theme set <name>`, `theme list`, `theme current`, `theme next`, or bare `theme` for an fzf picker). `theme set` edits `.chezmoidata/theme.yaml`, runs `chezmoi apply` scoped to the known `THEMED_TARGETS` array (not a bare `chezmoi apply`, which would walk/diff the entire source tree — and could sweep in unrelated pending changes elsewhere in the tree), swaps the wallpaper live with an animated transition via `awww img <path> --transition-type grow` (the wallpaper daemon; see below), and nudges already-running apps (`hyprctl reload`, `makoctl reload`, `tmux source-file`). Waybar needs no reload hook — `config.jsonc` sets `"reload_style_on_change": true`, but that flag only takes effect for a waybar process started *after* it was added, so a running waybar needs one manual restart to pick it up. Every Hyprland-specific step is guarded with `command -v hyprctl`/`command -v makoctl`/`command -v awww`, so the same script is a no-op for those steps on macOS (where it deploys too, since `dot_local/bin` isn't OS-gated) — tmux/Ghostty/Zed/GTK/git theming still works there.

**Ghostty has no external reload trigger at all** (confirmed via `ghostty +edit-config --help`: "Ghostty isn't capable of this yet") — already-open windows need a manual reload (`Ctrl+Shift+,`, Ghostty's own default keybind for the `reload_config` action) or a restart; new windows pick up the change immediately since `config`'s `theme = current` line never changes. Multi-value chezmoi lookups use `mapfile`, not `read`, because `read` reports failure on a final line with no trailing newline even though it still captures the value — a real bug this script had that silently killed every reload step under `set -e`.

**Wallpaper daemon: `awww`, not hyprpaper.** `awww` (extra/awww on Arch — the renamed successor to `swww`, same author) owns the wallpaper layer; `hyprpaper` was removed. `dot_local/bin/executable_awww-init` starts `awww-daemon` and paints the active theme's wallpaper at Hyprland startup (`dot_config/hypr/conf/execs.lua`'s `hl.exec_cmd("awww-init")`); `theme set` handles live swaps with a transition afterward. There is no `hyprpaper.conf` anymore.

**Full-screen switch animation.** `dot_config/quickshell-theme-transition/` is a second, standalone Quickshell config (deliberately separate from `dot_config/quickshell/`, the in-progress bar project — never touch that one for this) that plays a circular-reveal transition: a screenshot of the whole desktop taken just before switching is shown fullscreen and frozen, then a hole centered on the cursor grows to reveal the already-updated real desktop underneath. `run_transition()` in `dot_local/bin/executable_theme` owns the sequencing — it screenshots every monitor (`grim -o <name>`), spawns `qs -p ~/.config/quickshell-theme-transition` in the background, waits ~200ms for it to paint, runs `cmd_apply` itself (in bash, not from QML — see below for why), writes to a marker file, then waits for the QML process to exit. The QML side is a passive `PanelWindow` on `WlrLayer.Overlay` using `QtQuick.Effects.MultiEffect` (`maskEnabled`/`maskInverted`/`maskSource`) for the circular mask and a `FileView` watching that marker (`fileChanged()`) to trigger the reveal `NumberAnimation`, which calls `Qt.quit()` when done. `cmd_set` falls back to a non-animated direct `cmd_apply` call if `qs`/`grim`/`jq`/`hyprctl`/`$WAYLAND_DISPLAY` aren't all available (`can_animate()`), and re-checks `theme current` afterward either way since a failed apply inside the animated path wouldn't otherwise surface as a script error.

Known-bad approach, don't repeat it: an earlier version had the QML spawn `theme _apply <name>` itself via `Quickshell.Io.Process` and waited on its `exited(exitCode, exitStatus)` signal to trigger the reveal. The process demonstrably completed (the theme actually switched) but the signal never fired in testing on Quickshell 0.3.1, hanging the overlay indefinitely. Bash owning the apply step directly and signaling completion through a `FileView`-watched marker file sidesteps that unreliable signal entirely.

### Dev-tools system (machine-specific, gitignored)

`dot_config/zsh/dev-tools/*.zsh.example` are committed templates for per-language shell env setup (Node, Python, Go, .NET, Bun paths, etc.). The active, machine-specific versions (`*.zsh` without `.example`, gitignored via `.chezmoiignore`'s `.config/zsh/dev-tools/` entry) are sourced automatically by `.zshrc` and managed with `dev-tool {list,add,edit,remove,show} <name>` (`executable_dev-tool`). This is how machine-specific paths/versions stay out of version control while keeping a documented template in the repo.

## Known drift from AGENTS.md/README

Both docs predate several changes; when they conflict with the source tree, trust the source tree:
- Terminal is **Ghostty** (`dot_config/ghostty/`), not WezTerm — WezTerm is not present in this repo.
- Neovim plugin manager is **`vim.pack`** (native), not lazy.nvim (see above).
- The theme system they describe (Base16/flavours, dark/light toggle, `theme-gen`) has been replaced — see "Theming" above.
- `dot_pi/` (a Pi agent extension setup) has been removed from the working tree.
