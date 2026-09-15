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

`dot_local/bin/executable_*` becomes `~/.local/bin/*` on apply. Each script that should be user-invocable needs a matching alias added in `dot_config/zsh/aliases.zsh` (documented convention, see the header comment there). Key scripts: `create-project`/`delete-project` (GitHub-template project scaffolding, aliased `ccp`/`dcp`), `dev-tool` (manages machine-specific env files, see below), `install-lang`, `font-switcher`, `man-tldr` (aliased `m`), `tmux-new` (aliased `tt`).

### Neovim: native `vim.pack`, not lazy.nvim

`dot_config/nvim` uses Neovim's **built-in** `vim.pack` plugin manager (Neovim 0.12+), not lazy.nvim. Each plugin file under `lua/hkamal/plugins/*.lua` calls `vim.pack.add({ "https://github.com/..." })` directly followed by its own `setup()`/config, and every file is `require`d in sequence from `lua/hkamal/plugins/init.lua` (order matters — e.g. theme plugins load first, colorscheme is applied at the end of that file via `hkamal.theme`, which persists the active colorscheme/`termguicolors` to `stdpath("state")`).

LSP servers use Neovim's native `vim.lsp.config`/`vim.lsp.enable` (0.11+), **not** `nvim-lspconfig`'s `setup()` API — `nvim-lspconfig` is only pulled in for its bundled `lsp/*.lua` server definitions and `schemastore.nvim`. Per-server overrides live in `dot_config/nvim/lsp/*.lua` (one file per server, returning a `vim.lsp.Config` table) and are wired up in `lua/hkamal/plugins/lspconfig.lua`, which also sets a shared `blink.cmp` capabilities config, a custom hover handler that folds cursor diagnostics into the hover float, and the `LspAttach` keymaps. `mason-tool-installer.lua` separately ensures the actual LSP/formatter/linter binaries are installed (Mason package names there won't always match the `vim.lsp.enable(...)` server names — e.g. `tailwindcss-language-server` vs `tailwindcss`).

When adding a new language: add its parser to `plugins/treesitter.lua`, add the LSP server name to `vim.lsp.enable({...})` and its Mason package to `mason-tool-installer.lua`, and add an `lsp/<name>.lua` file only if the defaults need overriding (root-dir resolution, `cmd`, `settings`, etc. — see `lsp/gopls.lua` for a nontrivial example).

### Hyprland config is Lua, not hyprlang

`dot_config/hypr/hyprland.lua` is the entrypoint and `require`s modules from `dot_config/hypr/conf/*.lua` (`execs`, `keymaps`, `monitors`, `envs`, `looks`, `animations`, `misc`) — this uses Hyprland's native Lua config support, not the traditional `.conf`/hyprlang format. `.luarc.json` points at `/usr/share/hypr/stubs` for LSP annotations of the Hyprland Lua API.

### Theming: static, hardcoded, no switcher

There is no theme-switching system. Each app config just has its colors (the monochrome palette) hardcoded directly, as plain static files — no chezmoi templating, no `.chezmoidata` palette source, no `theme` command: `dot_config/rofi/theme.rasi`, `dot_config/mako/config`, `dot_config/waybar/style.css`, `dot_config/hypr/conf/looks.lua`, `dot_config/hypr/hyprlock.conf`, `dot_config/satty/config.toml`, `dot_config/ghostty/themes/current` (referenced by a static `theme = current` line in `dot_config/ghostty/config` — kept as a stable target name so already-open Ghostty windows don't need special handling if the palette is ever hand-edited), `dot_config/zed/settings.json` (plain `"theme"` key naming a Zed-bundled theme family), `dot_config/gtk-{3,4}.0/gtk.css`, `dot_config/tmux/themes/theme.tmux` (sourced by a pre-existing conditional `if-shell` hook in `dot_tmux.conf`, itself static and color-free), and `dot_config/git/config` (delta's diff/syntax colors plus git's native `[color "branch"/"diff"/"status"]` sections). To change the palette, hand-edit the hex values in each of these files directly — there's no single source of truth and no regeneration step. Neovim stays fully separate: it keeps its own working mechanism (`lua/hkamal/theme.lua`'s `~/.local/state/nvim/theme.txt`), set independently of everything above.

Wallpaper is set statically too, via `dot_config/hypr/hyprpaper.conf` (`hyprpaper`, started from `dot_config/hypr/conf/execs.lua`) — there is no live-switching wallpaper daemon.

### Dev-tools system (machine-specific, gitignored)

`dot_config/zsh/dev-tools/*.zsh.example` are committed templates for per-language shell env setup (Node, Python, Go, .NET, Bun paths, etc.). The active, machine-specific versions (`*.zsh` without `.example`, gitignored via `.chezmoiignore`'s `.config/zsh/dev-tools/` entry) are sourced automatically by `.zshrc` and managed with `dev-tool {list,add,edit,remove,show} <name>` (`executable_dev-tool`). This is how machine-specific paths/versions stay out of version control while keeping a documented template in the repo.

## Known drift from AGENTS.md/README

Both docs predate several changes; when they conflict with the source tree, trust the source tree:
- Terminal is **Ghostty** (`dot_config/ghostty/`), not WezTerm — WezTerm is not present in this repo.
- Neovim plugin manager is **`vim.pack`** (native), not lazy.nvim (see above).
- The theme system they describe (Base16/flavours, dark/light toggle, `theme-gen`) has been removed entirely — see "Theming" above.
- `dot_pi/` (a Pi agent extension setup) has been removed from the working tree.
