#!/usr/bin/env bash

# =============================================================================
# Zsh Theme Generator
# =============================================================================
# Generates Zsh terminal color configuration from central color palette
# =============================================================================

set -e

MODE="${1:-all}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_FILE="$SCRIPT_DIR/../.chezmoidata/themes/colors.sh"
OUTPUT_DIR="$HOME/.config/zsh/themes"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Source color definitions
if [[ ! -f "$COLORS_FILE" ]]; then
    echo "Error: Colors file not found: $COLORS_FILE" >&2
    exit 1
fi

generate_zsh_theme() {
    local theme_name="$1"
    local output_file="$OUTPUT_DIR/soft-focus-${theme_name}.zsh"
    
    # Load colors for this theme
    source "$COLORS_FILE"
    get_colors "$theme_name"
    
    # Generate Zsh config
    cat > "$output_file" << EOF
# =============================================================================
# Soft Focus ${theme_name^} - Zsh Terminal Colors
# =============================================================================
# Auto-generated from: colors.sh
# Do not edit directly - use theme-gen.sh to regenerate
# =============================================================================

# Terminal color definitions for zsh
# These are used for syntax highlighting and other color features

# Base colors
export SOFT_FOCUS_BG="$BG"
export SOFT_FOCUS_FG="$FG"
export SOFT_FOCUS_SELECTION="$SELECTION"
export SOFT_FOCUS_COMMENT="$COMMENT"

# UI Colors
export SOFT_FOCUS_BORDER="$BORDER"
export SOFT_FOCUS_BORDER_FOCUSED="$BORDER_FOCUSED"
export SOFT_FOCUS_MUTED="$MUTED"
export SOFT_FOCUS_ACCENT="$ACCENT"

# Syntax colors
export SOFT_FOCUS_KEYWORD="$KEYWORD"
export SOFT_FOCUS_FUNCTION="$FUNCTION"
export SOFT_FOCUS_STRING="$STRING"
export SOFT_FOCUS_NUMBER="$NUMBER"
export SOFT_FOCUS_TYPE="$TYPE"
export SOFT_FOCUS_OPERATOR="$OPERATOR"
export SOFT_FOCUS_VARIABLE="$VARIABLE"

# ANSI colors
export SOFT_FOCUS_BLACK="$ANSI_BLACK"
export SOFT_FOCUS_RED="$ANSI_RED"
export SOFT_FOCUS_GREEN="$ANSI_GREEN"
export SOFT_FOCUS_YELLOW="$ANSI_YELLOW"
export SOFT_FOCUS_BLUE="$ANSI_BLUE"
export SOFT_FOCUS_MAGENTA="$ANSI_MAGENTA"
export SOFT_FOCUS_CYAN="$ANSI_CYAN"
export SOFT_FOCUS_WHITE="$ANSI_WHITE"

# Bright ANSI colors
export SOFT_FOCUS_BRIGHT_BLACK="$ANSI_BRIGHT_BLACK"
export SOFT_FOCUS_BRIGHT_RED="$ANSI_BRIGHT_RED"
export SOFT_FOCUS_BRIGHT_GREEN="$ANSI_BRIGHT_GREEN"
export SOFT_FOCUS_BRIGHT_YELLOW="$ANSI_BRIGHT_YELLOW"
export SOFT_FOCUS_BRIGHT_BLUE="$ANSI_BRIGHT_BLUE"
export SOFT_FOCUS_BRIGHT_MAGENTA="$ANSI_BRIGHT_MAGENTA"
export SOFT_FOCUS_BRIGHT_CYAN="$ANSI_BRIGHT_CYAN"
export SOFT_FOCUS_BRIGHT_WHITE="$ANSI_BRIGHT_WHITE"

# Git/VCS colors
export SOFT_FOCUS_GIT_ADDED="$GIT_ADDED"
export SOFT_FOCUS_GIT_MODIFIED="$GIT_MODIFIED"
export SOFT_FOCUS_GIT_DELETED="$GIT_DELETED"
export SOFT_FOCUS_GIT_RENAMED="$GIT_RENAMED"
export SOFT_FOCUS_GIT_CONFLICT="$GIT_CONFLICT"

# Status colors
export SOFT_FOCUS_ERROR="$ERROR"
export SOFT_FOCUS_WARNING="$WARNING"
export SOFT_FOCUS_INFO="$INFO"
export SOFT_FOCUS_SUCCESS="$SUCCESS"

# LS_COLORS configuration for colored ls output
export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=1;34:cd=1;34:su=1;31:sg=1;31:tw=1;34:ow=1;34"

# Zsh syntax highlighting colors (if zsh-syntax-highlighting is installed)
if [[ -n "\$ZSH_HIGHLIGHT_STYLES" ]]; then
    typeset -gA ZSH_HIGHLIGHT_STYLES
    
    ZSH_HIGHLIGHT_STYLES[comment]='fg=$COMMENT,italic'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=$FUNCTION'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=$KEYWORD'
    ZSH_HIGHLIGHT_STYLES[function]='fg=$FUNCTION,bold'
    ZSH_HIGHLIGHT_STYLES[command]='fg=$STRING'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=$STRING,underline'
    ZSH_HIGHLIGHT_STYLES[path]='fg=$FG'
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=$MUTED'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=$ACCENT'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=$STRING'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=$STRING'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=$STRING'
    ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=$STRING'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=$NUMBER'
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=$NUMBER'
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=$NUMBER'
    ZSH_HIGHLIGHT_STYLES[assign]='fg=$VARIABLE'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=$OPERATOR'
    ZSH_HIGHLIGHT_STYLES[arg0]='fg=$STRING'
    ZSH_HIGHLIGHT_STYLES[default]='fg=$FG'
fi

# Zsh autosuggestions colors (if zsh-autosuggestions is installed)
if [[ -n "\$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" ]]; then
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=$COMMENT'
fi
EOF

    return 0
}

# Generate themes based on mode
case "$MODE" in
    dark)
        generate_zsh_theme "dark"
        ;;
    light)
        generate_zsh_theme "light"
        ;;
    all)
        generate_zsh_theme "dark"
        generate_zsh_theme "light"
        ;;
esac

exit 0