#!/bin/bash

# -----------------------------------------------------
# Pywal Theme Setter for Hyprland
# -----------------------------------------------------
# Description: This script selects a random wallpaper, generates a color
# scheme using pywal, and applies the theme to Hyprland, Waybar, and other apps.
#
# Dependencies: pywal, swww (or another wallpaper daemon)
# -----------------------------------------------------

# --- Configuration ---
# The directory where your wallpapers are stored.
WALLPAPER_DIR="$HOME/.config/wallpapers"

# --- Script Logic ---
# Check if the wallpaper directory exists and is not empty.
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR")" ]; then
    notify-send "Pywal Theme Setter" "Wallpaper directory not found or is empty: $WALLPAPER_DIR"
    exit 1
fi

# Select a random wallpaper from the directory.
# `shuf -n 1` picks one random line from the output of `find`.
wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)

if [ -z "$wallpaper" ]; then
    notify-send "Pywal Theme Setter" "No valid image files found in $WALLPAPER_DIR"
    exit 1
fi

# Run pywal to generate the color scheme.
# -i: The input image
# -q: Run quietly (no output)
# -n: Skip setting the wallpaper in the terminal background
# -s: Skip setting wallpaper with feh/nitrogen (we use swww)
# -t: Skip setting terminal colors in active terminals
wal -i "$wallpaper" -q -n -s -t

# Set the wallpaper using swww (a popular Wayland wallpaper daemon).
# Make sure swww is installed and initialized (e.g., `swww init` in your hyprland.conf).
swww img "$wallpaper" --transition-type any

# Reload Waybar to apply the new theme.
# We send a SIGUSR2 signal which tells Waybar to reload its config and styles.
killall -SIGUSR2 waybar

# Reload Hyprland to apply new border colors.
hyprctl reload

notify-send "Pywal" "Theme updated from $(basename "$wallpaper")"
