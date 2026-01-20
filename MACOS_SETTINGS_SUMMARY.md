# macOS Settings Configuration - Quick Reference

## What It Configures

The script applies **12 focused settings** optimized for a clean, minimal macOS experience:

## Settings Applied

### 🎨 Appearance
- ✅ **System theme**: Dark mode
- ✅ **Icon theme**: Dark
- ✅ **Accent color**: Pink

### 🗂️ Dock
- ✅ **Size**: 30% (~36px)
- ✅ **Position**: Right side
- ✅ **Recent apps**: Hidden
- ✅ **Auto-hide**: Enabled (instant, fast animation)

### ⌨️ Keyboard
- ✅ **Key repeat rate**: Maximum speed

### 📁 Finder
- ✅ **Path bar**: Visible
- ✅ **Title bar**: Shows full path
- ✅ **Default view**: List view

### 🖱️ Trackpad
- ✅ **Tap to click**: Enabled
- ✅ **Secondary click**: Bottom right corner

## Usage

### Automatic (Recommended)
```bash
chezmoi apply
```

### Re-run After Editing
```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Quick Customizations

### Change Dock Size
```bash
# Current: 36px (30%)
defaults write com.apple.dock tilesize -int 36

# Smaller: 24px (20%)
defaults write com.apple.dock tilesize -int 24

# Larger: 48px (40%)
defaults write com.apple.dock tilesize -int 48
```

### Change Dock Position
```bash
# Current: Right
defaults write com.apple.dock orientation -string "right"

# Bottom
defaults write com.apple.dock orientation -string "bottom"

# Left
defaults write com.apple.dock orientation -string "left"
```

### Change Accent Color
```bash
# Current: Pink (6)
defaults write NSGlobalDomain AppleAccentColor -int 6

# Blue (4)
defaults write NSGlobalDomain AppleAccentColor -int 4

# Purple (5)
defaults write NSGlobalDomain AppleAccentColor -int 5

# Red (0)
defaults write NSGlobalDomain AppleAccentColor -int 0
```

### Switch to Light Mode
```bash
defaults write NSGlobalDomain AppleInterfaceStyle -string "Light"
# Or delete to use system default
defaults delete NSGlobalDomain AppleInterfaceStyle
```

### Slower Key Repeat
```bash
# Current: Maximum (1)
defaults write NSGlobalDomain KeyRepeat -int 1

# Normal (6)
defaults write NSGlobalDomain KeyRepeat -int 6

# Slow (12)
defaults write NSGlobalDomain KeyRepeat -int 12
```

### Change Finder Default View
```bash
# Current: List view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Icon view
defaults write com.apple.finder FXPreferredViewStyle -string "icnv"

# Column view
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Gallery view
defaults write com.apple.finder FXPreferredViewStyle -string "Flwv"
```

## After Changing Settings

Restart affected applications:
```bash
killall Dock
killall Finder
killall SystemUIServer
```

Or let the script do it automatically when you run `chezmoi apply`.

## Files

- **Script**: `run_once_before_03_darwin-configure-macos.sh.tmpl`
- **Full docs**: `MACOS_SETTINGS.md`
- **This file**: `MACOS_SETTINGS_SUMMARY.md`

## Notes

✅ Minimal and focused settings
✅ Clean, developer-friendly configuration
✅ Easy to customize
✅ Safe and reversible
✅ Runs automatically on setup

For complete documentation and all available options, see [MACOS_SETTINGS.md](MACOS_SETTINGS.md).
