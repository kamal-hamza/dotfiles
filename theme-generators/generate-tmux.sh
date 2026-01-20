#!/usr/bin/env bash

# =============================================================================
# Tmux Theme Generator
# =============================================================================
# Generates tmux theme configuration from central color palette
# =============================================================================

set -e

MODE="${1:-all}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_FILE="$SCRIPT_DIR/../.chezmoidata/themes/colors.sh"
OUTPUT_DIR="$HOME/.config/tmux/themes"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Source color definitions
if [[ ! -f "$COLORS_FILE" ]]; then
    echo "Error: Colors file not found: $COLORS_FILE" >&2
    exit 1
fi

generate_tmux_theme() {
    local theme_name="$1"
    local output_file="$OUTPUT_DIR/soft-focus-${theme_name}.conf"
    
    # Load colors for this theme
    source "$COLORS_FILE"
    get_colors "$theme_name"
    
    # Generate tmux config
    {
        echo "# ============================================================================="
        echo "# Soft Focus ${theme_name^} - Tmux Theme"
        echo "# ============================================================================="
        echo "# Auto-generated from: colors.sh"
        echo "# Do not edit directly - use theme-gen.sh to regenerate"
        echo "# ============================================================================="
        echo ""
        echo "# Status bar colors"
        echo "set -g status-style \"bg=$BG,fg=$FG\""
        echo "set -g message-style \"bg=$BG,fg=$ACCENT,bold\""
        echo "set -g message-command-style \"bg=$BG,fg=$ACCENT\""
        echo ""
        echo "# Pane borders"
        echo "set -g pane-border-style \"fg=$BORDER\""
        echo "set -g pane-active-border-style \"fg=$BORDER_FOCUSED\""
        echo ""
        echo "# Window status colors"
        echo "set -g window-status-style \"fg=$MUTED,bg=$BG\""
        echo "set -g window-status-current-style \"fg=$BG,bg=$ACCENT,bold\""
        echo "set -g window-status-activity-style \"fg=$ERROR,bg=$BG\""
        echo "set -g window-status-bell-style \"fg=$ERROR,bg=$BG,bold\""
        echo "set -g window-status-separator \"\""
        echo ""
        echo "# Mode colors (copy mode, etc)"
        echo "set -g mode-style \"bg=$SELECTION,fg=$BG\""
        echo ""
        echo "# Clock mode"
        echo "set -g clock-mode-colour \"$ANSI_BLUE\""
        echo ""
        echo "# Status bar format"
        echo "set -g status-left-style \"bg=$BG,fg=$ACCENT\""
        echo "set -g status-right-style \"bg=$BG,fg=$MUTED\""
    } > "$output_file"
    
    return 0
}

# Generate themes based on mode
case "$MODE" in
    dark)
        generate_tmux_theme "dark"
        ;;
    light)
        generate_tmux_theme "light"
        ;;
    all)
        generate_tmux_theme "dark"
        generate_tmux_theme "light"
        ;;
esac

exit 0
