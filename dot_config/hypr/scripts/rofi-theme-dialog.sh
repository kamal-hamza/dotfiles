#!/bin/bash

THEMES_DIR="$HOME/.config/hypr/themes"
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"

# Get a list of available themes
themes=($(ls "$THEMES_DIR"))

# Present the themes in rofi
selected_theme=$(printf "%s\n" "${themes[@]}" | rofi --dmenu --prompt "Select a theme:")

# If a theme was selected, apply it
if [ -n "$selected_theme" ]; then
    # Update the hyprland.conf to source the new theme
    sed -i "s|source = ~/.config/hypr/themes/.*/.*.conf|source = ~/.config/hypr/themes/$selected_theme/$selected_theme.conf|" "$HYPRLAND_CONF"
    # Reload Hyprland
    hyprctl reload
fi
