#!/bin/zsh

# Generic function to display a menu using Walker's dmenu mode.
# Takes a prompt and a newline-separated list of options.
menu() {
    local prompt="$1"
    local options="$2"
    echo -e "$options" | walker --dmenu --prompt "$prompt"
}

# --- MENU DEFINITIONS ---

# Main Menu: The first screen the user sees.
show_main_menu() {
    # Nerd Font Icons: 󰣇 (package),  (power/exit)
    local options="󰣇  Package Management\n  Exit"

    case $(menu "Main Menu" "$options") in
        *"Package Management"*)
            show_package_menu
            ;;
        *"Exit"*)
            exit 0
            ;;
    esac
}

# Package Management Sub-Menu
show_package_menu() {
    # Nerd Font Icons: 󰆖 (install), 󰆴 (uninstall),  (back arrow)
    local options="󰆖  Install Package\n󰆴  Uninstall Package\n  Back to Main Menu"

    case $(menu "Package Management" "$options") in
        *"Install Package"*)
            # This calls the `install` command we set up earlier.
            pkg-install.sh
            ;;
        *"Uninstall Package"*)
            # This calls the `uninstall` command we set up earlier.
            pkg-uninstall.sh
            ;;
        *"Back to Main Menu"*)
            show_main_menu
            ;;
        *)
            show_main_menu
            ;;
    esac
}


# --- SCRIPT ENTRYPOINT ---
# This is the first function that runs when the script is executed.
show_main_menu
