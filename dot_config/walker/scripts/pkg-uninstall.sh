#!/bin/bash

TERMINAL="wezterm"

# Get a list of packages installed from official repositories.
# `pacman -Qeq` lists explicitly installed native packages.
pacman_list=$(pacman -Qeq | awk '{printf "%-15s %s\\n", "[pacman]", $1}')

# Get a list of packages installed from the AUR.
# `pacman -Qmq` lists explicitly installed foreign packages (i.e., AUR).
aur_list=$(pacman -Qmq | awk '{printf "%-15s %s\\n", "[aur]", $1}')

# Combine the two lists and sort them alphabetically by package name for easy searching.
combined_list=$(echo -e "$pacman_list\n$aur_list" | sort -k2)

# Use Walker in dmenu mode, piping the combined list into it for selection.
selected_line=$(echo -e "$combined_list" | walker --dmenu --prompt 'Uninstall Package>')

# If the user selected a package (i.e., didn't cancel with Esc), proceed.
if [ -n "$selected_line" ]; then
    # Extract the source ([pacman] or [aur]) and the package name from the selected line.
    source=$(echo "$selected_line" | awk '{print $1}')
    package_to_uninstall=$(echo "$selected_line" | awk '{print $2}')

    # Determine the correct uninstall command based on the package's source.
    # We use "-Rns" to recursively remove the package, its dependencies that aren't
    # needed by other packages, and its system-wide configuration files.
    if [[ "$source" == "[pacman]" ]]; then
        uninstall_command="sudo pacman -Rns $package_to_uninstall"
        echo "Preparing to uninstall $package_to_uninstall with pacman..."
    else
        uninstall_command="yay -Rns $package_to_uninstall"
        echo "Preparing to uninstall $package_to_uninstall with yay..."
    fi

    # Execute the final uninstall command in a new terminal window. This is necessary
    # to handle confirmation prompts and see the uninstallation progress.
    $TERMINAL sh -c "$uninstall_command; echo -e \"\n--- Uninstallation finished. Press Enter to close. ---\"; read"
else
    # The user cancelled the operation in Walker.
    echo "No package selected. Exiting."
    exit 0
fi
