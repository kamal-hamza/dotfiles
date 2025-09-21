#!/bin/bash

# Exit if any command fails
set -e

# Check if a theme name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME_NAME=$1
THEME_DIR="$HOME/.config/hypr/themes/$THEME_NAME"
THEME_JSON="$THEME_DIR/$THEME_NAME.json"

# Check if the theme directory and JSON file exist
if [ ! -d "$THEME_DIR" ] || [ ! -f "$THEME_JSON" ]; then
    echo "Error: Theme '$THEME_NAME' not found in $THEME_DIR"
    exit 1
fi

# --- Helper Functions ---
# Read a value from the JSON file
get_json_value() {
    jq -r "$1" "$THEME_JSON"
}

# --- Theme Application Functions ---

apply_wallpaper() {
    local wall_path=$(get_json_value '.wallpaper')
    echo "Setting wallpaper to $wall_path"
    hyprctl hyprpaper unload all
    hyprctl hyprpaper preload "$wall_path"
    hyprctl hyprpaper wallpaper ",$wall_path"
}

apply_waybar_theme() {
    local theme=$(get_json_value '.waybarTheme')
    local theme_file="$HOME/.config/waybar/themes/$theme.css"
    if [ -f "$theme_file" ]; then
        echo "Applying Waybar theme: $theme"
        ln -sf "$theme_file" "$HOME/.config/waybar/current-theme.css"
        # Restart Waybar to apply the new theme
        pkill waybar && waybar &
    else
        echo "Warning: Waybar theme '$theme' not found."
    fi
}

apply_zed_theme() {
    local theme=$(get_json_value '.zedTheme')
    local settings_file="$HOME/.config/zed/settings.json"
    if [ -f "$settings_file" ]; then
        echo "Applying Zed theme: $theme"
        # Use jq to update the theme value in settings.json
        tmp_file=$(mktemp)
        jq --arg theme "$theme" '.theme = $theme' "$settings_file" > "$tmp_file" && mv "$tmp_file" "$settings_file"
    else
        echo "Warning: Zed settings.json not found."
    fi
}

apply_wezterm_theme() {
    local theme=$(get_json_value '.weztermTheme')
    local theme_file="$HOME/.config/wezterm/themes/$theme.lua"
    if [ -f "$theme_file" ]; then
        echo "Applying Wezterm theme: $theme"
        ln -sf "$theme_file" "$HOME/.config/wezterm/current-theme.lua"
    else
        echo "Warning: Wezterm theme '$theme' not found."
    fi
}

apply_rofi_theme() {
    local theme=$(get_json_value '.rofiTheme')
    local theme_file="$HOME/.config/rofi/themes/$theme.rasi"
    if [ -f "$theme_file" ]; then
        echo "Applying Rofi theme: $theme"
        ln -sf "$theme_file" "$HOME/.config/rofi/current-theme.rasi"
    else
        echo "Warning: Rofi theme '$theme' not found."
    fi
}

apply_nvim_theme() {
    local theme=$(get_json_value '.nvimTheme')
    local theme_config="$HOME/.config/nvim/lua/user/theme.lua"
    echo "Applying Neovim theme: $theme"
    # Overwrite the theme file with the new colorscheme
    echo "vim.cmd('colorscheme $theme')" > "$theme_config"
}

apply_firefox_theme() {
    local theme=$(get_json_value '.firefoxTheme')
    # Find the Firefox profile directory
    local ff_profile_dir=$(find "$HOME/.mozilla/firefox/" -maxdepth 1 -name "*.default-release")
    local chrome_dir="$ff_profile_dir/chrome"
    local theme_file="$chrome_dir/themes/$theme.css"

    if [ -d "$chrome_dir" ] && [ -f "$theme_file" ]; then
        echo "Applying Firefox theme: $theme"
        ln -sf "$theme_file" "$chrome_dir/current-theme.css"
    else
        echo "Warning: Firefox theme '$theme' or chrome directory not found."
    fi
}

# --- Main Execution ---

echo "--- Switching to theme: $THEME_NAME ---"
apply_wallpaper
apply_waybar_theme
apply_zed_theme
apply_wezterm_theme
apply_rofi_theme
-- apply_nvim_theme
-- apply_firefox_theme
echo "--- Theme switch complete ---"
