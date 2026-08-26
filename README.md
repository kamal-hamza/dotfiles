# Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Features

- **Cross-platform**: Supports macOS (Homebrew) and Arch Linux (pacman/AUR)
- **Theme system**: Omarchy-style theme switching (colors + wallpaper) across all applications
- **Minimal setup**: Simple zsh configuration with essential plugins
- **Custom scripts**: Useful scripts for project management, tmux, and Docker

## Installation

### First time setup

```bash
# Install chezmoi (if not installed)
sh -c "$(curl -fsLS get.chezmoi.io)"

# Initialize with this repository
chezmoi init https://github.com/kamal-hamza/dotfiles.git

# Apply dotfiles (uses dark theme by default)
chezmoi apply
```

### Using a specific theme

The dotfiles ship with a few named themes (not just light/dark). See the
[Theme System](#theme-system) section below for the full list and how to
switch between them.

```bash
# Switch persistently (updates .chezmoidata/theme.yaml and applies)
theme set tokyo-night

# Preview a theme for a single apply, without persisting the switch
chezmoi apply --override-data '{"theme": "gruvbox"}'
```

## What's Included

### Applications

- **Editor**: Neovim, Zed
- **Terminal**: WezTerm with tmux
- **Shell**: Zsh with autosuggestions, syntax highlighting, and autopair
- **Tools**: fzf, tldr, git, obsidian, ChatGPT

### Fonts

- **Liga SFMono Nerd Font**: Monospace font with ligatures and nerd font icons
  - Installed automatically via Homebrew tap on macOS
  - Used in all terminal applications and editors

### Custom Scripts

All scripts are available in your PATH after running `chezmoi apply`:

- `ccp` - Create a new project with common structure
- `dcp` - Delete a project
- `tt` - Quick tmux session management
- `m` - Man pages with TLDR fallback
- `dr` - Run Docker containers
- `ds` - Stop Docker containers
- `theme` - Switch the active theme (colors + wallpaper) across every themed app

### Theme System

Omarchy-style theme switching: one command re-colors every themed app *and*
swaps the wallpaper. Each theme is a single palette file under
`.chezmoidata/themes/<name>.yaml`; chezmoi's own templating renders it into
every app's config, so there's no external tool (no flavours, matugen, or
pywal) involved.

Themed apps: rofi, mako, waybar, Hyprland (borders + hyprlock), GTK 3/4,
Ghostty, Zed, tmux, and git/delta. The wallpaper switches too, with a
transition, via `awww` (swww's successor). Switching also plays a full-screen
circular-reveal animation (a screenshot of your old desktop grows a hole
around the cursor to reveal the new one), similar to Omarchy's effect,
powered by a small standalone Quickshell config. Neovim uses its own existing
colorscheme-plugin mechanism instead (see `dot_config/nvim/lua/hkamal/theme.lua`).

**Switch themes:**
```bash
theme                  # interactive picker (fzf)
theme set tokyo-night   # switch to a specific theme
theme list              # list available themes
theme current           # show the active theme
theme next               # cycle to the next theme
```

**Add a new theme:** drop a new `.chezmoidata/themes/<name>.yaml` file with
the same shape as the existing ones (see `monochrome.yaml` for the full key
list) — no script or template changes needed.

## Package Management

### Adding packages

Edit `.chezmoidata/packages.yaml`:

```yaml
packages:
  darwin:
    taps:
      - homebrew/cask-fonts
    brews:
      - neovim
    casks:
      - docker
  arch:
    pacman:
      - docker
    aur:
      - visual-studio-code-bin
```

Then apply:
```bash
chezmoi apply
```

### Homebrew Taps

You can add third-party Homebrew taps to install packages not in the main repository:

```yaml
packages:
  darwin:
    taps:
      - shaunsingh/SFMono-Nerd-Font-Ligaturized
```

The tap will be added automatically before installing packages.

## Configuration

### Zsh

- Config location: `~/.config/zsh/`
- Aliases: `~/.config/zsh/aliases.zsh`

### Tmux

- Config location: `~/.tmux.conf`
- Prefix key: `Ctrl+s` (instead of default `Ctrl+b`)
- Theme: generated to `~/.config/tmux/themes/theme.tmux`, sourced by `.tmux.conf`

### Ghostty

- Config location: `~/.config/ghostty/config`
- Theme: generated to `~/.config/ghostty/themes/current`, referenced by `config`'s `theme = current`

### Zed

- Config location: `~/.config/zed/settings.json`
- Theme: `settings.json`'s `"theme"` key is generated per active theme, naming one of Zed's built-in theme families

## Updating

```bash
# Update dotfiles from repository
chezmoi update

# Or manually
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

## Advanced Usage

### Applying with custom theme

You can temporarily override the active theme for a single apply, without
persisting the switch:

```bash
chezmoi apply --override-data '{"theme": "gruvbox"}'
```

This is useful for:
- Previewing a theme before switching to it for real (`theme set <name>`)
- Using different themes on different machines
- CI/CD pipelines or automated setups

## Structure

```
~/.local/share/chezmoi/
├── .chezmoidata/
│   ├── packages.yaml       # Package definitions
│   ├── theme.yaml          # Active theme selector
│   └── themes/             # One palette file per theme
├── .chezmoitemplates/      # Reusable template snippets (e.g. gtk colors)
├── dot_config/
│   ├── zsh/                # Zsh configuration
│   ├── tmux/                # Tmux theme partial
│   ├── zed/                 # Zed editor configuration
│   └── nvim/                # Neovim configuration
├── scripts/                 # Custom scripts
└── run_onchange_*.sh.tmpl   # Package installers
```

## License

MIT

## macOS System Settings

The dotfiles automatically configure macOS system preferences on first run. This includes:

### Configured Settings
- **Keyboard**: Fast key repeat, disabled auto-correct/capitalization/smart quotes
- **Trackpad**: Tap to click enabled, optimized tracking speed
- **Finder**: Show hidden files, extensions, path bar, status bar
- **Dock**: Auto-hide, custom size, disable recent apps
- **Screenshots**: Save to Desktop in PNG format without shadows
- **Developer Tools**: Safari developer menu, Activity Monitor optimizations
- And many more...

### Customizing Settings

See [MACOS_SETTINGS.md](MACOS_SETTINGS.md) for:
- Complete list of all settings
- How to add/modify/disable settings
- Commands reference

### Re-running Configuration

The configuration runs automatically on first `chezmoi apply`. To re-run:

```bash
# Delete the state and re-apply
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

