#!/usr/bin/env python3
"""
Soft Focus Theme Generator
Generates theme files for all applications from central color definitions
"""

import os
import sys
import json
from pathlib import Path

# Color definitions
COLORS = {
    "dark": {
        # Base
        "bg": "#050505",
        "fg": "#f5f5f5",
        "selection": "#448cbb",
        "comment": "#888888",
        # UI
        "border": "#333333",
        "border_focused": "#448cbb",
        "muted": "#bbbbbb",
        "accent": "#67b7f5",
        # Syntax
        "keyword": "#ff4c6a",
        "function": "#67b7f5",
        "string": "#99cc99",
        "number": "#f0d08a",
        "type": "#4da6ff",
        "operator": "#bbbbbb",
        "variable": "#f5f5f5",
        # ANSI
        "ansi_black": "#111111",
        "ansi_red": "#C42847",
        "ansi_green": "#77aa77",
        "ansi_yellow": "#D4B87B",
        "ansi_blue": "#448cbb",
        "ansi_magenta": "#B88E8D",
        "ansi_cyan": "#67b7f5",
        "ansi_white": "#f5f5f5",
        # Bright ANSI
        "ansi_bright_black": "#333333",
        "ansi_bright_red": "#ff4c6a",
        "ansi_bright_green": "#99cc99",
        "ansi_bright_yellow": "#f0d08a",
        "ansi_bright_blue": "#4da6ff",
        "ansi_bright_magenta": "#d4a6a6",
        "ansi_bright_cyan": "#77d5ff",
        "ansi_bright_white": "#ffffff",
        # Git/Status
        "git_added": "#77aa77",
        "git_modified": "#D4B87B",
        "git_deleted": "#C42847",
        "git_renamed": "#D5F2E3",
        "git_conflict": "#ff4c6a",
        "error": "#ff4c6a",
        "warning": "#D4B87B",
        "info": "#67b7f5",
        "success": "#77aa77",
    },
    "light": {
        # Base
        "bg": "#ffffff",
        "fg": "#000000",
        "selection": "#448cbb",
        "comment": "#888888",
        # UI
        "border": "#d0d0d0",
        "border_focused": "#448cbb",
        "muted": "#666666",
        "accent": "#4da6ff",
        # Syntax
        "keyword": "#C42847",
        "function": "#4da6ff",
        "string": "#558855",
        "number": "#b8943d",
        "type": "#448cbb",
        "operator": "#666666",
        "variable": "#000000",
        # ANSI
        "ansi_black": "#000000",
        "ansi_red": "#C42847",
        "ansi_green": "#558855",
        "ansi_yellow": "#b8943d",
        "ansi_blue": "#448cbb",
        "ansi_magenta": "#9a6e6d",
        "ansi_cyan": "#4da6ff",
        "ansi_white": "#f5f5f5",
        # Bright ANSI
        "ansi_bright_black": "#666666",
        "ansi_bright_red": "#ff4c6a",
        "ansi_bright_green": "#77aa77",
        "ansi_bright_yellow": "#D4B87B",
        "ansi_bright_blue": "#67b7f5",
        "ansi_bright_magenta": "#B88E8D",
        "ansi_bright_cyan": "#77d5ff",
        "ansi_bright_white": "#ffffff",
        # Git/Status
        "git_added": "#558855",
        "git_modified": "#b8943d",
        "git_deleted": "#C42847",
        "git_renamed": "#2d5f4f",
        "git_conflict": "#ff4c6a",
        "error": "#ff4c6a",
        "warning": "#b8943d",
        "info": "#4da6ff",
        "success": "#558855",
    }
}

def generate_tmux(theme_name, colors):
    """Generate tmux theme"""
    output_dir = Path.home() / ".config/tmux/themes"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_file = output_dir / f"soft-focus-{theme_name}.conf"
    
    content = f"""# Soft Focus {theme_name.title()} - Tmux Theme
# Auto-generated - do not edit directly

# Status bar
set -g status-style "bg={colors['bg']},fg={colors['fg']}"
set -g message-style "bg={colors['bg']},fg={colors['accent']},bold"

# Pane borders
set -g pane-border-style "fg={colors['border']}"
set -g pane-active-border-style "fg={colors['border_focused']}"

# Window status
set -g window-status-style "fg={colors['muted']},bg={colors['bg']}"
set -g window-status-current-style "fg={colors['bg']},bg={colors['accent']},bold"

# Mode colors
set -g mode-style "bg={colors['selection']},fg={colors['bg']}"

# Clock
set -g clock-mode-colour "{colors['ansi_blue']}"
"""
    
    output_file.write_text(content)
    return True

