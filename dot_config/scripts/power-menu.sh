#!/bin/bash

# -----------------------------------------------------
# Rofi Power Menu
# -----------------------------------------------------
# Description: A simple Rofi-based power menu for Hyprland.
# Provides options for shutdown, reboot, lock, and logout.
# Now themed with Pywal.
#
# Author: Gemini
# -----------------------------------------------------

# Define the options for the Rofi menu
options="Shutdown\nReboot\nLock\nLogout"

# Prompt the user with the Rofi menu, now using the pywal theme
selected_option=$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme ~/.cache/wal/colors-rofi-dark.rasi)

# Execute the command based on the user's selection
case "$selected_option" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Lock")
        # Assumes you have swaylock installed, a popular choice for Wayland
        swaylock
        ;;
    "Logout")
        hyprctl dispatch exit
        ;;
esac
