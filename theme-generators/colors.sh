#!/usr/bin/env bash
# =============================================================================
# Soft Focus Color Palette - Central Definition
# =============================================================================
# This file defines all colors for both dark and light themes.
# Edit these colors to change the theme across all applications.
# After editing, run: theme-gen.sh all && chezmoi apply
# =============================================================================

# Function to get colors for a specific theme
get_colors() {
    local theme="$1"
    
    if [[ "$theme" == "dark" ]]; then
        # =====================================================================
        # DARK THEME COLORS
        # =====================================================================
        
        # Base colors
        export BG="#050505"
        export FG="#f5f5f5"
        export SELECTION="#448cbb"
        export COMMENT="#888888"
        
        # UI Colors
        export BORDER="#333333"
        export BORDER_FOCUSED="#448cbb"
        export MUTED="#bbbbbb"
        export ACCENT="#67b7f5"
        
        # Syntax highlighting
        export KEYWORD="#ff4c6a"      # Keywords (if, for, function)
        export FUNCTION="#67b7f5"     # Function names
        export STRING="#99cc99"       # Strings
        export NUMBER="#f0d08a"       # Numbers and constants
        export TYPE="#4da6ff"         # Types and classes
        export OPERATOR="#bbbbbb"     # Operators
        export VARIABLE="#f5f5f5"     # Variables
        
        # Terminal ANSI colors
        export ANSI_BLACK="#111111"
        export ANSI_RED="#C42847"
        export ANSI_GREEN="#77aa77"
        export ANSI_YELLOW="#D4B87B"
        export ANSI_BLUE="#448cbb"
        export ANSI_MAGENTA="#B88E8D"
        export ANSI_CYAN="#67b7f5"
        export ANSI_WHITE="#f5f5f5"
        
        # Bright ANSI colors
        export ANSI_BRIGHT_BLACK="#333333"
        export ANSI_BRIGHT_RED="#ff4c6a"
        export ANSI_BRIGHT_GREEN="#99cc99"
        export ANSI_BRIGHT_YELLOW="#f0d08a"
        export ANSI_BRIGHT_BLUE="#4da6ff"
        export ANSI_BRIGHT_MAGENTA="#d4a6a6"
        export ANSI_BRIGHT_CYAN="#77d5ff"
        export ANSI_BRIGHT_WHITE="#ffffff"
        
        # Git/VCS colors
        export GIT_ADDED="#77aa77"
        export GIT_MODIFIED="#D4B87B"
        export GIT_DELETED="#C42847"
        export GIT_RENAMED="#D5F2E3"
        export GIT_CONFLICT="#ff4c6a"
        
        # Status colors
        export ERROR="#ff4c6a"
        export WARNING="#D4B87B"
        export INFO="#67b7f5"
        export SUCCESS="#77aa77"
        
    else
        # =====================================================================
        # LIGHT THEME COLORS
        # =====================================================================
        
        # Base colors
        export BG="#ffffff"
        export FG="#000000"
        export SELECTION="#448cbb"
        export COMMENT="#888888"
        
        # UI Colors
        export BORDER="#d0d0d0"
        export BORDER_FOCUSED="#448cbb"
        export MUTED="#666666"
        export ACCENT="#4da6ff"
        
        # Syntax highlighting
        export KEYWORD="#C42847"      # Keywords
        export FUNCTION="#4da6ff"     # Function names
        export STRING="#558855"       # Strings
        export NUMBER="#b8943d"       # Numbers and constants
        export TYPE="#448cbb"         # Types and classes
        export OPERATOR="#666666"     # Operators
        export VARIABLE="#000000"     # Variables
        
        # Terminal ANSI colors
        export ANSI_BLACK="#000000"
        export ANSI_RED="#C42847"
        export ANSI_GREEN="#558855"
        export ANSI_YELLOW="#b8943d"
        export ANSI_BLUE="#448cbb"
        export ANSI_MAGENTA="#9a6e6d"
        export ANSI_CYAN="#4da6ff"
        export ANSI_WHITE="#f5f5f5"
        
        # Bright ANSI colors
        export ANSI_BRIGHT_BLACK="#666666"
        export ANSI_BRIGHT_RED="#ff4c6a"
        export ANSI_BRIGHT_GREEN="#77aa77"
        export ANSI_BRIGHT_YELLOW="#D4B87B"
        export ANSI_BRIGHT_BLUE="#67b7f5"
        export ANSI_BRIGHT_MAGENTA="#B88E8D"
        export ANSI_BRIGHT_CYAN="#77d5ff"
        export ANSI_BRIGHT_WHITE="#ffffff"
        
        # Git/VCS colors
        export GIT_ADDED="#558855"
        export GIT_MODIFIED="#b8943d"
        export GIT_DELETED="#C42847"
        export GIT_RENAMED="#2d5f4f"
        export GIT_CONFLICT="#ff4c6a"
        
        # Status colors
        export ERROR="#ff4c6a"
        export WARNING="#b8943d"
        export INFO="#4da6ff"
        export SUCCESS="#558855"
    fi
}

# If script is sourced with a theme argument, load those colors
if [[ -n "$1" ]]; then
    get_colors "$1"
fi
