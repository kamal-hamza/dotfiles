#!/bin/bash

# -----------------------------------------------------
# Rofi Wallpaper Selector & Pywal Themer
# -----------------------------------------------------
# Description: This script displays wallpapers from a directory using Rofi,
# allowing the user to select one. It then generates and applies a new
# color scheme using pywal.
#
# Author: Gemini
# -----------------------------------------------------

# --- Configuration ---
# The directory where your wallpapers are stored.
WALLPAPER_DIR="$HOME/.config/wallpapers"

# --- Script Logic ---
# Check if the wallpaper directory exists.
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Selector" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Use Rofi to select a wallpaper.
# We show the basename of the file for a cleaner look.
# The `-i` flag makes the search case-insensitive.
selected_wallpaper_name=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec basename {} \; | rofi -dmenu -i -p "Select Wallpaper" -theme ~/.cache/wal/colors-rofi-dark.rasi)

# Exit if no wallpaper was selected (e.g., user pressed Esc).
if [ -z "$selected_wallpaper_name" ]; then
    exit 0
fi

# Construct the full path to the selected wallpaper.
wallpaper="$WALLPAPER_DIR/$selected_wallpaper_name"

# Run pywal to generate the color scheme.
# -i: The input image
# -q: Run quietly (no output)
# -n: Skip setting the wallpaper in the terminal background
# -s: Skip setting wallpaper with feh/nitrogen (we use swww)
# -t: Skip setting terminal colors in active terminals
wal -i "$wallpaper" -q -n -s -t

# Set the wallpaper using swww.
swww img "$wallpaper" --transition-type any

# Reload Waybar to apply the new theme.
# We send a SIGUSR2 signal which tells Waybar to reload its config and styles.
killall -SIGUSR2 waybar

# Reload Hyprland to apply new border colors.
hyprctl reload

notify-send "Pywal" "Theme updated from $(basename "$wallpaper")"
