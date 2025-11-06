#!/usr/bin/env bash
# Enhanced Theme Switcher for Soft Focus Dotfiles (Unix/macOS/Linux)
# Switches between light and dark themes with proper reload mechanisms
# Author: Hamza Kamal

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
CHEZMOI_ROOT="${CHEZMOI_ROOT:-$HOME/.local/share/chezmoi}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
THEME_STATE_FILE="$CONFIG_DIR/.soft-focus-theme"

# Functions
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  🎨 Soft Focus Theme Switcher${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

get_current_theme() {
    if [ -f "$THEME_STATE_FILE" ]; then
        cat "$THEME_STATE_FILE"
    else
        echo "dark"
    fi
}

save_theme_state() {
    echo "$1" > "$THEME_STATE_FILE"
}

detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        *)          echo "unknown" ;;
    esac
}

# Enhanced application switchers with reload

switch_kitty() {
    local theme=$1
    local kitty_conf="$CONFIG_DIR/kitty/kitty.conf"

    if [ ! -f "$kitty_conf" ]; then
        return
    fi

    if grep -q "^include.*soft-focus-" "$kitty_conf" 2>/dev/null; then
        sed -i.bak "s|^include.*soft-focus-.*\.conf|include themes/soft-focus-${theme}.conf|" "$kitty_conf"
        rm -f "${kitty_conf}.bak"
        print_success "Kitty theme updated"
        
        # Reload all Kitty instances
        if command -v kitty &> /dev/null; then
            killall -SIGUSR1 kitty 2>/dev/null && print_success "Kitty reloaded" || true
        fi
    fi
}

switch_wezterm() {
    local theme=$1
    local wezterm_lua="$CONFIG_DIR/wezterm/wezterm.lua"

    if [ ! -f "$wezterm_lua" ]; then
        return
    fi

    # Update color_scheme in wezterm.lua
    if grep -q 'color_scheme.*=.*"Soft Focus' "$wezterm_lua" 2>/dev/null; then
        if [ "$theme" = "dark" ]; then
            sed -i.bak 's/color_scheme.*=.*"Soft Focus Light"/color_scheme = "Soft Focus Dark"/' "$wezterm_lua"
        else
            sed -i.bak 's/color_scheme.*=.*"Soft Focus Dark"/color_scheme = "Soft Focus Light"/' "$wezterm_lua"
        fi
        rm -f "${wezterm_lua}.bak"
        print_success "WezTerm theme updated"
    else
        print_info "WezTerm: Add 'color_scheme = \"Soft Focus ${theme^}\"' to wezterm.lua"
    fi

    # Try to reload WezTerm using CLI
    if command -v wezterm &> /dev/null; then
        # WezTerm auto-reloads config, but we can signal windows
        wezterm cli list 2>/dev/null | while read -r line; do
            pane_id=$(echo "$line" | awk '{print $3}')
            [ -n "$pane_id" ] && wezterm cli activate-pane --pane-id "$pane_id" 2>/dev/null || true
        done
        print_info "WezTerm will reload automatically"
    fi
}

switch_tmux() {
    local theme=$1
    local tmux_conf="$HOME/.tmux.conf"

    if [ ! -f "$tmux_conf" ]; then
        return
    fi

    if grep -q "^source.*soft-focus-" "$tmux_conf" 2>/dev/null; then
        sed -i.bak "s|^source.*soft-focus-.*\.conf|source ~/.config/tmux/themes/soft-focus-${theme}.conf|" "$tmux_conf"
        rm -f "${tmux_conf}.bak"
        print_success "Tmux theme updated"
        
        # Reload tmux if running
        if command -v tmux &> /dev/null && tmux info &> /dev/null; then
            tmux source-file "$tmux_conf" 2>/dev/null && print_success "Tmux reloaded" || true
        fi
    fi
}

switch_yazi() {
    local theme=$1
    local yazi_theme="$CONFIG_DIR/yazi/theme.toml"

    if [ ! -f "$yazi_theme" ]; then
        return
    fi

    if grep -q "themes/soft-focus-" "$yazi_theme" 2>/dev/null; then
        sed -i.bak "s|themes/soft-focus-.*\.toml|themes/soft-focus-${theme}.toml|" "$yazi_theme"
        rm -f "${yazi_theme}.bak"
        print_success "Yazi theme updated"
        print_info "Yazi: Restart to see changes"
    fi
}

