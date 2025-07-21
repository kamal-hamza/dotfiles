#!/bin/bash

# Updated wallpaper directory
WALLPAPER_DIR="$HOME/.config/wallpapers"

menu() {
    # This function finds all images and prepares them for the menu
    find "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \)
}

main() {
    # Use Rofi instead of Wofi for the selection menu
    selected_wallpaper=$(menu | rofi -dmenu -i -p "Select Wallpaper:")

    # Exit if no wallpaper was selected
    if [ -z "$selected_wallpaper" ]; then
        exit 0
    fi

    # Set wallpaper and generate colors
    swww img "$selected_wallpaper" --transition-type any --transition-fps 60 --transition-duration .5
    wal -i "$selected_wallpaper" -n --cols16

    # Apply themes to other applications
    cat ~/.cache/wal/colors-kitty.conf > ~/.config/kitty/current-theme.conf
    pywalfox update

    # Source colors and copy the current wallpaper to a fixed location
    source ~/.cache/wal/colors.sh && cp -r "$wallpaper" ~/wallpapers/pywallpaper.jpg
}

main
