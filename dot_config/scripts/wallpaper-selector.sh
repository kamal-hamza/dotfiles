#!/bin/bash

# Set the directory where your wallpapers are stored
WALLPAPER_DIR="$HOME/.config/wallpapers"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/default.jpg"

# Get a list of all files in the wallpaper directory
wallpapers=("$WALLPAPER_DIR"/*)

# Create a string for Rofi to display
options=""
for wallpaper in "${wallpapers[@]}"; do
    options+=$(basename "$wallpaper")"\n"
done

# Show the Rofi menu and get the selected wallpaper
selected_wallpaper=$(echo -e "$options" | rofi -dmenu -p "Select Wallpaper")

# Determine the wallpaper path
if [ -n "$selected_wallpaper" ]; then
    # Use the selected wallpaper
    wallpaper_path="$WALLPAPER_DIR/$selected_wallpaper"
else
    # Use the default wallpaper if none was selected
    wallpaper_path="$DEFAULT_WALLPAPER"
fi

# Check if the wallpaper file exists, then set it
if [ -f "$wallpaper_path" ]; then
    wal -i "$wallpaper_path" -q -n -s -t
    swww img "$wallpaper_path" --transition-type any
    # Reload Waybar and other components as needed
    pkill waybar
    waybar &
else
    echo "Error: Wallpaper not found at $wallpaper_path"
    exit 1
fi
