#!/bin/bash
#
# Script to apply pywal theme to various applications.
# Includes a fallback to a default wallpaper if no theme is currently set.
#
# Usage: pywal-theme.sh

# --- Pywal Fallback Logic ---
# Check if a wal theme has been set by looking for the wallpaper file path cache.
if [ ! -f "$HOME/.cache/wal/wal" ]; then
    echo "No pywal theme found. Applying default wallpaper."

    # Define the path to the default wallpaper.
    DEFAULT_WALLPAPER="$HOME/.config/wallpapers/default.jpg"

    # Check if the default wallpaper actually exists before trying to apply it.
    if [ -f "$DEFAULT_WALLPAPER" ]; then
        # Run wal on the default wallpaper.
        # -s: Skip setting the wallpaper in TTYs.
        # -n: Skip running the post-execution script (this script), to prevent a loop.
        wal -i "$DEFAULT_WALLPAPER" -s -n
    else
        echo "Error: Default wallpaper not found at $DEFAULT_WALLPAPER."
        echo "Cannot set a theme. Please place a 'default.jpg' in ~/.config/wallpapers/"
        # Exit to prevent errors from the rest of the script.
        exit 1
    fi
fi

# --- Theme Application ---

# Set variables for configuration file paths.
pywal_dir="$HOME/.cache/wal"
rofi_config="$HOME/.config/rofi/config.rasi"
hypr_config_dir="$HOME/.config/hypr"
waybar_config_dir="$HOME/.config/waybar"
mako_config="$HOME/.config/mako/config"
foot_config="$HOME/.config/foot/foot.ini"
kitty_config="$HOME/.config/kitty/kitty.conf"
cava_config="$HOME/.config/cava/config"

# Reload Hyprland to apply colors.
hyprctl reload

# Apply pywal theme to Rofi.
sed -i -e "s/theme:.*/theme: \"$pywal_dir\/colors-rofi-dark.rasi\";/" "$rofi_config"

# Apply pywal theme to Waybar.
cp "$pywal_dir/colors-waybar.css" "$waybar_config_dir/colors.css"

# Apply pywal theme to Mako.
cp "$pywal_dir/colors-mako" "$mako_config"

# Apply pywal theme to Foot.
cp "$pywal_dir/colors-foot.ini" "$foot_config"

# Apply pywal theme to Kitty.
cp "$pywal_dir/colors-kitty.conf" "$kitty_config"

# Apply pywal theme to Cava.
cp "$pywal_dir/colors-cava" "$cava_config"

# Restart services to apply changes.
pkill waybar && waybar &
makoctl reload

echo "Pywal theme applied successfully!"
