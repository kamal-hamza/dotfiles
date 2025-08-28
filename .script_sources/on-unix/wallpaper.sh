#!/bin/bash
#   _ _ _ _____ __    __    _____ _____ _____ _____ _____
#  | | | |  _  |  |  |  |  |  _  |  _  |  _  |   __| __  |
#  | | | |     |  |__|  |__|   __|     |   __|   __|    -|
#  |_____|__|__|_____|_____|__|  |__|__|__|  |_____|__|__|
#

# Variables
wallpaper_dir="$HOME/.config/wallpapers"
blurred_dir="$wallpaper_dir/blurred"
current_wp_file="$wallpaper_dir/current_wallpaper.txt"
blur="50x30"

# Create the blurred directory if it doesn't exist
mkdir -p "$blurred_dir"

# Create current wallpaper file if it doesn't exist
if [ ! -f "$current_wp_file" ]; then
    touch "$current_wp_file"
    echo "$wallpaper_dir/default.jpg" > "$current_wp_file"
fi

# Rofi command to select a new wallpaper (shows only filename)
selected_filename=$(find "$wallpaper_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -printf "%f\n" | rofi -dmenu -p "Select Wallpaper")

# Exit if no wallpaper is selected
if [ -z "$selected_filename" ]; then
    exit 0
fi

# Construct the full path to the selected wallpaper
wallpaper="$wallpaper_dir/$selected_filename"

# Generate color scheme with wal
wal -q -i "$wallpaper" -o "$HOME/.config/scripts/post-pywal.sh"

# Source the new colors and relaunch waybar
source "$HOME/.cache/wal/colors.sh"
~/.config/waybar/launch.sh

# Copy the Zed theme to the proper directory
cp ~/.cache/wal/zed-pywal.json ~/.config/zed/themes/zed-pywal.json

# Set the new wallpaper with swww
transition_type="grow"
swww img "$wallpaper" \
    --transition-type=$transition_type \
    --transition-pos top-right

# Define the path for the blurred wallpaper
blurred_wp="$blurred_dir/$selected_filename"

# Create a blurred version for the lock screen
# First, resize the original image to a standard resolution (optional but good for consistency)
magick "$wallpaper" -resize 1920x1080\! "$blurred_wp"
echo ":: Resized"

# Then, apply the blur to the resized image
if [ ! "$blur" == "0x0" ] ; then
    magick "$blurred_wp" -blur "$blur" "$blurred_wp"
    echo ":: Blurred and saved to $blurred_wp"
fi

# Update the current wallpaper file
echo "$wallpaper" > "$current_wp_file"
