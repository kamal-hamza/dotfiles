# macOS Settings Configuration - Quick Reference

## What It Does

The `run_once_before_03_darwin-configure-macos.sh.tmpl` script automatically configures **70+ macOS system settings** to optimize your Mac for development work.

## Key Benefits

✅ **Runs automatically** - Executes on first `chezmoi apply`
✅ **Developer-focused** - Settings optimized for coding/productivity
✅ **Well-documented** - Every setting explained
✅ **Easily customizable** - Comment out what you don't want
✅ **Safe** - Uses standard `defaults` command
✅ **Idempotent** - Safe to run multiple times

## Highlights

### 🚀 Performance & Productivity
- **Blazing fast key repeat** (2ms) for Vim users
- **Tap to click** enabled on trackpad
- **All autocorrect/smart features disabled** (perfect for coding)
- **Hidden files & extensions visible** in Finder
- **Dock auto-hides** for more screen space

### 👨‍💻 Developer-Friendly
- **Full file extensions** always shown
- **Path bar & status bar** in Finder
- **Plain text mode** in TextEdit
- **UTF-8 encoding** everywhere
- **Safari developer tools** enabled
- **.DS_Store files** prevented on network/USB

### 🎨 UI Improvements
- **Folders on top** when sorting
- **List view by default** in Finder
- **Battery percentage** shown
- **No recent apps** in Dock
- **CPU usage** in Activity Monitor Dock icon

## Usage

### First Time (Automatic)
```bash
chezmoi apply
# Script runs automatically, prompts for sudo password
```

### Re-run After Editing
```bash
# Delete state to force re-run
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Test Without Applying
```bash
# Dry run to see what would change
cd ~/.local/share/chezmoi
cat run_once_before_03_darwin-configure-macos.sh.tmpl | grep "defaults write"
```

## Quick Customization

### Disable a Setting
Comment it out:
```bash
# Don't want auto-hide Dock?
# defaults write com.apple.dock autohide -bool true
```

### Change a Value
Edit the number/string:
```bash
# Want larger Dock icons?
defaults write com.apple.dock tilesize -int 64  # was 48
```

### Add a New Setting
```bash
# Add in appropriate section:
print_info "Describing new setting..."
defaults write com.apple.SomeApp SomeSetting -bool true
print_success "New setting applied"
```

## What Changes After Running

### Immediate Changes
- Dock appearance and behavior
- Finder view settings
- Keyboard/trackpad behavior
- Screenshot settings

### Requires Logout
- Some input settings
- Login window changes

### Requires Restart
- Boot sound changes

## Safety Notes

- ✅ Uses standard macOS `defaults` command
- ✅ No system files are deleted or moved
- ✅ All changes are reversible via System Preferences
- ✅ Script asks for sudo password (needed for some settings)
- ⚠️  Creates a background process to keep sudo alive during execution

## Reverting

### Individual Setting
```bash
# Delete to restore default
defaults delete com.apple.dock autohide

# Or set to original value
defaults write com.apple.dock autohide -bool false
```

### All Settings
Just change them back in System Preferences or re-run with modified script.

## File Locations

- **Script**: `run_once_before_03_darwin-configure-macos.sh.tmpl`
- **Documentation**: `MACOS_SETTINGS.md` (detailed reference)
- **This file**: `MACOS_SETTINGS_SUMMARY.md` (quick reference)

## Full Documentation

See [MACOS_SETTINGS.md](MACOS_SETTINGS.md) for:
- Complete list of all 70+ settings
- Table with every `defaults` command
- How to find new settings to add
- Common value types reference
- Useful external resources

## Popular Customizations

### Want slower key repeat?
```bash
defaults write NSGlobalDomain KeyRepeat -int 6
defaults write NSGlobalDomain InitialKeyRepeat -int 25
```

### Want Dock on left/right?
```bash
defaults write com.apple.dock orientation -string "left"  # or "right"
```

### Want to keep auto-correct?
```bash
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true
```

### Want screenshots elsewhere?
```bash
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
mkdir -p ~/Pictures/Screenshots
```

## Troubleshooting

### Setting didn't apply
1. Check if it requires logout/restart
2. Manually restart the affected app:
   ```bash
   killall Finder
   killall Dock
   ```

### Want to see current values
```bash
# Read specific setting
defaults read com.apple.dock autohide

# Read all settings for an app
defaults read com.apple.dock
```

### Script won't run
```bash
# Make sure it's executable
chmod +x run_once_before_03_darwin-configure-macos.sh.tmpl

# Check chezmoi recognizes it
chezmoi status
```

## Next Steps

1. ✅ Script is already committed and pushed to GitHub
2. 🔄 Run `chezmoi apply` to execute it
3. 🔧 Customize settings in the script if needed
4. 📖 Read `MACOS_SETTINGS.md` for detailed documentation
