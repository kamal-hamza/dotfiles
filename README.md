# Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Features

- **Cross-platform**: Supports macOS (Homebrew) and Arch Linux (pacman/AUR)
- **Minimal setup**: Simple zsh configuration with essential plugins
- **Custom scripts**: Useful scripts for project management, tmux, and Docker

## Installation

### First time setup

```bash
# Install chezmoi (if not installed)
sh -c "$(curl -fsLS get.chezmoi.io)"

# Initialize with this repository
chezmoi init https://github.com/kamal-hamza/dotfiles.git

# Apply dotfiles
chezmoi apply
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
- Theme: static colors in `~/.config/tmux/themes/theme.tmux`, sourced by `.tmux.conf`

### Ghostty

- Config location: `~/.config/ghostty/config`
- Theme: static palette in `~/.config/ghostty/themes/current`, referenced by `config`'s `theme = current`

### Zed

- Config location: `~/.config/zed/settings.json`
- Theme: `settings.json`'s `"theme"` key names one of Zed's built-in theme families

## Updating

```bash
# Update dotfiles from repository
chezmoi update

# Or manually
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

## Structure

```
~/.local/share/chezmoi/
├── .chezmoidata/
│   └── packages.yaml       # Package definitions
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