def generate_wezterm(theme_name, colors):
    """Generate WezTerm theme"""
    output_dir = Path.home() / ".config/wezterm/colors"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_file = output_dir / f"soft-focus-{theme_name}.toml"
    
    content = f"""# Soft Focus {theme_name.title()} - WezTerm Theme
# Auto-generated - do not edit directly

[colors]
foreground = "{colors['fg']}"
background = "{colors['bg']}"

cursor_bg = "{colors['accent']}"
cursor_fg = "{colors['bg']}"
cursor_border = "{colors['accent']}"

selection_fg = "{colors['bg']}"
selection_bg = "{colors['selection']}"

scrollbar_thumb = "{colors['muted']}"
split = "{colors['border']}"

ansi = [
    "{colors['ansi_black']}",
    "{colors['ansi_red']}",
    "{colors['ansi_green']}",
    "{colors['ansi_yellow']}",
    "{colors['ansi_blue']}",
    "{colors['ansi_magenta']}",
    "{colors['ansi_cyan']}",
    "{colors['ansi_white']}",
]

brights = [
    "{colors['ansi_bright_black']}",
    "{colors['ansi_bright_red']}",
    "{colors['ansi_bright_green']}",
    "{colors['ansi_bright_yellow']}",
    "{colors['ansi_bright_blue']}",
    "{colors['ansi_bright_magenta']}",
    "{colors['ansi_bright_cyan']}",
    "{colors['ansi_bright_white']}",
]

[metadata]
name = "Soft Focus {theme_name.title()}"
author = "Hamza Kamal"
"""
    
    output_file.write_text(content)
    return True

def generate_zsh(theme_name, colors):
    """Generate Zsh theme"""
    output_dir = Path.home() / ".config/zsh/themes"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_file = output_dir / f"soft-focus-{theme_name}.zsh"
    
    content = f"""# Soft Focus {theme_name.title()} - Zsh Theme
# Auto-generated - do not edit directly

# Color exports
export SOFT_FOCUS_BG="{colors['bg']}"
export SOFT_FOCUS_FG="{colors['fg']}"
export SOFT_FOCUS_ACCENT="{colors['accent']}"
export SOFT_FOCUS_COMMENT="{colors['comment']}"

# Zsh syntax highlighting
if [[ -n "$ZSH_HIGHLIGHT_STYLES" ]]; then
    typeset -gA ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[comment]='fg={colors['comment']},italic'
    ZSH_HIGHLIGHT_STYLES[function]='fg={colors['function']},bold'
    ZSH_HIGHLIGHT_STYLES[command]='fg={colors['string']}'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg={colors['keyword']}'
    ZSH_HIGHLIGHT_STYLES[string]='fg={colors['string']}'
fi

# Autosuggestions
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg={colors['comment']}'
"""
    
    output_file.write_text(content)
    return True

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"
    
    themes = []
    if mode == "all":
        themes = ["dark", "light"]
    elif mode in ["dark", "light"]:
        themes = [mode]
    else:
        print(f"Invalid mode: {mode}")
        print("Usage: theme-gen.py [dark|light|all]")
        sys.exit(1)
    
    print("\n" + "="*60)
    print(f"  Soft Focus Theme Generator")
    print("="*60 + "\n")
    
    success = []
    failed = []
    
    for theme in themes:
        colors = COLORS[theme]
        print(f"→ Generating {theme} theme...")
        
        try:
            generate_tmux(theme, colors)
            generate_wezterm(theme, colors)
            generate_zsh(theme, colors)
            success.append(theme)
            print(f"✓ {theme} theme generated\n")
        except Exception as e:
            failed.append(theme)
            print(f"✗ {theme} theme failed: {e}\n")
    
    print("="*60)
    if success:
        print(f"✓ Successfully generated: {', '.join(success)}")
    if failed:
        print(f"✗ Failed: {', '.join(failed)}")
    print("="*60 + "\n")
    
    return 0 if not failed else 1

if __name__ == "__main__":
    sys.exit(main())
