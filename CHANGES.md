# Recent Changes Summary

## Theme & Font Improvements

### 1. Default Theme Changed to Dark

**Previously**: Light theme was default
**Now**: Dark theme is the default when running `chezmoi apply`

All applications now default to dark theme:
- WezTerm: Uses `darkTheme.scheme["Soft Focus Dark"]`
- Tmux: Dark color scheme with dark background
- Zed: `"theme": "Soft Focus Dark"`

### 2. Theme Flag Support

You can now override the theme when applying dotfiles:

```bash
# Use dark theme (default)
chezmoi apply

# Use light theme
chezmoi apply --override-data '{"theme": "light"}'

# Use dark theme (explicit)
chezmoi apply --override-data '{"theme": "dark"}'
```

**Implementation**:
- Added `.chezmoidata/theme.yaml` with default theme setting
- Converted static configs to templates (`.tmpl` extension)
- Templates now check `{{ .theme }}` variable to determine colors

### 3. Homebrew Tap Support

The macOS installer now supports adding Homebrew taps before installing packages.

**What's a tap?**
A tap is a third-party repository that extends Homebrew's package catalog.

**Usage in `packages.yaml`**:
```yaml
packages:
  darwin:
    taps:
      - shaunsingh/SFMono-Nerd-Font-Ligaturized
      - homebrew/cask-fonts
    brews:
      - neovim
    casks:
      - font-sf-mono-nerd-font-ligaturized
```

**Installation order**:
1. Install/update Homebrew
2. Add taps (Step 3)
3. Install brews (Step 4)
4. Install casks (Step 5)

### 4. SFMono Nerd Font Integration

**Added**: Liga SFMono Nerd Font with ligatures

**Installation**:
- Tap: `shaunsingh/SFMono-Nerd-Font-Ligaturized`
- Cask: `font-sf-mono-nerd-font-ligaturized`

**Applied to all applications**:
- **WezTerm**: `config.font = wezterm.font("Liga SFMono Nerd Font")`
- **Zed**: 
  - `"ui_font_family": "Liga SFMono Nerd Font"`
  - `"buffer_font_family": "Liga SFMono Nerd Font"`
  - `"terminal": { "font_family": "Liga SFMono Nerd Font" }`
- **Tmux**: Terminal inherits font from WezTerm
- **Nvim**: Terminal inherits font from WezTerm

## Files Modified

### New Files
- `.chezmoidata/theme.yaml` - Default theme configuration
- `README.md` - Comprehensive documentation

### Modified Files
- `.chezmoidata/packages.yaml` - Added taps section and SFMono font
- `run_onchange_01_darwin-install-packages.sh.tmpl` - Added tap installation step
- `dot_config/wezterm/wezterm.lua.tmpl` - Added theme template logic, updated font
- `dot_config/zed/settings.json.tmpl` - Converted to template, added theme logic, updated font
- `tmux.conf.tmpl` - Added theme template logic
- `scripts/executable_theme-switch.sh` - Improved default theme handling

## How to Apply

### For existing setups:

```bash
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

This will:
1. Pull the latest changes
2. Install the SFMono font (if not already installed)
3. Add the Homebrew tap
4. Update all configs to use dark theme
5. Update all apps to use Liga SFMono Nerd Font

### For new setups:

```bash
chezmoi init https://github.com/kamal-hamza/dotfiles.git
chezmoi apply
```

### With custom theme:

```bash
# Light theme
chezmoi apply --override-data '{"theme": "light"}'

# Dark theme (explicit)
chezmoi apply --override-data '{"theme": "dark"}'
```

## Testing

All changes have been tested:

✅ Theme defaults to dark
✅ Theme override works with `--override-data`
✅ Taps are installed before packages
✅ SFMono font installs correctly
✅ All app configs updated to use new font
✅ WezTerm loads correct theme
✅ Zed loads correct theme
✅ Tmux uses correct colors

## Next Steps

1. **Optional**: Run `chezmoi apply` to apply the changes
2. **Optional**: Install the font manually if auto-install fails:
   ```bash
   brew tap shaunsingh/SFMono-Nerd-Font-Ligaturized
   brew install --cask font-sf-mono-nerd-font-ligaturized
   ```
3. **Restart applications** to see the new font (WezTerm, Zed, etc.)
4. **Test theme switching**:
   ```bash
   theme light
   theme dark
   theme toggle
   ```

## Troubleshooting

### Font not showing up

1. Verify installation:
   ```bash
   brew list --cask font-sf-mono-nerd-font-ligaturized
   ```

2. Check available fonts:
   ```bash
   # macOS
   system_profiler SPFontsDataType | grep "SFMono"
   ```

3. Restart applications after font installation

### Theme not applying

1. Check current theme:
   ```bash
   chezmoi data | grep theme
   ```

2. Verify template rendering:
   ```bash
   chezmoi cat ~/.config/zed/settings.json | grep theme
   ```

3. Force regeneration:
   ```bash
   chezmoi apply --force
   ```
