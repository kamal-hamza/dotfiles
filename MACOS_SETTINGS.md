# macOS Settings Configuration

This document explains all the macOS system settings that are automatically configured by the `run_once_before_03_darwin-configure-macos.sh.tmpl` script.

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

### General UI/UX

| Setting | Value | Command |
|---------|-------|---------|
| Boot sound | Disabled | `sudo nvram SystemAudioVolume=" "` |
| Save panel | Expanded by default | `defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true` |
| Print panel | Expanded by default | `defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true` |
| Default save location | Disk (not iCloud) | `defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false` |
| Automatic app termination | Disabled | `defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true` |
| Login window clock | Shows system info | `sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName` |

### Keyboard & Input

| Setting | Value | Command |
|---------|-------|---------|
| Key repeat rate | Very fast (2) | `defaults write NSGlobalDomain KeyRepeat -int 2` |
| Initial key repeat | Fast (15) | `defaults write NSGlobalDomain InitialKeyRepeat -int 15` |
| Auto-correct | Disabled | `defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false` |
| Auto-capitalization | Disabled | `defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false` |
| Smart dashes | Disabled | `defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false` |
| Auto period (double-space) | Disabled | `defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false` |
| Smart quotes | Disabled | `defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false` |

### Trackpad

| Setting | Value | Command |
|---------|-------|---------|
| Tap to click | Enabled | `defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true` |
| Tracking speed | 1.5 | `defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5` |

### Finder

| Setting | Value | Command |
|---------|-------|---------|
| Hidden files | Visible | `defaults write com.apple.finder AppleShowAllFiles -bool true` |
| File extensions | All visible | `defaults write NSGlobalDomain AppleShowAllExtensions -bool true` |
| Status bar | Visible | `defaults write com.apple.finder ShowStatusBar -bool true` |
| Path bar | Visible | `defaults write com.apple.finder ShowPathbar -bool true` |
| Full path in title | Enabled | `defaults write com.apple.finder _FXShowPosixPathInTitle -bool true` |
| Folders on top | Enabled | `defaults write com.apple.finder _FXSortFoldersFirst -bool true` |
| Search scope | Current folder | `defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"` |
| Extension change warning | Disabled | `defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false` |
| .DS_Store on network | Disabled | `defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true` |
| .DS_Store on USB | Disabled | `defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true` |
| Default view | List view | `defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"` |
| ~/Library folder | Visible | `chflags nohidden ~/Library` |
| /Volumes folder | Visible | `sudo chflags nohidden /Volumes` |

### Dock

| Setting | Value | Command |
|---------|-------|---------|
| Icon size | 48px | `defaults write com.apple.dock tilesize -int 48` |
| Magnification | Enabled (64px) | `defaults write com.apple.dock magnification -bool true` |
| Window effect | Scale | `defaults write com.apple.dock mineffect -string "scale"` |
| Minimize to app icon | Enabled | `defaults write com.apple.dock minimize-to-application -bool true` |
| App indicators | Visible | `defaults write com.apple.dock show-process-indicators -bool true` |
| Auto-rearrange Spaces | Disabled | `defaults write com.apple.dock mru-spaces -bool false` |
| Auto-hide | Enabled | `defaults write com.apple.dock autohide -bool true` |
| Hidden apps translucent | Enabled | `defaults write com.apple.dock showhidden -bool true` |
| Recent applications | Hidden | `defaults write com.apple.dock show-recents -bool false` |
| Position | Bottom | `defaults write com.apple.dock orientation -string "bottom"` |

### Screenshots

| Setting | Value | Command |
|---------|-------|---------|
| Save location | Desktop | `defaults write com.apple.screencapture location -string "${HOME}/Desktop"` |
| Format | PNG | `defaults write com.apple.screencapture type -string "png"` |
| Shadow | Disabled | `defaults write com.apple.screencapture disable-shadow -bool true` |

### Menu Bar

| Setting | Value | Command |
|---------|-------|---------|
| Battery percentage | Visible | `defaults write com.apple.menuextra.battery ShowPercent -string "YES"` |

### Activity Monitor

| Setting | Value | Command |
|---------|-------|---------|
| Open main window | On launch | `defaults write com.apple.ActivityMonitor OpenMainWindow -bool true` |
| Dock icon | CPU history | `defaults write com.apple.ActivityMonitor IconType -int 5` |
| Show processes | All | `defaults write com.apple.ActivityMonitor ShowCategory -int 0` |
| Sort by | CPU usage | `defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"` |

### TextEdit

| Setting | Value | Command |
|---------|-------|---------|
| New document format | Plain text | `defaults write com.apple.TextEdit RichText -int 0` |
| Encoding | UTF-8 | `defaults write com.apple.TextEdit PlainTextEncoding -int 4` |

### Terminal

| Setting | Value | Command |
|---------|-------|---------|
| Character encoding | UTF-8 only | `defaults write com.apple.terminal StringEncodings -array 4` |

### Time Machine

| Setting | Value | Command |
|---------|-------|---------|
| New disk prompts | Disabled | `defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true` |

### Safari & WebKit

| Setting | Value | Command |
|---------|-------|---------|
| Search suggestions | Disabled | `defaults write com.apple.Safari UniversalSearchEnabled -bool false` |
| Full URL | Visible | `defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true` |
| Developer menu | Enabled | `defaults write com.apple.Safari IncludeDevelopMenu -bool true` |
| Web Inspector | Enabled | `defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true` |
| Do Not Track | Enabled | `defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true` |

## Customization

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

3. Apply the changes:
   ```bash
   chezmoi apply
   ```

### To Modify Existing Settings

Edit `run_once_before_03_darwin-configure-macos.sh.tmpl` and change the values:

**Example - Change Dock icon size from 48 to 36:**
```bash
# Before:
defaults write com.apple.dock tilesize -int 48

# After:
defaults write com.apple.dock tilesize -int 36
```

### To Disable Specific Settings

Comment out the lines you don't want:

```bash
# Don't auto-hide the Dock
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

## Useful Resources

- [defaults command documentation](https://ss64.com/osx/defaults.html)
- [macOS defaults list](https://macos-defaults.com/)
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles/blob/main/.macos) - Comprehensive example

## Reverting Changes

To revert a specific setting:

```bash
# Delete the setting (restores default)
defaults delete com.apple.finder ShowPathbar

# Or set it back to the original value
defaults write com.apple.finder ShowPathbar -bool false
```

To see what changed:

```bash
# Before running the script
defaults read com.apple.finder > before.txt

# After running the script
defaults read com.apple.finder > after.txt

# Compare
diff before.txt after.txt
```

## Notes

- Most changes take effect immediately or after restarting the affected application
- Some settings require logging out or restarting your Mac
- The script automatically restarts Dock, Finder, and SystemUIServer
- You may need to restart other applications manually for changes to take effect
