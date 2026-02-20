# Agent Guidelines for Dotfiles Repository

This repository contains cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/).
Target platforms: macOS (Homebrew) and Arch Linux (pacman/AUR).

## Repository Overview

**Primary Languages:**
- **Shell Script** (Bash/Zsh) - Dotfile automation and custom utilities
- **Lua** - Neovim configuration
- **YAML** - Configuration data for packages, themes, and tools
- **Mustache Templates** - Base16 theme generation

**Key Technologies:**
- Chezmoi for dotfile management
- Base16/Flavours for consistent theming
- lazy.nvim for Neovim plugin management

## Commands

### Testing & Validation

```bash
# Apply dotfiles (primary validation method)
chezmoi apply

# Preview changes without applying
chezmoi diff

# Verify Neovim configuration
nvim --headless "+Lazy! sync" +qa

# Test shell configuration (in new shell)
zsh -c "source ~/.zshrc && echo 'Shell config OK'"

# Validate YAML syntax
yamllint .chezmoidata/*.yaml

# Sync local changes back to chezmoi source
./scripts/sync-to-chezmoi.sh
```

### Theme Management

```bash
# Switch themes (via theme-switch script)
theme dark          # Switch to dark theme
theme light         # Switch to light theme
theme toggle        # Toggle between themes
theme status        # Show current theme

# Regenerate theme files (via theme-gen script)
theme-gen all       # Generate both dark and light themes
theme-gen dark      # Generate dark theme only
theme-gen light     # Generate light theme only

# Apply changes (triggers automatic theme generation)
chezmoi apply
```

### Project Management

```bash
# Create new project from GitHub template
ccp <template-repo> <project-name>

# Delete project (removes from filesystem and optionally GitHub)
dcp <project-name>

# Quick tmux session
tt <session-name>
```

### No Traditional Build/Test Framework
This is a configuration repository. Testing is manual via `chezmoi apply` and verifying
application behavior. There are no unit tests.

## File Structure

```
├── .chezmoidata/              # Central configuration data (YAML)
│   ├── packages.yaml          # Package definitions
│   ├── theme.yaml             # Active theme configuration
│   ├── tools.yaml             # Language tools & LSP definitions
│   └── fonts.yaml             # Font configuration
├── dot_config/                # Application configs (becomes ~/.config)
│   ├── nvim/                  # Neovim (Lua-based, lazy.nvim)
│   ├── zsh/                   # Zsh configuration
│   ├── wezterm/               # Terminal emulator
│   └── zed/                   # Code editor
├── dot_local/bin/             # Custom executables
├── theme-generators/          # Base16 theme system
│   ├── base16-schemes/        # Color scheme definitions
│   └── base16-templates/      # Mustache templates per app
└── run_*.sh.tmpl              # Chezmoi lifecycle scripts
```

## Code Style Guidelines

### Shell Scripts (Bash/Zsh)

**File Headers:**
```bash
#!/usr/bin/env bash

# =============================================================================
# Script Name - Brief description
# =============================================================================
# Detailed description of purpose and usage
#
# Usage:
#   script-name [options]
# =============================================================================

set -e  # Exit on error
```

**Error Handling:**
```bash
# Always use strict mode
set -e          # Exit on error
set -euo pipefail  # Strict error handling (when using pipes)

# Command availability checks
if ! command -v brew &> /dev/null; then
    print_error "Homebrew not found"
    exit 1
fi

# Fallback patterns for cross-platform compatibility
eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
```

**Output Functions:**
```bash
# Use color-coded output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
```

**Naming Conventions:**
- Variables: `lowercase_with_underscores`
- Functions: `lowercase_with_underscores`
- Constants: `UPPERCASE_WITH_UNDERSCORES`

### Lua (Neovim Configuration)

**Plugin Structure (lazy.nvim):**
```lua
-- Single plugin file: dot_config/nvim/lua/plugins/pluginname.lua
return {
    "author/plugin-name",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },  -- Lazy load
    cmd = "PluginCommand",                    -- Load on command
    keys = {                                  -- Load on keymap
        { "<leader>x", "<cmd>Command<cr>", desc = "Description" },
    },
    opts = {
        -- Plugin options (calls setup() automatically)
    },
    config = function()
        -- Manual configuration (use when opts isn't sufficient)
        require("plugin").setup({})
    end,
}
```

**Safe Requires:**
```lua
-- Use pcall for optional dependencies
local ok, module = pcall(require, "module-name")
if not ok then
    vim.notify("Module not found", vim.log.levels.WARN)
    return
end
```

**Naming Conventions:**
- Files: `lowercase-with-dashes.lua`
- Functions: `snake_case`
- Variables: `snake_case`
- Constants: `UPPERCASE_WITH_UNDERSCORES`

**Options:**
```lua
-- Use vim.opt for options
local opt = vim.opt
opt.number = true
opt.relativenumber = true
```