switch_btop() {
    local theme=$1
    local btop_conf="$CONFIG_DIR/btop/btop.conf"

    if [ ! -f "$btop_conf" ]; then
        return
    fi

    if grep -q "^color_theme" "$btop_conf" 2>/dev/null; then
        sed -i.bak "s|^color_theme.*|color_theme = \"soft-focus-${theme}\"|" "$btop_conf"
        rm -f "${btop_conf}.bak"
        print_success "btop theme updated"
        print_info "btop: Restart to see changes"
    fi
}

switch_nvim() {
    local theme=$1
    local nvim_state="$CONFIG_DIR/nvim/.theme-mode"

    # Write theme state for Neovim to read
    echo "$theme" > "$nvim_state"
    print_success "Neovim theme state updated"

    # Try to reload all Neovim instances via remote commands
    if command -v nvim &> /dev/null; then
        # Find nvim socket files
        for socket in /tmp/nvim*/0; do
            if [ -S "$socket" ]; then
                if [ "$theme" = "dark" ]; then
                    nvim --server "$socket" --remote-send '<Cmd>set background=dark<CR>' 2>/dev/null || true
                else
                    nvim --server "$socket" --remote-send '<Cmd>set background=light<CR>' 2>/dev/null || true
                fi
            fi
        done
        print_info "Neovim: Background set to $theme (active instances updated)"
    fi
}

switch_zed() {
    local theme=$1
    local zed_settings="$CONFIG_DIR/zed/settings.json"

    if [ ! -f "$zed_settings" ]; then
        return
    fi

    if grep -q '"theme":' "$zed_settings" 2>/dev/null; then
        if [ "$theme" = "dark" ]; then
            sed -i.bak 's/"theme": *"Soft Focus Light"/"theme": "Soft Focus Dark"/' "$zed_settings"
        else
            sed -i.bak 's/"theme": *"Soft Focus Dark"/"theme": "Soft Focus Light"/' "$zed_settings"
        fi
        rm -f "${zed_settings}.bak"
        print_success "Zed theme updated"
        print_info "Zed: Restart or reload window to see changes"
    fi
}

switch_hyprland() {
    local theme=$1
    local hypr_conf="$CONFIG_DIR/hypr/hyprland.conf"

    if [ ! -f "$hypr_conf" ]; then
        return
    fi

    if grep -q "source.*soft-focus-" "$hypr_conf" 2>/dev/null; then
        sed -i.bak "s|source.*soft-focus-.*\.conf|source = ~/.config/hypr/themes/soft-focus-${theme}.conf|" "$hypr_conf"
        rm -f "${hypr_conf}.bak"
        print_success "Hyprland theme updated"

        if command -v hyprctl &> /dev/null; then
            hyprctl reload 2>/dev/null && print_success "Hyprland reloaded" || true
        fi
    fi
}

switch_waybar() {
    local theme=$1
    local waybar_config="$CONFIG_DIR/waybar/config"
    local waybar_style="$CONFIG_DIR/waybar/style.css"

    if [ ! -d "$CONFIG_DIR/waybar" ]; then
        return
    fi

    # Update style.css to import correct theme
    if [ -f "$waybar_style" ] && grep -q "@import.*soft-focus-" "$waybar_style" 2>/dev/null; then
        sed -i.bak "s|@import.*soft-focus-.*\.css|@import \"themes/soft-focus-${theme}.css\"|" "$waybar_style"
        rm -f "${waybar_style}.bak"
        print_success "Waybar theme updated"
    fi

    # Restart waybar
    if pgrep -x waybar > /dev/null; then
        killall waybar 2>/dev/null
        waybar &
        disown
        print_success "Waybar restarted"
    fi
}

switch_rofi() {
    local theme=$1
    local rofi_config="$CONFIG_DIR/rofi/config.rasi"

    if [ ! -f "$rofi_config" ]; then
        return
    fi

    if grep -q "@theme.*soft-focus-" "$rofi_config" 2>/dev/null; then
        sed -i.bak "s|@theme.*soft-focus-.*\.rasi|@theme \"themes/soft-focus-${theme}.rasi\"|" "$rofi_config"
        rm -f "${rofi_config}.bak"
        print_success "Rofi theme updated"
    fi
}

