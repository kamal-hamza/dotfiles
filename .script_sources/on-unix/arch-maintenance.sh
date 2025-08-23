#!/bin/bash

# -----------------------------------------------------
# Arch Linux Maintenance Script
# -----------------------------------------------------
# Description: This script automates common maintenance tasks for an
# Arch Linux system, including updating packages, cleaning the cache,
# and removing orphan packages. It's designed to be run on a schedule.
#
# Dependencies: pacman-contrib (for paccache), yay (or another AUR helper)
# -----------------------------------------------------

# --- Configuration ---
# Set your AUR helper command here.
AUR_HELPER="yay"

# --- Script Logic ---
# Send a notification that the maintenance has started.
notify-send "System Maintenance" "Starting automatic updates and cleanup..."

# Update official repository packages.
echo ":: Updating official packages..."
sudo pacman -Syu --noconfirm

# Update AUR packages using the specified helper.
if command -v $AUR_HELPER &> /dev/null; then
    echo ":: Updating AUR packages with $AUR_HELPER..."
    $AUR_HELPER -Sua --noconfirm
else
    echo ":: AUR helper ($AUR_HELPER) not found. Skipping AUR updates."
fi

# Clean the package cache to remove old package versions.
# `paccache -r` removes all cached versions except for the 3 most recent.
echo ":: Cleaning package cache..."
sudo paccache -r

# Remove orphan packages (dependencies that are no longer required).
echo ":: Checking for and removing orphan packages..."
orphans=$(pacman -Qtdq)
if [ -n "$orphans" ]; then
    sudo pacman -Rns --noconfirm $orphans
    echo ":: Removed orphan packages: $orphans"
else
    echo ":: No orphan packages found."
fi

# Send a final notification that the maintenance is complete.
notify-send "System Maintenance" "Updates and cleanup finished successfully."

echo ":: System maintenance complete."
