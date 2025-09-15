#!/bin/bash
# -----------------------------------------------------------------------------
# Dynamic Wallpaper Script for Wayland (Hyprland) with pywal & multi-monitor support
# -----------------------------------------------------------------------------

wallpaper_dir="$HOME/.config/wallpapers"
blurred_dir="$wallpaper_dir/blurred"
current_wp_file="$wallpaper_dir/current_wallpaper.txt"
blur="50x30"

# Ensure directories exist
mkdir -p "$blurred_dir"
[ ! -f "$current_wp_file" ] && echo "$wallpaper_dir/default.jpg" > "$current_wp_file"

# -----------------------------------------------------------------------------
# Detect all connected monitors
# -----------------------------------------------------------------------------
mapfile -t monitors < <(wlr-randr | grep -v "off")

# Default to first monitor for rofi menu
first_monitor_info="${monitors[0]}"
monitor_name=$(echo "$first_monitor_info" | awk '{print $1}')

# -----------------------------------------------------------------------------
# Wallpaper selection via rofi-wayland
# -----------------------------------------------------------------------------
selected_filename=$(find "$wallpaper_dir" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
    | rofi -dmenu -p "Select Wallpaper" -monitor "$monitor_name")

[ -z "$selected_filename" ] && exit 0
wallpaper="$wallpaper_dir/$selected_filename"

# -----------------------------------------------------------------------------
# Generate pywal colors
# -----------------------------------------------------------------------------
wal -q -i -g "$wallpaper" -o "$HOME/.config/scripts/post-pywal.sh"
source "$HOME/.cache/wal/colors.sh"

# Reload Waybar
~/.config/waybar/launch.sh

# Update Zed theme
cp ~/.cache/wal/zed-pywal.json ~/.config/zed/themes/zed-pywal.json

# -----------------------------------------------------------------------------
# Set wallpaper and blurred version on all monitors
# -----------------------------------------------------------------------------
for monitor_info in "${monitors[@]}"; do
    mon_name=$(echo "$monitor_info" | awk '{print $1}')
    res=$(echo "$monitor_info" | awk '{print $2}' | cut -d'+' -f1)
    width=$(echo "$res" | cut -d'x' -f1)
    height=$(echo "$res" | cut -d'x' -f2)

    # Set wallpaper with swww for this monitor
    swww img "$wallpaper" --output "$mon_name" --transition-type grow --transition-pos top-right

    # Create blurred wallpaper for lockscreen
    blurred_wp="$blurred_dir/${mon_name}_$selected_filename"
    magick "$wallpaper" -resize "${width}x${height}!" "$blurred_wp"
    [ "$blur" != "0x0" ] && magick "$blurred_wp" -blur "$blur" "$blurred_wp"
done

# -----------------------------------------------------------------------------
# Update current wallpaper file
# -----------------------------------------------------------------------------
echo "$wallpaper" > "$current_wp_file"

echo ":: Wallpaper set successfully on all connected monitors"
