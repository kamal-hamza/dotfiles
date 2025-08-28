#!/bin/bash
#   _ _ _ _____ __    __    _____ _____ _____ _____ _____
#  | | | |  _  |  |  |  |  |  _  |  _  |  _  |   __| __  |
#  | | | |     |  |__|  |__|   __|     |   __|   __|    -|
#  |_____|__|__|_____|_____|__|  |__|__|__|  |_____|__|__|
#

# Variables
current_wp_file="$CONFIG/wallpapers/default.jpg"
blurred_wp="$CONFIG/wallpapers/default.jpg"
blur="50x30"
wallpaper_dir="$CONFIG/wallpapers"

# Create current wallpaper file if it doesn't exist
if [ ! -f "$current_wp_file" ]; then
    touch "$current_wp_file"
    echo "$wallpaper_dir/default.jpg" > "$current_wp_file"
fi

# Get current wallpaper path
current_wallpaper=$(cat "$current_wp_file")

# Rofi command to select a new wallpaper
selected_wallpaper=$(find "$wallpaper_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | rofi -dmenu -p "Select Wallpaper")

# Exit if no wallpaper is selected
if [ -z "$selected_wallpaper" ]; then
    exit 0
fi

# Set the wallpaper variable to the selected one
wallpaper="$selected_wallpaper"

# Generate color scheme with wal
wal -q -i "$wallpaper"

# Source the new colors and relaunch waybar
source "$HOME/.cache/wal/colors.sh"
~/.config/waybar/launch.sh

# Set the new wallpaper with swww
transition_type="grow"
swww img "$wallpaper" \
    --transition-type=$transition_type \
    --transition-pos top-right

# Create a blurred version for the lock screen
magick "$wallpaper" -resize 1920x1080\! "$wallpaper"
echo ":: Resized"
if [ ! "$blur" == "0x0" ] ; then
    magick "$wallpaper" -blur "$blur" "$blurred_wp"
    echo ":: Blurred"
fi

# Update the current wallpaper file
echo "$wallpaper" > "$current_wp_file"
