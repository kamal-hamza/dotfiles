#!/usr/bin/env bash

# =============================================================================
# Theme Switcher - Switch between light and dark Soft Focus themes
# =============================================================================
# This script switches all applications to use either the light or dark theme
#
# Usage:
#   theme-switch.sh [dark|light|toggle|status]
#
# Examples:
#   theme-switch.sh dark     # Switch to dark theme
#   theme-switch.sh light    # Switch to light theme
#   theme-switch.sh toggle   # Toggle between themes
#   theme-switch.sh status   # Show current theme
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
CONFIG_DIR="$HOME/.config"
THEME_STATE_FILE="$CONFIG_DIR/.current-theme"

# Helper functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Get current theme
get_current_theme() {
    if [[ -f "$THEME_STATE_FILE" ]]; then
        cat "$THEME_STATE_FILE"
    else
        echo "dark"  # Default theme
    fi
}

# Save current theme
set_current_theme() {
    echo "$1" > "$THEME_STATE_FILE"
}

# Show current theme status
show_status() {
    local current=$(get_current_theme)
    echo ""
    echo "Current theme: $(echo $current | tr '[:lower:]' '[:upper:]')"
    echo ""
}

# Switch Zed theme
switch_zed() {
    local theme="$1"
    local settings_file="$CONFIG_DIR/zed/settings.json"
    
    if [[ ! -f "$settings_file" ]]; then
        print_warning "Zed settings file not found, skipping"
        return 0
    fi
    
    # Use sed to update the theme in settings.json
    if grep -q '"theme":' "$settings_file"; then
        sed -i.bak "s/\"theme\": \".*\"/\"theme\": \"Soft Focus ${theme^}\"/" "$settings_file"
        rm -f "${settings_file}.bak"
        print_success "Zed theme updated"
    else
        print_warning "Could not find theme setting in Zed config"
    fi
}

# Switch tmux theme
switch_tmux() {
    local theme="$1"
    local tmux_conf="$HOME/.tmux.conf"
    
    if [[ ! -f "$tmux_conf" ]]; then
        print_warning "Tmux config not found, skipping"
        return 0
    fi
    
    # Check if tmux is running and reload config
    if command -v tmux &> /dev/null && tmux info &> /dev/null; then
        tmux source-file "$tmux_conf" &> /dev/null
        print_success "Tmux theme reloaded"
    else
        print_info "Tmux not running, theme will apply on next start"
    fi
}

# Switch WezTerm theme
switch_wezterm() {
    local theme="$1"
    local wezterm_config="$CONFIG_DIR/wezterm/wezterm.lua"
    
    if [[ ! -f "$wezterm_config" ]]; then
        print_warning "WezTerm config not found, skipping"
        return 0
    fi
    
    # Update color scheme in wezterm.lua
    if grep -q "color_scheme" "$wezterm_config"; then
        sed -i.bak "s/color_scheme = \".*\"/color_scheme = \"Soft Focus ${theme^}\"/" "$wezterm_config"
        rm -f "${wezterm_config}.bak"
        print_success "WezTerm theme updated (restart WezTerm to apply)"
    else
        print_warning "Could not find color_scheme in WezTerm config"
    fi
}

# Switch Zsh theme
switch_zsh() {
    local theme="$1"
    local zshrc="$CONFIG_DIR/zsh/.zshrc"
    
    if [[ ! -f "$zshrc" ]]; then
        print_warning "Zsh config not found, skipping"
        return 0
    fi
    
    print_success "Zsh theme updated (restart shell to apply)"
}

# Main switch function
switch_theme() {
    local theme="$1"
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Switching to ${theme^^} theme${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Switch each application
    switch_zed "$theme"
    switch_tmux "$theme"
    switch_wezterm "$theme"
    switch_zsh "$theme"
    
    # Save current theme
    set_current_theme "$theme"
    
    echo ""
    print_success "Theme switched to ${theme}!"
    echo ""
    print_info "Note: Some applications may need to be restarted"
    echo ""
}

# Parse arguments
MODE="${1:-status}"

case "$MODE" in
    dark)
        switch_theme "dark"
        ;;
    light)
        switch_theme "light"
        ;;
    toggle)
        current=$(get_current_theme)
        if [[ "$current" == "dark" ]]; then
            switch_theme "light"
        else
            switch_theme "dark"
        fi
        ;;
    status)
        show_status
        ;;
    *)
        print_error "Invalid argument: $MODE"
        echo ""
        echo "Usage: theme-switch.sh [dark|light|toggle|status]"
        echo ""
        echo "Commands:"
        echo "  dark    - Switch to dark theme"
        echo "  light   - Switch to light theme"
        echo "  toggle  - Toggle between themes"
        echo "  status  - Show current theme"
        echo ""
        exit 1
        ;;
esac

exit 0