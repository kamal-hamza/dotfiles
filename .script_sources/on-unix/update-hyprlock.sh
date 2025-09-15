#!/bin/bash
# -----------------------------------------------------------------------------
# Generate hyprlock config dynamically using pywal colors per active monitor
# -----------------------------------------------------------------------------

blurred_dir="$HOME/.config/wallpapers/blurred"
current_wp_file="$HOME/.config/wallpapers/current_wallpaper.txt"
hyprlock_conf="$HOME/.config/hypr/hyprlock.conf"

# Get the monitor under the mouse
active_monitor=$(wlr-randr | awk '/ connected/ {print $1}' | head -n1)
# If you want to detect based on mouse position instead:
# mouse_monitor=$(swaymsg -t get_inputs | jq -r '.[] | select(.type=="pointer") | .x, .y')

# Use the blurred wallpaper for that monitor
current_wallpaper=$(basename "$(cat "$current_wp_file")")
background="$blurred_dir/${active_monitor}_$current_wallpaper"

# Extract pywal colors
source "$HOME/.cache/wal/colors.sh"

# Generate hyprlock config
cat > "$hyprlock_conf" <<EOF
# Minimalist hyprlock config with pywal colors
background="$background"
blur=true
blur_radius=10
blur_passes=3
indicator=false
verif_text=" "
wrong_text=" "
caps_text="CAPS LOCK"
greeter_color=0x${color0:1}      # pywal color0 as overlay
greeter_text_color=0x${color7:1} # pywal color7 as text
EOF

echo ":: hyprlock config updated dynamically for monitor: $active_monitor"
