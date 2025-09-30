#!/bin/bash
TERMINAL="wezterm"

# Function to install one or more packages, prioritizing pacman
install_package_logic() {
    local pacman_packages=""
    local yay_packages=""

    # Sort packages into pacman or yay lists
    for pkg in "$@"; do
        # Check if the package exists in the official repos (sync database)
        if pacman -Ssq "$pkg" > /dev/null 2>&1; then
            pacman_packages+="$pkg "
        else
            yay_packages+="$pkg "
        fi
    done

    local full_command=""
    # Build the command string based on which lists have packages
    if [ -n "$pacman_packages" ]; then
        full_command+="echo '--- Installing with pacman (official repos)...'; sudo pacman -S --noconfirm $pacman_packages; "
    fi
    if [ -n "$yay_packages" ]; then
        full_command+="echo '--- Installing with yay (AUR)...'; yay -S $yay_packages; "
    fi

    # Execute the installation in a terminal if there are packages to install
    if [ -n "$full_command" ]; then
        $TERMINAL sh -c "$full_command echo -e \"\n--- Installation finished. Press Enter to close. ---\"; read"
    else
        echo "No valid packages found to install."
    fi
}


# Get the package name(s) from the user's input in Walker.
PACKAGE_NAMES=$@

# If no package names are provided, use Walker's dmenu mode for an interactive search.
if [ -z "$PACKAGE_NAMES" ]; then
    # This command gets all packages from repos and the AUR, then formats them
    # for display in Walker. Example: "[extra]         firefox"
    # --color=never is important to prevent weird characters in the dmenu list.
    # The list is sorted by package name for consistency.
    PACKAGE_LIST_CMD="yay -Sl --color=never | awk '{printf \"%-15s %s\\n\", \"[\" \$1 \"]\", \$2}' | sort -k2"

    # Use Walker in dmenu mode to let the user select a package.
    # The output of PACKAGE_LIST_CMD is piped into Walker.
    selected_line=$($PACKAGE_LIST_CMD | walker --dmenu --prompt 'Install Package>')

    # If the user selected a package (i.e., didn't cancel with Esc), proceed.
    if [ -n "$selected_line" ]; then
        # Extract just the package name from the selected line.
        # e.g., "[extra]         firefox" becomes "firefox"
        package_to_install=$(echo "$selected_line" | awk '{print $2}')
        install_package_logic "$package_to_install"
    else
        # The user cancelled the operation in Walker.
        echo "No package selected. Exiting."
        exit 0
    fi
else
    # If package names are provided as arguments, install them directly.
    # This allows for quick installs like "install neofetch google-chrome".
    install_package_logic "$@"
fi