switch_gtk() {
    local theme=$1
    local gtk3_settings="$CONFIG_DIR/gtk-3.0/settings.ini"

    if [ ! -f "$gtk3_settings" ]; then
        return
    fi

    if [ "$theme" = "dark" ]; then
        sed -i.bak 's/gtk-application-prefer-dark-theme=0/gtk-application-prefer-dark-theme=1/' "$gtk3_settings"
    else
        sed -i.bak 's/gtk-application-prefer-dark-theme=1/gtk-application-prefer-dark-theme=0/' "$gtk3_settings"
    fi
    rm -f "${gtk3_settings}.bak"
    print_success "GTK theme preference updated"
}

switch_macos_appearance() {
    local theme=$1

    if [ "$(detect_os)" != "macos" ]; then
        return
    fi

    if [ "$theme" = "dark" ]; then
        osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true' 2>/dev/null
        print_success "macOS system appearance set to dark"
    else
        osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false' 2>/dev/null
        print_success "macOS system appearance set to light"
    fi
}

# Main switching logic
switch_theme() {
    local target_theme=$1

    echo
    print_info "Switching to ${target_theme} theme..."
    echo

    # Terminal emulators
    switch_kitty "$target_theme"
    switch_wezterm "$target_theme"

    # Terminal multiplexer
    switch_tmux "$target_theme"

    # File manager
    switch_yazi "$target_theme"

    # System monitor
    switch_btop "$target_theme"

    # Editors
    switch_nvim "$target_theme"
    switch_zed "$target_theme"

    # Window manager and desktop (Linux)
    if [ "$(detect_os)" = "linux" ]; then
        switch_hyprland "$target_theme"
        switch_waybar "$target_theme"
        switch_rofi "$target_theme"
        switch_gtk "$target_theme"
    fi

    # macOS system appearance
    if [ "$(detect_os)" = "macos" ]; then
        switch_macos_appearance "$target_theme"
    fi

    # Save state
    save_theme_state "$target_theme"

    echo
    print_success "Theme switched to: ${target_theme}"
    echo
    print_info "Note: Some applications may require manual restart:"
    echo "      • WezTerm (auto-reloads)"
    echo "      • Zed (reload window)"
    echo "      • Neovim (new instances only)"
    echo "      • Yazi, btop (restart)"
    echo
}

# Auto-switch based on time
auto_switch() {
    local hour=$(date +%H)
    local current_theme=$(get_current_theme)
    local dark_start=${DARK_START:-18}
    local dark_end=${DARK_END:-8}

    if [ "$hour" -ge "$dark_start" ] || [ "$hour" -lt "$dark_end" ]; then
        target="dark"
    else
        target="light"
    fi

    if [ "$current_theme" != "$target" ]; then
        print_info "Auto-switching theme based on time (${hour}:00)"
        switch_theme "$target"
    else
        print_info "Current theme ($current_theme) is appropriate for time ${hour}:00"
    fi
}

# Usage
show_usage() {
    cat << EOF
Usage: $(basename "$0") [COMMAND]

Commands:
    dark            Switch to dark theme
    light           Switch to light theme
    toggle          Toggle between dark and light
    auto            Auto-switch based on time of day
    status          Show current theme
    help            Show this help message

Environment Variables:
    DARK_START      Hour to switch to dark (default: 18)
    DARK_END        Hour to switch to light (default: 8)

Examples:
    $(basename "$0") dark
    $(basename "$0") toggle
    $(basename "$0") auto

To auto-switch on schedule, add to crontab:
    */30 * * * * ~/.local/bin/theme-switch auto

EOF
}

# Main
main() {
    local command=${1:-help}

    case "$command" in
        dark)
            print_header
            switch_theme "dark"
            ;;
        light)
            print_header
            switch_theme "light"
            ;;
        toggle)
            print_header
            current=$(get_current_theme)
            if [ "$current" = "dark" ]; then
                switch_theme "light"
            else
                switch_theme "dark"
            fi
            ;;
        auto)
            print_header
            auto_switch
            ;;
        status)
            current=$(get_current_theme)
            print_info "Current theme: $current"
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            echo
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