### YAML Configuration

**Structure (.chezmoidata files):**
```yaml
# =============================================================================
# File Purpose - Description
# =============================================================================
# Usage instructions

top_level_key:
    nested_key: value
    list:
        - item1
        - item2
```

**Naming Conventions:**
- Keys: `lowercase_with_underscores`
- Lists: Use YAML array syntax with `-`
- Comments: Use `#` with descriptive explanations

### Chezmoi Templates

**OS-Specific Conditionals:**
```bash
{{ if eq .chezmoi.os "darwin" -}}
# macOS-specific code
{{- else if eq .chezmoi.os "linux" -}}
# Linux-specific code
{{- end }}
```

**Variable Interpolation:**
```bash
{{- $scheme := .active_scheme | default "soft-focus-dark" }}
SCHEME="{{ $scheme }}"
```

**Naming Conventions:**
- Template files: `filename.tmpl` or `dot_filename.tmpl`
- Executables: `executable_scriptname` (becomes `scriptname` with +x)
- Hidden files: `dot_filename` (becomes `.filename`)
- Private files: `private_dot_filename` (becomes `.filename` with 600 perms)

## Best Practices

1. **Cross-Platform Compatibility**: Always test on both macOS and Linux when possible
2. **Idempotency**: Scripts should be safe to run multiple times
3. **Documentation**: Include usage instructions in file headers
4. **Error Messages**: Provide clear, actionable error messages with color coding
5. **Modularity**: One responsibility per file/script
6. **Conditional Loading**: Use lazy loading in Neovim plugins
7. **Theme Consistency**: All new applications should support Base16 theming
8. **State Management**: Use config files for persistent state (e.g., `~/.config/.current-theme`)
9. **Script Aliases**: Add new scripts to `dot_config/zsh/aliases.zsh` for user convenience

## Common Patterns

**Conditional Sourcing (Zsh):**
```bash
source_if_exists() {
    [[ -f "$1" && -r "$1" ]] && source "$1"
}
source_if_exists "$HOME/.config/zsh/aliases.zsh"
```

**OS Detection:**
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
fi
```

## Adding New Features

**New Package:**
1. Edit `.chezmoidata/packages.yaml`
2. Add to appropriate section (darwin/linux)
3. Run `chezmoi apply`

**New Script:**
1. Create `dot_local/bin/executable_scriptname` in chezmoi source
2. Add alias to `dot_config/zsh/aliases.zsh`
3. Run `chezmoi apply`

**New Neovim Plugin:**
1. Create `dot_config/nvim/lua/plugins/pluginname.lua`
2. Follow lazy.nvim spec format
3. Restart Neovim or run `:Lazy sync`

**New Theme Template:**
1. Add mustache template to `theme-generators/base16-templates/app-name/`
2. Update `run_onchange_after_generate-base16-themes.sh.tmpl`
3. Run `chezmoi apply`

## Key Script Inventory

**Location:** `dot_local/bin/` (installed to `~/.local/bin/` in PATH)

**Core Scripts:**
- `theme-switch` - Central theme manager for all applications (Zed, WezTerm, Tmux, Zsh, Neovim)
- `create-project` - Scaffold projects from GitHub templates with automatic tmux/editor setup
- `dev-tool` - Manage machine-specific language tool configs (uses `.example` pattern)
- `install-lang` - Cross-platform language toolchain installer (uses `tools.yaml`)
- `theme-gen` - Base16 theme generator (wrapper for flavours)
- `font-switcher` - Interactive font selection with fzf
- `delete-project` - Project cleanup (filesystem and GitHub)
- `tmux-new` - Quick tmux session management
- `man-tldr` - Man page search with tldr fallback

**Aliases (defined in `dot_config/zsh/aliases.zsh`):**
- `ccp` → `create-project`
- `dcp` → `delete-project`
- `tt` → `tmux-new`
- `m` → `man-tldr`
- `theme` → `theme-switch`

## Dev Tools System

**Purpose:** Machine-specific environment configuration for language tools without version control

**Pattern:**
1. Template files: `~/.config/zsh/dev-tools/*.zsh.example`
2. Active configs: `~/.config/zsh/dev-tools/*.zsh` (gitignored)
3. Sourced automatically by `.zshrc`

**Available Templates:**
- `node.zsh.example` - Node.js/npm/pnpm/bun paths
- `python.zsh.example` - Python/pip/virtualenv
- `dotnet.zsh.example` - .NET SDK paths
- `go.zsh.example` - GOPATH configuration
- `bun.zsh.example` - Bun runtime

**Management:**
```bash
dev-tool list              # List available templates
dev-tool add node          # Activate node template
dev-tool edit node         # Edit active config
dev-tool remove node       # Deactivate config
dev-tool show node         # Display config contents
```
