#!/usr/bin/env bash

# =============================================================================
# Media Player Status Script for Waybar
# =============================================================================
# Checks mpc for playing music, falls back to playerctl, shows status with icon
#
# Usage:
#   media.sh [option]
# =============================================================================

set -e

# Color and formatting
PLAYING_ICON="󰐎"      # Music playing icon (play triangle)
PAUSED_ICON="󰏤"       # Music paused icon
STOPPED_ICON="󰓛"      # Stop icon
IDLE_ICON="󰽰"        # No music icon

# Check if mpc is available and if music server is running
check_mpc() {
    if ! command -v mpc &> /dev/null; then
        return 1
    fi
    
    # Get mpc status
    local status=$(mpc status 2>/dev/null)
    if [ -z "$status" ]; then
        return 1
    fi
    
    # Extract the status line (second line)
    local state=$(echo "$status" | sed -n '2p')
    
    # Check if playing (only show when actively playing, not paused)
    if echo "$state" | grep -q "\[playing\]"; then
        # Get the current song title
        local current=$(mpc current 2>/dev/null)
        if [ -n "$current" ]; then
            # Extract just the song title (after " - ")
            local title=$(echo "$current" | sed 's/.*[[:space:]]\-[[:space:]]//; s/[[:space:]]*(From.*//')
            echo "$PLAYING_ICON $title"
            return 0
        fi
    fi
    
    return 1
}

# Check playerctl as fallback
check_playerctl() {
    if ! command -v playerctl &> /dev/null; then
        return 1
    fi
    
    # Get the first available player
    local status=$(playerctl status 2>/dev/null) || return 1
    
    # Only show when actively playing, not paused
    if [ "$status" = "Playing" ]; then
        local title=$(playerctl metadata title 2>/dev/null) || title="Unknown"
        echo "$PLAYING_ICON $title"
        return 0
    fi
    
    return 1
}

# Main logic
if check_mpc; then
    exit 0
elif check_playerctl; then
    exit 0
else
    echo "$IDLE_ICON Nothing playing"
    exit 0
fi
