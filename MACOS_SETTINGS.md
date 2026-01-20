# macOS Settings Configuration

This document explains the macOS system settings that are automatically configured by the `run_once_before_03_darwin-configure-macos.sh.tmpl` script.

## How It Works

The script runs **once** when you first apply your dotfiles (or when the script content changes). It uses the `defaults` command and other system utilities to configure macOS preferences.

## Running the Script

### Automatically (Recommended)
```bash
chezmoi apply
```

### Manually Re-run
If you want to re-run the script after editing:

```bash
# Option 1: Delete the state database
rm ~/.local/share/chezmoi/chezmoistate.boltdb

# Option 2: Delete specific script state
chezmoi state delete-bucket --bucket=scriptState

# Then apply
chezmoi apply
```

### Run Directly (Testing)
```bash
cd ~/.local/share/chezmoi
bash run_once_before_03_darwin-configure-macos.sh.tmpl
```

## Settings Configured

### Appearance

| Setting | Value | Command |
|---------|-------|---------|
| System theme | Dark | `defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"` |
| Accent color | Pink | `defaults write NSGlobalDomain AppleAccentColor -int 6` |
| Icon theme | Dark | `defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool false` |

**Accent Color Values:**
- `-1` = Graphite
- `0` = Red
- `1` = Orange
- `2` = Yellow
- `3` = Green
- `4` = Blue
- `5` = Purple
- `6` = Pink

### Dock

| Setting | Value | Command |
|---------|-------|---------|
| Icon size | 30% (~36px) | `defaults write com.apple.dock tilesize -int 36` |
| Position | Right | `defaults write com.apple.dock orientation -string "right"` |
| Recent apps | Hidden | `defaults write com.apple.dock show-recents -bool false` |
| Auto-hide | Enabled | `defaults write com.apple.dock autohide -bool true` |
| Auto-hide delay | Instant | `defaults write com.apple.dock autohide-delay -float 0.0` |
| Auto-hide animation | Fast (0.4s) | `defaults write com.apple.dock autohide-time-modifier -float 0.4` |

**Dock Position Values:**
- `"left"` = Left side
- `"bottom"` = Bottom (default)
- `"right"` = Right side

**Dock Size:**
- Small: 16-32px
- Medium: 48-64px
- Large: 80-128px

### Keyboard

| Setting | Value | Command |
|---------|-------|---------|
| Key repeat rate | Maximum (1) | `defaults write NSGlobalDomain KeyRepeat -int 1` |
| Initial delay | Very fast (10) | `defaults write NSGlobalDomain InitialKeyRepeat -int 10` |

**Key Repeat Values:**
- `1` = Fastest
- `2` = Very fast
- `6` = Normal
- `12` = Slow

### Finder

| Setting | Value | Command |
|---------|-------|---------|
| Path bar | Visible | `defaults write com.apple.finder ShowPathbar -bool true` |
| Full path in title | Enabled | `defaults write com.apple.finder _FXShowPosixPathInTitle -bool true` |
| Default view | List | `defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"` |

**Finder View Styles:**
- `"icnv"` = Icon view
- `"clmv"` = Column view
- `"Flwv"` = Gallery view
- `"Nlsv"` = List view

### Trackpad

| Setting | Value | Command |
|---------|-------|---------|
| Tap to click | Enabled | `defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true` |
| Secondary click | Bottom right corner | `defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2` |

**Secondary Click Values:**
- `0` = Off
- `1` = Bottom left corner
- `2` = Bottom right corner

## Customization

### To Change a Setting

Edit `run_once_before_03_darwin-configure-macos.sh.tmpl` and modify the value:

**Example - Change Dock size:**
```bash
# Current (30% = 36px)
defaults write com.apple.dock tilesize -int 36

# Larger (50% = 60px)
defaults write com.apple.dock tilesize -int 60

# Smaller (20% = 24px)
defaults write com.apple.dock tilesize -int 24
```

**Example - Change accent color to blue:**
```bash
# Current (pink)
defaults write NSGlobalDomain AppleAccentColor -int 6

# Blue
defaults write NSGlobalDomain AppleAccentColor -int 4
```

**Example - Move Dock to bottom:**
```bash
# Current (right)
defaults write com.apple.dock orientation -string "right"

# Bottom
defaults write com.apple.dock orientation -string "bottom"
```

### To Add New Settings

1. Find the `defaults` command for your setting:
   ```bash
   # Read current value
   defaults read com.apple.finder ShowPathbar
   
   # List all settings for an app
   defaults read com.apple.finder
   ```

2. Add it to the script in the appropriate section:
   ```bash
   print_info "Describing what this does..."
   defaults write com.apple.SomeApp SomeSetting -bool true
   print_success "Setting applied"
   ```

3. Re-run:
   ```bash
   chezmoi state delete-bucket --bucket=scriptState
   chezmoi apply
   ```

### To Disable a Setting

Comment it out:

```bash
# Don't want auto-hide Dock?
# print_info "Enabling Dock auto-hide..."
# defaults write com.apple.dock autohide -bool true
# print_success "Dock auto-hide enabled"
```

## Common Value Types

- **Boolean**: `-bool true` or `-bool false`
- **Integer**: `-int 42`
- **Float**: `-float 1.5`
- **String**: `-string "value"`
- **Array**: `-array 1 2 3`

## Reverting Changes

To revert a specific setting:

```bash
# Delete the setting (restores default)
defaults delete com.apple.dock autohide

# Or set it back to the original value
defaults write com.apple.dock autohide -bool false

# Restart the affected app
killall Dock
```

To see current values:

```bash
# Read specific setting
defaults read com.apple.dock autohide

# Read all Dock settings
defaults read com.apple.dock
```

## Useful Resources

- [defaults command documentation](https://ss64.com/osx/defaults.html)
- [macOS defaults list](https://macos-defaults.com/)
- [Apple's User Defaults documentation](https://developer.apple.com/documentation/foundation/userdefaults)

## Notes

- Most changes take effect immediately or after restarting the affected application
- The script automatically restarts Dock, Finder, and SystemUIServer
- Some settings may require logging out or restarting your Mac
- Settings are stored in `.plist` files in `~/Library/Preferences/`

## Troubleshooting

### Setting didn't apply

1. Manually restart the affected application:
   ```bash
   killall Dock
   killall Finder
   killall SystemUIServer
   ```

2. Log out and log back in

3. Restart your Mac (if needed)

### Check if setting was applied

```bash
# Read the current value
defaults read com.apple.dock autohide

# Should output: 1 (for true) or 0 (for false)
```

### Reset to defaults

```bash
# Delete custom setting to restore default
defaults delete com.apple.dock autohide

# Restart the app
killall Dock
```

## Testing Before Applying

To see what the script will change without running it:

```bash
# View the script
cat ~/.local/share/chezmoi/run_once_before_03_darwin-configure-macos.sh.tmpl

# See all defaults commands
grep "defaults write" ~/.local/share/chezmoi/run_once_before_03_darwin-configure-macos.sh.tmpl
```
