#!/usr/bin/env bash

# =============================================================================
# WezTerm Theme Generator
# =============================================================================
# Generates WezTerm color scheme from central color palette
# =============================================================================

set -e

MODE="${1:-all}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_FILE="$SCRIPT_DIR/../.chezmoidata/themes/colors.sh"
OUTPUT_DIR="$HOME/.config/wezterm/colors"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Source color definitions
if [[ ! -f "$COLORS_FILE" ]]; then
    echo "Error: Colors file not found: $COLORS_FILE" >&2
    exit 1
fi

generate_wezterm_theme() {
    local theme_name="$1"
    local output_file="$OUTPUT_DIR/soft-focus-${theme_name}.toml"
    
    # Load colors for this theme
    source "$COLORS_FILE"
    get_colors "$theme_name"
    
    # Generate WezTerm config in TOML format
    cat > "$output_file" << EOF
# =============================================================================
# Soft Focus ${theme_name^} - WezTerm Color Scheme
# =============================================================================
# Auto-generated from: colors.sh
# Do not edit directly - use theme-gen.sh to regenerate
# =============================================================================

[colors]
foreground = "$FG"
background = "$BG"

cursor_bg = "$ACCENT"
cursor_fg = "$BG"
cursor_border = "$ACCENT"

selection_fg = "$BG"
selection_bg = "$SELECTION"

scrollbar_thumb = "$MUTED"
split = "$BORDER"

ansi = [
    "$ANSI_BLACK",
    "$ANSI_RED",
    "$ANSI_GREEN",
    "$ANSI_YELLOW",
    "$ANSI_BLUE",
    "$ANSI_MAGENTA",
    "$ANSI_CYAN",
    "$ANSI_WHITE",
]

brights = [
    "$ANSI_BRIGHT_BLACK",
    "$ANSI_BRIGHT_RED",
    "$ANSI_BRIGHT_GREEN",
    "$ANSI_BRIGHT_YELLOW",
    "$ANSI_BRIGHT_BLUE",
    "$ANSI_BRIGHT_MAGENTA",
    "$ANSI_BRIGHT_CYAN",
    "$ANSI_BRIGHT_WHITE",
]

[colors.indexed]

[colors.tab_bar]
background = "$BG"
active_tab.bg_color = "$ACCENT"
active_tab.fg_color = "$BG"
inactive_tab.bg_color = "$BG"
inactive_tab.fg_color = "$MUTED"
inactive_tab_hover.bg_color = "$BORDER"
inactive_tab_hover.fg_color = "$FG"
new_tab.bg_color = "$BG"
new_tab.fg_color = "$MUTED"
new_tab_hover.bg_color = "$BORDER"
new_tab_hover.fg_color = "$FG"

[metadata]
name = "Soft Focus ${theme_name^}"
author = "Hamza Kamal"
EOF

    return 0
}

# Generate themes based on mode
case "$MODE" in
    dark)
        generate_wezterm_theme "dark"
        ;;
    light)
        generate_wezterm_theme "light"
        ;;
    all)
        generate_wezterm_theme "dark"
        generate_wezterm_theme "light"
        ;;
esac

exit 0