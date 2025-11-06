#!/usr/bin/env python3
"""
Extended Theme Generator for Soft Focus Dotfiles
Generates application-specific theme files from central color palette files.

Cross-platform support: Windows, macOS, Linux

Author: Hamza Kamal
License: MIT
"""

import json
import os
import sys
import platform
from pathlib import Path
from typing import Dict, Any, Optional
import argparse


class ThemeGenerator:
    """Generates application-specific theme files from color palettes."""

    def __init__(self, chezmoi_root: Path):
        self.chezmoi_root = chezmoi_root
        self.colors_dir = chezmoi_root / ".chezmoidata" / "colors"
        self.themes_dir = chezmoi_root / "dot_config"

    def load_palette(self, theme_name: str) -> Dict[str, Any]:
        """Load color palette from JSON or YAML file."""
        # Try JSON first
        palette_file = self.colors_dir / f"{theme_name}.json"
        if palette_file.exists():
            with open(palette_file, "r") as f:
                return json.load(f)

        # Fall back to YAML if available
        palette_file = self.colors_dir / f"{theme_name}.yaml"
        if palette_file.exists():
            try:
                import yaml
                with open(palette_file, "r") as f:
                    return yaml.safe_load(f)
            except ImportError:
                raise ImportError(
                    f"YAML file found but PyYAML not installed. "
                    f"Install with: pip3 install --user PyYAML --break-system-packages\n"
                    f"Or convert {palette_file} to JSON format."
                )

        raise FileNotFoundError(
            f"Palette file not found: {theme_name}.json or {theme_name}.yaml"
        )

    def generate_kitty_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Kitty terminal theme."""
        p = palette["palette"]
        t = p["terminal"]
        appearance = palette["appearance"]
        overrides = palette.get("overrides", {}).get("kitty", {})

        content = f"""# Soft Focus {appearance.title()} Theme for Kitty
# Auto-generated from central color palette

foreground              {p["foreground"]}
background              {p["background"]}
selection_foreground    {p.get("cursor_text", p["background"])}
selection_background    {p["primary"]}

cursor                  {p.get("cursor", p["foreground"])}
cursor_text_color       {p.get("cursor_text", p["background"])}

url_color               {p["secondary"]}

active_border_color     {p["border_active"]}
inactive_border_color   {p["border"]}
bell_border_color       {p["warning"]}

wayland_titlebar_color  {p["background"]}
macos_titlebar_color    {p["background"]}

active_tab_foreground   {overrides.get("active_tab_fg", p["foreground"])}
active_tab_background   {overrides.get("active_tab_bg", p["background_elevated"])}
inactive_tab_foreground {overrides.get("inactive_tab_fg", p["foreground_alt"])}
inactive_tab_background {overrides.get("inactive_tab_bg", p["background"])}
tab_bar_background      {overrides.get("tab_bar_background", p["background"])}

mark1_foreground        {p["background"]}
mark1_background        {p["secondary"]}
mark2_foreground        {p["background"]}
mark2_background        {p["error"]}
mark3_foreground        {p["background"]}
mark3_background        {p["warning"]}

color0  {t["black"]}
color8  {t["bright_black"]}
color1  {t["red"]}
color9  {t["bright_red"]}
color2  {t["green"]}
color10 {t["bright_green"]}
color3  {t["yellow"]}
color11 {t["bright_yellow"]}
color4  {t["blue"]}
color12 {t["bright_blue"]}
color5  {t["magenta"]}
color13 {t["bright_magenta"]}
color6  {t["cyan"]}
color14 {t["bright_cyan"]}
color7  {t["white"]}
color15 {t["bright_white"]}
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated Kitty theme: {output_path}")

    def generate_wezterm_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate WezTerm theme (TOML format)."""
        p = palette["palette"]
        t = p["terminal"]
        appearance = palette["appearance"]
        overrides = palette.get("overrides", {}).get("wezterm", {})

        # Format arrays for TOML
        ansi_colors = [t["black"], t["red"], t["green"], t["yellow"], 
                      t["blue"], t["magenta"], t["cyan"], t["white"]]
        brights_colors = [t["bright_black"], t["bright_red"], t["bright_green"], 
                         t["bright_yellow"], t["bright_blue"], t["bright_magenta"], 
                         t["bright_cyan"], t["bright_white"]]

        content = f"""# Soft Focus {appearance.title()} Theme for WezTerm
# Auto-generated from central color palette

[colors]
foreground = "{p["foreground"]}"
background = "{p["background"]}"

cursor_bg = "{p.get('cursor', p['foreground'])}"
cursor_fg = "{p.get('cursor_text', p['background'])}"
cursor_border = "{p.get('cursor', p['foreground'])}"

selection_fg = "{p.get('cursor_text', p['background'])}"
selection_bg = "{p['primary']}"

scrollbar_thumb = "{p['foreground_dim']}"
split = "{p['border']}"

ansi = {ansi_colors}
brights = {brights_colors}

[colors.tab_bar]
background = "{overrides.get('tab_bar_background', p['background'])}"

[colors.tab_bar.active_tab]
bg_color = "{overrides.get('active_tab_bg', p['background_elevated'])}"
fg_color = "{overrides.get('active_tab_fg', p['foreground'])}"
intensity = "Bold"

[colors.tab_bar.inactive_tab]
bg_color = "{overrides.get('inactive_tab_bg', p['background'])}"
fg_color = "{overrides.get('inactive_tab_fg', p['foreground_alt'])}"

[colors.tab_bar.inactive_tab_hover]
bg_color = "{overrides.get('new_tab_hover_bg', p['primary'])}"
fg_color = "{overrides.get('new_tab_hover_fg', p['background'])}"
italic = true

[colors.tab_bar.new_tab]
bg_color = "{p['background']}"
fg_color = "{p['foreground_alt']}"

[colors.tab_bar.new_tab_hover]
bg_color = "{overrides.get('new_tab_hover_bg', p['primary'])}"
fg_color = "{overrides.get('new_tab_hover_fg', p['background'])}"
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated WezTerm theme: {output_path}")

    def generate_tmux_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate tmux theme."""
        p = palette["palette"]
        appearance = palette["appearance"]
        overrides = palette.get("overrides", {}).get("tmux", {})

        content = f"""# Soft Focus {appearance.title()} Theme for tmux
# Auto-generated from central color palette

set -g status-style "bg={overrides.get("status_bg", p["background"])},fg={overrides.get("status_fg", p["foreground"])}"
set -g status-left-style "bg={overrides.get("status_bg", p["background"])},fg={p["primary"]},bold"
set -g status-right-style "bg={overrides.get("status_bg", p["background"])},fg={p["foreground_alt"]}"

set -g window-status-style "bg={overrides.get("status_bg", p["background"])},fg={p["foreground_alt"]}"
set -g window-status-current-style "bg={overrides.get("window_status_current_bg", p["background_elevated"])},fg={overrides.get("window_status_current_fg", p["primary"])},bold"
set -g window-status-activity-style "bg={overrides.get("status_bg", p["background"])},fg={p["warning"]}"
set -g window-status-bell-style "bg={overrides.get("status_bg", p["background"])},fg={p["error"]}"

set -g pane-border-style "fg={overrides.get("pane_border", p["border"])}"
set -g pane-active-border-style "fg={overrides.get("pane_active_border", p["border_active"])}"

set -g message-style "bg={overrides.get("message_bg", p["background_elevated"])},fg={overrides.get("message_fg", p["primary"])},bold"
set -g message-command-style "bg={overrides.get("message_bg", p["background_elevated"])},fg={overrides.get("message_fg", p["primary"])}"

set -g mode-style "bg={p["primary"]},fg={p["background"]}"

set -g clock-mode-colour "{p["primary"]}"
set -g clock-mode-style 24
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated tmux theme: {output_path}")

    def generate_yazi_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Yazi file manager theme."""
        p = palette["palette"]
        appearance = palette["appearance"]
        overrides = palette.get("overrides", {}).get("yazi", {})

        content = f"""# Soft Focus {appearance.title()} Theme for Yazi
# Auto-generated from central color palette

[manager]
cwd = {{ fg = "{p["primary"]}", bold = true }}
hovered = {{ fg = "{p["foreground"]}", bg = "{overrides.get("hovered_bg", p["background_elevated"])}" }}
preview_hovered = {{ underline = true }}
find_keyword = {{ fg = "{p["warning"]}", bold = true }}
find_position = {{ fg = "{p["info"]}", bg = "reset", bold = true }}
marker_selected = {{ fg = "{p["success"]}", bg = "{overrides.get("selected_bg", p["primary"])}" }}
marker_copied = {{ fg = "{p["warning"]}", bg = "{p["warning"]}" }}
marker_cut = {{ fg = "{p["error"]}", bg = "{p["error"]}" }}
tab_active = {{ fg = "{p["foreground"]}", bg = "{p["background_elevated"]}", bold = true }}
tab_inactive = {{ fg = "{p["foreground_alt"]}", bg = "{p["background"]}" }}
tab_width = 1
border_symbol = "│"
border_style = {{ fg = "{overrides.get("border", p["border"])}" }}
syntect_theme = ""

[status]
separator_open = ""
separator_close = ""
separator_style = {{ fg = "{p["border"]}", bg = "{p["border"]}" }}
mode_normal = {{ fg = "{p["background"]}", bg = "{p["primary"]}", bold = true }}
mode_select = {{ fg = "{p["background"]}", bg = "{p["success"]}", bold = true }}
mode_unset = {{ fg = "{p["background"]}", bg = "{p["warning"]}", bold = true }}
progress_label = {{ fg = "{p["foreground"]}", bold = true }}
progress_normal = {{ fg = "{p["primary"]}", bg = "{p["background_alt"]}" }}
progress_error = {{ fg = "{p["error"]}", bg = "{p["background_alt"]}" }}
permissions_t = {{ fg = "{p["success"]}" }}
permissions_r = {{ fg = "{p["warning"]}" }}
permissions_w = {{ fg = "{p["error"]}" }}
permissions_x = {{ fg = "{p["info"]}" }}
permissions_s = {{ fg = "{p["foreground_dim"]}" }}

[input]
border = {{ fg = "{overrides.get("border_active", p["border_active"])}" }}
title = {{ fg = "{p["primary"]}" }}
value = {{ fg = "{p["foreground"]}" }}
selected = {{ bg = "{p["primary"]}", fg = "{p["background"]}" }}

[select]
border = {{ fg = "{overrides.get("border_active", p["border_active"])}" }}
active = {{ fg = "{p["primary"]}", bold = true }}
inactive = {{ fg = "{p["foreground_alt"]}" }}

[tasks]
border = {{ fg = "{overrides.get("border_active", p["border_active"])}" }}
title = {{ fg = "{p["primary"]}" }}
hovered = {{ fg = "{p["foreground"]}", bg = "{p["background_elevated"]}" }}

[which]
cols = 3
mask = {{ bg = "{p["background"]}" }}
cand = {{ fg = "{p["foreground"]}" }}
rest = {{ fg = "{p["foreground_dim"]}" }}
desc = {{ fg = "{p["info"]}" }}
separator = "  "
separator_style = {{ fg = "{p["border"]}" }}

[help]
on = {{ fg = "{p["success"]}" }}
run = {{ fg = "{p["info"]}" }}
desc = {{ fg = "{p["foreground_alt"]}" }}
hovered = {{ bg = "{p["background_elevated"]}" }}
footer = {{ fg = "{p["foreground"]}", bg = "{p["background"]}" }}

[filetype]
rules = [
  {{ name = "*/", fg = "{p["primary"]}", bold = true }},
  {{ name = "*", fg = "{p["foreground"]}" }},
]
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated Yazi theme: {output_path}")

    def generate_btop_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate btop system monitor theme."""
        p = palette["palette"]
        t = p["terminal"]
        appearance = palette["appearance"]
        overrides = palette.get("overrides", {}).get("btop", {})

        def to_btop_color(hex_color: str) -> str:
            return hex_color.lstrip("#")

        content = f"""# Soft Focus {appearance.title()} Theme for btop
# Auto-generated from central color palette

theme[main_bg]="#{to_btop_color(overrides.get("main_bg", p["background"]))}"
theme[main_fg]="#{to_btop_color(overrides.get("main_fg", p["foreground"]))}"
theme[title]="#{to_btop_color(overrides.get("title", p["primary"]))}"
theme[hi_fg]="#{to_btop_color(overrides.get("selected_fg", p["primary"]))}"
theme[selected_bg]="#{to_btop_color(overrides.get("selected_bg", p["background_elevated"]))}"
theme[selected_fg]="#{to_btop_color(overrides.get("selected_fg", p["primary"]))}"
theme[inactive_fg]="#{to_btop_color(overrides.get("inactive_fg", p["foreground_dim"]))}"
theme[proc_misc]="#{to_btop_color(overrides.get("proc_misc", p["secondary"]))}"
theme[cpu_box]="#{to_btop_color(overrides.get("cpu_box", p["primary"]))}"
theme[cpu_graph_upper]="#{to_btop_color(p["primary"])}"
theme[cpu_graph_lower]="#{to_btop_color(p["secondary"])}"
theme[mem_box]="#{to_btop_color(overrides.get("mem_box", p["success"]))}"
theme[mem_graph_upper]="#{to_btop_color(p["success"])}"
theme[mem_graph_lower]="#{to_btop_color(t["green"])}"
theme[net_box]="#{to_btop_color(overrides.get("net_box", p["warning"]))}"
theme[net_graph_upper]="#{to_btop_color(p["warning"])}"
theme[net_graph_lower]="#{to_btop_color(t["yellow"])}"
theme[proc_box]="#{to_btop_color(overrides.get("proc_box", t["magenta"]))}"
theme[graph_text]="#{to_btop_color(overrides.get("graph_text", p["foreground"]))}"
theme[meter_bg]="#{to_btop_color(p["background_alt"])}"
theme[gradient_c0]="#{to_btop_color(t["blue"])}"
theme[gradient_c1]="#{to_btop_color(p["secondary"])}"
theme[gradient_c2]="#{to_btop_color(t["cyan"])}"
theme[gradient_c3]="#{to_btop_color(t["green"])}"
theme[gradient_c4]="#{to_btop_color(t["yellow"])}"
theme[gradient_c5]="#{to_btop_color(t["red"])}"
theme[div_line]="#{to_btop_color(p["border"])}"
theme[temp_start]="#{to_btop_color(t["green"])}"
theme[temp_mid]="#{to_btop_color(t["yellow"])}"
theme[temp_end]="#{to_btop_color(t["red"])}"
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated btop theme: {output_path}")

    def generate_hyprland_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Hyprland window manager colors."""
        p = palette["palette"]
        appearance = palette["appearance"]

        content = f"""# Soft Focus {appearance.title()} Theme for Hyprland
# Auto-generated from central color palette

$background = rgb({p["background"].lstrip("#")})
$foreground = rgb({p["foreground"].lstrip("#")})
$primary = rgb({p["primary"].lstrip("#")})
$secondary = rgb({p["secondary"].lstrip("#")})
$border = rgb({p["border"].lstrip("#")})
$border_active = rgb({p["border_active"].lstrip("#")})
$background_elevated = rgb({p["background_elevated"].lstrip("#")})

general {{
    col.active_border = $border_active $primary 45deg
    col.inactive_border = $border
}}

decoration {{
    col.shadow = rgba(00000099)
}}

group {{
    col.border_active = $border_active
    col.border_inactive = $border
    
    groupbar {{
        col.active = $primary
        col.inactive = $border
    }}
}}
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated Hyprland theme: {output_path}")

    def generate_waybar_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Waybar CSS theme."""
        p = palette["palette"]
        appearance = palette["appearance"]

        content = f"""/* Soft Focus {appearance.title()} Theme for Waybar */
/* Auto-generated from central color palette */

* {{
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 14px;
    min-height: 0;
}}

window#waybar {{
    background: {p["background"]};
    color: {p["foreground"]};
}}

#workspaces button {{
    padding: 0 10px;
    color: {p["foreground_alt"]};
    background: transparent;
}}

#workspaces button.active {{
    color: {p["primary"]};
    background: {p["background_elevated"]};
}}

#workspaces button.urgent {{
    color: {p["error"]};
}}

#workspaces button:hover {{
    background: {p["background_elevated"]};
    color: {p["foreground"]};
}}

#clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #mode {{
    padding: 0 10px;
    margin: 0 5px;
}}

#clock {{
    color: {p["primary"]};
}}

#battery {{
    color: {p["success"]};
}}

#battery.charging {{
    color: {p["info"]};
}}

#battery.warning:not(.charging) {{
    color: {p["warning"]};
}}

#battery.critical:not(.charging) {{
    color: {p["error"]};
}}

#cpu {{
    color: {p["secondary"]};
}}

#memory {{
    color: {p["info"]};
}}

#network {{
    color: {p["success"]};
}}

#network.disconnected {{
    color: {p["error"]};
}}

#pulseaudio {{
    color: {p["warning"]};
}}

#pulseaudio.muted {{
    color: {p["foreground_dim"]};
}}

#tray {{
    background: transparent;
}}

#mode {{
    background: {p["primary"]};
    color: {p["background"]};
    padding: 0 15px;
}}
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated Waybar theme: {output_path}")

    def generate_rofi_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Rofi launcher theme."""
        p = palette["palette"]
        appearance = palette["appearance"]

        content = f"""/* Soft Focus {appearance.title()} Theme for Rofi */
/* Auto-generated from central color palette */

* {{
    background: {p["background"]};
    foreground: {p["foreground"]};
    background-alt: {p["background_elevated"]};
    foreground-alt: {p["foreground_alt"]};
    primary: {p["primary"]};
    secondary: {p["secondary"]};
    urgent: {p["error"]};
    active: {p["success"]};
    border: {p["border"]};
    border-active: {p["border_active"]};
    
    background-color: transparent;
    text-color: @foreground;
}}

window {{
    background-color: @background;
    border: 2px;
    border-color: @border;
    padding: 20px;
}}

mainbox {{
    background-color: transparent;
}}

inputbar {{
    background-color: @background-alt;
    text-color: @foreground;
    padding: 10px;
    margin: 0 0 10px 0;
    border: 1px;
    border-color: @border-active;
}}

prompt {{
    background-color: transparent;
    text-color: @primary;
    padding: 0 10px 0 0;
}}

entry {{
    background-color: transparent;
    text-color: @foreground;
}}

listview {{
    background-color: transparent;
    spacing: 5px;
    padding: 5px 0 0 0;
}}

element {{
    background-color: transparent;
    text-color: @foreground-alt;
    padding: 8px;
}}

element selected {{
    background-color: @background-alt;
    text-color: @primary;
    border: 1px;
    border-color: @border-active;
}}

element-text {{
    background-color: transparent;
    text-color: inherit;
}}

element-icon {{
    background-color: transparent;
    size: 1.2em;
}}

mode-switcher {{
    background-color: transparent;
    margin: 10px 0 0 0;
}}

button {{
    background-color: @background-alt;
    text-color: @foreground-alt;
    padding: 8px;
    margin: 0 5px 0 0;
}}

button selected {{
    background-color: @primary;
    text-color: @background;
}}
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated Rofi theme: {output_path}")

    def generate_vscode_settings(self, palette: Dict[str, Any], output_path: Path):
        """Generate VS Code workbench color customizations."""
        p = palette["palette"]
        t = p["terminal"]
        appearance = palette["appearance"]

        # VS Code uses # prefix for colors
        colors = {
            # Editor colors
            "editor.background": p["background"],
            "editor.foreground": p["foreground"],
            "editorLineNumber.foreground": p["foreground_dim"],
            "editorLineNumber.activeForeground": p["foreground"],
            "editorCursor.foreground": p["primary"],
            "editor.selectionBackground": p["visual"],
            "editor.inactiveSelectionBackground": p["cursor_line"],
            "editor.lineHighlightBackground": p["cursor_line"],
            "editorWhitespace.foreground": p["foreground_dim"],
            "editorIndentGuide.background": p["border"],
            "editorIndentGuide.activeBackground": p["border_active"],
            "editorRuler.foreground": p["border"],
            "editorBracketMatch.background": p["visual"],
            "editorBracketMatch.border": p["primary"],
            "editorGutter.background": p["background"],
            "editorGutter.modifiedBackground": p["warning"],
            "editorGutter.addedBackground": p["success"],
            "editorGutter.deletedBackground": p["error"],
            
            # Sidebar colors
            "sideBar.background": p["background"],
            "sideBar.foreground": p["foreground_alt"],
            "sideBar.border": p["border"],
            "sideBarTitle.foreground": p["primary"],
            "sideBarSectionHeader.background": p["background_elevated"],
            "sideBarSectionHeader.foreground": p["foreground"],
            "sideBarSectionHeader.border": p["border"],
            
            # Activity bar
            "activityBar.background": p["background"],
            "activityBar.foreground": p["primary"],
            "activityBar.inactiveForeground": p["foreground_dim"],
            "activityBar.border": p["border"],
            "activityBarBadge.background": p["primary"],
            "activityBarBadge.foreground": p["background"],
            
            # Status bar
            "statusBar.background": p["background"],
            "statusBar.foreground": p["foreground_alt"],
            "statusBar.border": p["border"],
            "statusBar.debuggingBackground": p["warning"],
            "statusBar.debuggingForeground": p["background"],
            "statusBar.noFolderBackground": p["background"],
            "statusBar.noFolderForeground": p["foreground_alt"],
            
            # Tabs
            "tab.activeBackground": p["background"],
            "tab.activeForeground": p["foreground"],
            "tab.activeBorder": p["primary"],
            "tab.inactiveBackground": p["background"],
            "tab.inactiveForeground": p["foreground_alt"],
            "tab.border": p["border"],
            "editorGroupHeader.tabsBackground": p["background"],
            "editorGroupHeader.tabsBorder": p["border"],
            
            # Title bar
            "titleBar.activeBackground": p["background"],
            "titleBar.activeForeground": p["foreground"],
            "titleBar.inactiveBackground": p["background"],
            "titleBar.inactiveForeground": p["foreground_dim"],
            "titleBar.border": p["border"],
            
            # Panel (terminal, output, etc.)
            "panel.background": p["background"],
            "panel.border": p["border"],
            "panelTitle.activeBorder": p["primary"],
            "panelTitle.activeForeground": p["foreground"],
            "panelTitle.inactiveForeground": p["foreground_alt"],
            
            # Terminal colors
            "terminal.background": p["background"],
            "terminal.foreground": p["foreground"],
            "terminal.ansiBlack": t["black"],
            "terminal.ansiRed": t["red"],
            "terminal.ansiGreen": t["green"],
            "terminal.ansiYellow": t["yellow"],
            "terminal.ansiBlue": t["blue"],
            "terminal.ansiMagenta": t["magenta"],
            "terminal.ansiCyan": t["cyan"],
            "terminal.ansiWhite": t["white"],
            "terminal.ansiBrightBlack": t["bright_black"],
            "terminal.ansiBrightRed": t["bright_red"],
            "terminal.ansiBrightGreen": t["bright_green"],
            "terminal.ansiBrightYellow": t["bright_yellow"],
            "terminal.ansiBrightBlue": t["bright_blue"],
            "terminal.ansiBrightMagenta": t["bright_magenta"],
            "terminal.ansiBrightCyan": t["bright_cyan"],
            "terminal.ansiBrightWhite": t["bright_white"],
            
            # Git decorations
            "gitDecoration.modifiedResourceForeground": p["warning"],
            "gitDecoration.deletedResourceForeground": p["error"],
            "gitDecoration.untrackedResourceForeground": p["success"],
            "gitDecoration.ignoredResourceForeground": p["foreground_dim"],
            "gitDecoration.conflictingResourceForeground": p["error"],
            
            # Buttons
            "button.background": p["primary"],
            "button.foreground": p["background"],
            "button.hoverBackground": p["secondary"],
            
            # Lists and trees
            "list.activeSelectionBackground": p["visual"],
            "list.activeSelectionForeground": p["foreground"],
            "list.inactiveSelectionBackground": p["cursor_line"],
            "list.inactiveSelectionForeground": p["foreground_alt"],
            "list.hoverBackground": p["cursor_line"],
            "list.hoverForeground": p["foreground"],
            "list.focusBackground": p["visual"],
            "list.focusForeground": p["foreground"],
            
            # Peek view
            "peekView.border": p["primary"],
            "peekViewEditor.background": p["background"],
            "peekViewEditor.matchHighlightBackground": p["search"],
            "peekViewResult.background": p["background_elevated"],
            "peekViewResult.matchHighlightBackground": p["search"],
            "peekViewResult.selectionBackground": p["visual"],
            "peekViewTitle.background": p["background_elevated"],
            
            # Notifications
            "notificationCenter.border": p["border"],
            "notificationCenterHeader.background": p["background_elevated"],
            "notifications.background": p["background_elevated"],
            "notifications.border": p["border"],
            
            # Search
            "searchEditor.findMatchBackground": p["search"],
            "search.resultsInfoForeground": p["foreground_alt"],
        }

        # Generate JSON content
        content = {
            "workbench.colorCustomizations": colors
        }

        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            json.dump(content, f, indent=4)
        print(f"✓ Generated VS Code settings: {output_path}")

    def generate_zsh_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Zsh syntax highlighting theme."""
        p = palette["palette"]
        appearance = palette["appearance"]

        content = f"""# Soft Focus {appearance.title()} Theme for Zsh Syntax Highlighting
# Auto-generated from central color palette

typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[default]=fg={p["foreground"]}
ZSH_HIGHLIGHT_STYLES[comment]=fg={p["foreground_dim"]},italic
ZSH_HIGHLIGHT_STYLES[command]=fg={p["primary"]},bold
ZSH_HIGHLIGHT_STYLES[alias]=fg={p["primary"]}
ZSH_HIGHLIGHT_STYLES[builtin]=fg={p["secondary"]}
ZSH_HIGHLIGHT_STYLES[function]=fg={p["info"]}
ZSH_HIGHLIGHT_STYLES[keyword]=fg={p["error"]}
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg={p["error"]}
ZSH_HIGHLIGHT_STYLES[string]=fg={p["success"]}
ZSH_HIGHLIGHT_STYLES[param]=fg={p["foreground"]}
ZSH_HIGHLIGHT_STYLES[command-substitution]=fg={p["info"]}
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=fg={p["info"]}
ZSH_HIGHLIGHT_STYLES[operator]=fg={p["foreground_alt"]}
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg={p["warning"]},bold
ZSH_HIGHLIGHT_STYLES[path]=fg={p["foreground"]},underline
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated Zsh theme: {output_path}")

    def generate_zed_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Zed editor theme."""
        p = palette["palette"]
        t = p["terminal"]
        appearance = palette["appearance"]
        is_dark = appearance == "dark"

        theme = {
            "$schema": "https://zed.dev/schema/themes/v0.2.0.json",
            "name": "Soft Focus",
            "author": "Hamza Kamal",
            "themes": [
                {
                    "name": f"Soft Focus {appearance.title()}",
                    "appearance": appearance,
                    "style": {
                        "accents": [
                            p.get("accent_mint", p["tertiary"]),
                            p["primary"],
                            p["secondary"]
                        ],
                        "background": p["background"],
                        "border": p["border"],
                        "border.variant": "#00000000",
                        "border.focused": p["primary"],
                        "border.selected": p["primary"],
                        "border.transparent": "transparent",
                        "border.disabled": p["foreground_dim"],
                        "elevated_surface.background": p["background"],
                        "surface.background": p["background"],
                        "element.background": p["background"],
                        "element.hover": p["background_elevated"],
                        "element.active": p["cursor_line"],
                        "element.selected": p["cursor_line"],
                        "element.disabled": p["foreground_dim"],
                        "drop_target.background": p["secondary"],
                        "ghost_element.background": p["background"],
                        "ghost_element.hover": p["background_elevated"],
                        "ghost_element.active": p["cursor_line"],
                        "ghost_element.selected": p["cursor_line"],
                        "ghost_element.disabled": p["foreground_dim"],
                        "text": p["foreground"],
                        "text.muted": p["foreground_alt"],
                        "text.placeholder": p["foreground_dim"],
                        "text.disabled": p["foreground_dim"],
                        "text.accent": p["secondary"],
                        "icon": p["foreground"],
                        "icon.muted": p["foreground_alt"],
                        "icon.disabled": p["foreground_dim"],
                        "icon.placeholder": p["foreground_dim"],
                        "icon.accent": p["secondary"],
                        "status_bar.background": p["background"],
                        "title_bar.background": p["background"],
                        "title_bar.inactive_background": p["background"],
                        "toolbar.background": p["background"],
                        "tab_bar.background": p["background"],
                        "tab.active_background": p["background"],
                        "tab.inactive_background": p["background"],
                        "search.match_background": p["search"],
                        "panel.background": p["background"],
                        "panel.focused_border": p["primary"],
                        "panel.indent_guide": p["indent_guide"],
                        "panel.indent_guide_active": p["indent_guide_active"],
                        "panel.indent_guide_hover": p["primary"],
                        "panel.overlay_background": p["background_alt"],
                        "pane.focused_border": p["primary"],
                        "pane_group.border": p["border"],
                        "scrollbar.thumb.background": p["foreground_dim"],
                        "scrollbar.thumb.hover_background": p["foreground_alt"],
                        "scrollbar.thumb.border": p["primary"],
                        "scrollbar.track.background": p["background"],
                        "scrollbar.track.border": "#00000000",
                        "editor.background": p["background"],
                        "editor.foreground": p["foreground"],
                        "editor.gutter.background": p["background"],
                        "editor.subheader.background": p["background_elevated"],
                        "editor.active_line.background": p["cursor_line"],
                        "editor.highlighted_line.background": p["background_elevated"],
                        "editor.line_number": p["foreground_dim"],
                        "editor.active_line_number": p["foreground"],
                        "editor.invisible": p["foreground_dim"],
                        "editor.wrap_guide": p["border"],
                        "editor.active_wrap_guide": p["foreground_dim"],
                        "editor.document_highlight.bracket_background": p["visual"],
                        "editor.document_highlight.read_background": p["cursor_line"],
                        "editor.document_highlight.write_background": p["visual"],
                        "editor.indent_guide": p["indent_guide"],
                        "editor.indent_guide_active": p["indent_guide_active"],
                        "terminal.background": p["background"],
                        "terminal.ansi.background": p["background"],
                        "terminal.foreground": p["foreground"],
                        "terminal.dim_foreground": p["foreground_alt"],
                        "terminal.bright_foreground": p["foreground"],
                        "terminal.ansi.black": t["black"],
                        "terminal.ansi.red": t["red"],
                        "terminal.ansi.green": t["green"],
                        "terminal.ansi.yellow": t["yellow"],
                        "terminal.ansi.blue": t["blue"],
                        "terminal.ansi.magenta": t["magenta"],
                        "terminal.ansi.cyan": t["cyan"],
                        "terminal.ansi.white": t["white"],
                        "terminal.ansi.bright_black": t["bright_black"],
                        "terminal.ansi.bright_red": t["bright_red"],
                        "terminal.ansi.bright_green": t["bright_green"],
                        "terminal.ansi.bright_yellow": t["bright_yellow"],
                        "terminal.ansi.bright_blue": t["bright_blue"],
                        "terminal.ansi.bright_magenta": t["bright_magenta"],
                        "terminal.ansi.bright_cyan": t["bright_cyan"],
                        "terminal.ansi.bright_white": t["bright_white"],
                        "terminal.ansi.dim_black": t["bright_black"],
                        "terminal.ansi.dim_red": t["red"],
                        "terminal.ansi.dim_green": t["green"],
                        "terminal.ansi.dim_yellow": t["yellow"],
                        "terminal.ansi.dim_blue": t["blue"],
                        "terminal.ansi.dim_magenta": t["magenta"],
                        "terminal.ansi.dim_cyan": t["cyan"],
                        "terminal.ansi.dim_white": t["bright_black"],
                        "link_text.hover": p["secondary"],
                        "conflict": t["bright_red"],
                        "conflict.border": t["bright_red"],
                        "conflict.background": p["diff_delete_bg"],
                        "created": t["green"],
                        "created.border": t["green"],
                        "created.background": p["diff_add_bg"],
                        "deleted": t["red"],
                        "deleted.border": t["red"],
                        "deleted.background": p["diff_delete_bg"],
                        "hidden": p["foreground_dim"],
                        "hidden.border": p["foreground_dim"],
                        "hidden.background": p["background_alt"],
                        "ignored": p["foreground_dim"],
                        "ignored.border": p["foreground_dim"],
                        "ignored.background": p["background_alt"],
                        "modified": t["yellow"],
                        "modified.border": t["yellow"],
                        "modified.background": p["diff_change_bg"],
                        "predictive": p["foreground_dim"],
                        "predictive.border": p["primary"],
                        "predictive.background": p["background_alt"],
                        "renamed": p.get("accent_mint", p["tertiary"]),
                        "renamed.border": p.get("accent_mint", p["tertiary"]),
                        "renamed.background": f"{p.get('accent_mint', p['tertiary'])}",
                        "success": t["green"],
                        "success.border": t["green"],
                        "success.background": f"{t['green']}",
                        "unreachable": t["red"],
                        "unreachable.border": t["red"],
                        "unreachable.background": f"{t['red']}",
                        "players": [
                            {
                                "cursor": p["foreground"],
                                "selection": f"{p['primary']}",
                                "background": p["background"]
                            }
                        ],
                        "version_control.added": t["green"],
                        "version_control.added_background": f"{t['green']}26",
                        "version_control.deleted": t["red"],
                        "version_control.deleted_background": f"{t['red']}26",
                        "version_control.modified": t["yellow"],
                        "version_control.modified_background": f"{t['yellow']}26",
                        "version_control.renamed": p.get("accent_mint", p["tertiary"]),
                        "version_control.conflict": t["bright_red"],
                        "version_control.conflict_background": f"{t['bright_red']}26",
                        "version_control.ignored": p["foreground_dim"],
                        "error": t["bright_red"],
                        "error.background": p["background"],
                        "error.border": t["bright_red"],
                        "warning": t["yellow"],
                        "warning.background": p["background"],
                        "warning.border": t["yellow"],
                        "hint": p["secondary"],
                        "hint.background": p["background"],
                        "hint.border": p["secondary"],
                        "info": p["info"],
                        "info.background": p["background"],
                        "info.border": p["info"],
                        "syntax": {
                            "comment": {
                                "color": p["foreground_dim"],
                                "font_style": "italic",
                                "font_weight": None
                            },
                            "keyword": {
                                "color": t["bright_red"],
                                "font_style": None,
                                "font_weight": None
                            },
                            "function": {
                                "color": p["secondary"],
                                "font_style": None,
                                "font_weight": None
                            },
                            "string": {
                                "color": t["green"],
                                "font_style": None,
                                "font_weight": None
                            },
                            "variable": {
                                "color": p["foreground"],
                                "font_style": None,
                                "font_weight": None
                            },
                            "type": {
                                "color": t["yellow"],
                                "font_style": None,
                                "font_weight": None
                            }
                        }
                    }
                }
            ]
        }

        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            json.dump(theme, f, indent=4)
        print(f"✓ Generated Zed theme: {output_path}")

    def generate_firefox_theme(self, palette: Dict[str, Any], output_dir: Path):
        """Generate Firefox userChrome.css and userContent.css themes."""
        p = palette["palette"]
        appearance = palette["appearance"]
        is_dark = appearance == "dark"
        
        # Generate userChrome.css (browser UI)
        userchrome_content = f"""/**
 * Soft Focus {appearance.title()} Theme for Firefox
 * 
 * Installation:
 * 1. Navigate to about:config
 * 2. Set toolkit.legacyUserProfileCustomizations.stylesheets to true
 * 3. Navigate to about:support
 * 4. Click "Open Folder" next to "Profile Folder"
 * 5. Create a "chrome" folder if it doesn't exist
 * 6. Place this file as chrome/userChrome.css
 * 7. Restart Firefox
 */

/* Color Palette */
:root {{
  /* Base colors */
  --sf-background: {p["background"]};
  --sf-foreground: {p["foreground"]};
  --sf-background-alt: {p["background_alt"]};
  --sf-background-elevated: {p["background_elevated"]};
  --sf-foreground-alt: {p["foreground_alt"]};
  --sf-foreground-dim: {p["foreground_dim"]};

  /* Accent colors */
  --sf-primary: {p["primary"]};
  --sf-secondary: {p["secondary"]};
  --sf-tertiary: {p["tertiary"]};

  /* Semantic colors */
  --sf-success: {p["success"]};
  --sf-warning: {p["warning"]};
  --sf-error: {p["error"]};
  --sf-info: {p["info"]};

  /* UI elements */
  --sf-border: {p["border"]};
  --sf-border-active: {p["border_active"]};

  /* Override Firefox default variables */
  --toolbar-bgcolor: var(--sf-background) !important;
  --toolbar-color: var(--sf-foreground) !important;
  --tab-selected-bgcolor: var(--sf-background-elevated) !important;
  --lwt-sidebar-background-color: var(--sf-background) !important;
  --lwt-sidebar-text-color: var(--sf-foreground) !important;
}}

/* ===== Toolbar ===== */
#navigator-toolbox {{
  background-color: var(--sf-background) !important;
  border: none !important;
}}

/* Main toolbar */
#nav-bar {{
  background-color: var(--sf-background) !important;
  border: none !important;
  box-shadow: none !important;
  padding: 4px 8px !important;
}}

/* URL bar */
#urlbar,
#urlbar:not([breakout][breakout-extend]) {{
  background-color: var(--sf-background-alt) !important;
  color: var(--sf-foreground) !important;
  border: 1px solid var(--sf-border) !important;
  border-radius: 6px !important;
}}

#urlbar[focused] {{
  background-color: var(--sf-background-elevated) !important;
  border-color: var(--sf-primary) !important;
  box-shadow: 0 0 0 1px var(--sf-primary) !important;
}}

/* URL bar text */
#urlbar-input {{
  color: var(--sf-foreground) !important;
  font-family: "JetBrainsMono Nerd Font", monospace !important;
  font-size: 13px !important;
}}

/* Search suggestions */
#urlbar-results {{
  background-color: var(--sf-background-elevated) !important;
  border: 1px solid var(--sf-border) !important;
  border-radius: 6px !important;
  margin-top: 4px !important;
}}

.urlbarView-row {{
  background-color: var(--sf-background-elevated) !important;
}}

.urlbarView-row:hover {{
  background-color: var(--sf-background-alt) !important;
}}

.urlbarView-row[selected] {{
  background-color: var(--sf-primary) !important;
  color: var(--sf-{"foreground" if is_dark else "background"}) !important;
}}

/* ===== Tabs ===== */
.tabbrowser-tab {{
  background-color: var(--sf-background) !important;
  color: var(--sf-foreground-dim) !important;
  border: none !important;
  border-radius: 6px 6px 0 0 !important;
  margin: 0 2px !important;
}}

.tabbrowser-tab:hover {{
  background-color: var(--sf-background-alt) !important;
  color: var(--sf-foreground-alt) !important;
}}

.tabbrowser-tab[selected] {{
  background-color: var(--sf-background-elevated) !important;
  color: var(--sf-foreground) !important;
  border-bottom: 2px solid var(--sf-primary) !important;
}}

/* Tab text */
.tab-text {{
  color: inherit !important;
  font-weight: normal !important;
}}

.tabbrowser-tab[selected] .tab-text {{
  font-weight: 500 !important;
  color: var(--sf-foreground) !important;
}}

/* Tab close button */
.tab-close-button {{
  color: var(--sf-foreground-dim) !important;
}}

.tab-close-button:hover {{
  background-color: var(--sf-error) !important;
  color: var(--sf-{"foreground" if is_dark else "background"}) !important;
  border-radius: 3px !important;
}}

/* New tab button */
#tabs-newtab-button {{
  background-color: var(--sf-background-alt) !important;
  color: var(--sf-primary) !important;
  border-radius: 6px !important;
}}

#tabs-newtab-button:hover {{
  background-color: var(--sf-primary) !important;
  color: var(--sf-{"foreground" if is_dark else "background"}) !important;
}}

/* ===== Sidebar ===== */
#sidebar-box {{
  background-color: var(--sf-background) !important;
  border-right: 1px solid var(--sf-border) !important;
}}

#sidebar-header {{
  background-color: var(--sf-background) !important;
  border-bottom: 1px solid var(--sf-border) !important;
  color: var(--sf-foreground) !important;
}}

#sidebar-splitter {{
  background-color: var(--sf-border) !important;
  border: none !important;
  width: 1px !important;
}}

/* ===== Context Menu ===== */
menupopup {{
  background-color: var(--sf-background-elevated) !important;
  border: 1px solid var(--sf-border) !important;
  border-radius: 6px !important;
  padding: 4px !important;
}}

menuitem,
menu {{
  color: var(--sf-foreground) !important;
  border-radius: 4px !important;
}}

menuitem:hover,
menu:hover {{
  background-color: var(--sf-background-alt) !important;
}}

menuitem[selected],
menu[selected] {{
  background-color: var(--sf-primary) !important;
  color: var(--sf-{"foreground" if is_dark else "background"}) !important;
}}

menuseparator {{
  border-top: 1px solid var(--sf-border) !important;
  margin: 4px 0 !important;
}}

/* ===== Buttons ===== */
toolbarbutton {{
  color: var(--sf-foreground) !important;
  border-radius: 6px !important;
}}

toolbarbutton:hover {{
  background-color: var(--sf-background-alt) !important;
}}

toolbarbutton[checked],
toolbarbutton[open] {{
  background-color: var(--sf-primary) !important;
  color: var(--sf-{"foreground" if is_dark else "background"}) !important;
}}

/* ===== Bookmarks Bar ===== */
#PersonalToolbar {{
  background-color: var(--sf-background) !important;
  border-bottom: 1px solid var(--sf-border) !important;
  padding: 4px 8px !important;
}}

.bookmark-item {{
  background-color: transparent !important;
  color: var(--sf-foreground-alt) !important;
  border-radius: 4px !important;
  padding: 4px 8px !important;
}}

.bookmark-item:hover {{
  background-color: var(--sf-background-alt) !important;
  color: var(--sf-foreground) !important;
}}

/* ===== Find Bar ===== */
findbar {{
  background-color: var(--sf-background-elevated) !important;
  border: 1px solid var(--sf-border) !important;
  color: var(--sf-foreground) !important;
}}

.findbar-textbox {{
  background-color: var(--sf-background-alt) !important;
  color: var(--sf-foreground) !important;
  border: 1px solid var(--sf-border) !important;
  border-radius: 4px !important;
}}

.findbar-textbox[focused] {{
  border-color: var(--sf-primary) !important;
}}

/* ===== Notifications ===== */
notification {{
  background-color: var(--sf-background-elevated) !important;
  border: 1px solid var(--sf-border) !important;
  color: var(--sf-foreground) !important;
}}

.notificationbox-stack notification[type="info"] {{
  background-color: var(--sf-info) !important;
  {"" if is_dark else "color: var(--sf-background) !important;"}
}}

.notificationbox-stack notification[type="warning"] {{
  background-color: var(--sf-warning) !important;
  {"" if is_dark else "color: var(--sf-background) !important;"}
}}

.notificationbox-stack notification[type="error"] {{
  background-color: var(--sf-error) !important;
  {"" if is_dark else "color: var(--sf-background) !important;"}
}}

/* ===== Scrollbars ===== */
scrollbar {{
  background-color: var(--sf-background) !important;
}}

scrollbar thumb {{
  background-color: var(--sf-foreground-dim) !important;
  border-radius: 4px !important;
}}

scrollbar thumb:hover {{
  background-color: var(--sf-foreground-alt) !important;
}}

/* ===== Status Panel ===== */
#statuspanel {{
  background-color: var(--sf-background-elevated) !important;
  border: 1px solid var(--sf-border) !important;
  color: var(--sf-foreground) !important;
  border-radius: 6px !important;
  padding: 4px 8px !important;
}}

/* ===== Developer Tools ===== */
#developer-toolbar {{
  background-color: var(--sf-background) !important;
  border-top: 1px solid var(--sf-border) !important;
}}

/* ===== Privacy/Security Indicators ===== */
#identity-box {{
  background-color: transparent !important;
  border-radius: 4px !important;
}}

#identity-box:hover {{
  background-color: var(--sf-background-alt) !important;
}}

#identity-box[open] {{
  background-color: var(--sf-primary) !important;
}}

/* Lock icon color */
#identity-icon-label {{
  color: var(--sf-foreground) !important;
}}

/* ===== Extension Icons ===== */
#unified-extensions-button {{
  background-color: transparent !important;
}}

#unified-extensions-button:hover {{
  background-color: var(--sf-background-alt) !important;
}}

/* ===== Tab Counter (if any extension) ===== */
.tab-counter {{
  color: var(--sf-primary) !important;
  font-weight: 500 !important;
}}

/* ===== Minimize visual clutter ===== */
/* Remove tab separators */
.tabbrowser-tab::after,
.tabbrowser-tab::before {{
  display: none !important;
}}

/* Compact tab height */
:root {{
  --tab-min-height: 36px !important;
}}

/* Compact toolbar */
:root[uidensity="compact"] #nav-bar {{
  padding: 2px 8px !important;
}}
"""

        # Generate userContent.css (web content pages)
        usercontent_content = f"""/**
 * Soft Focus {appearance.title()} Theme for Firefox - Content Styles
 * 
 * This file themes web content pages (like about: pages and reader mode)
 * Place this file as chrome/userContent.css in your Firefox profile
 */

/* Color Palette */
@-moz-document url-prefix(about:),
url-prefix(chrome: //),

  url(about:blank){{
  :root {{
    /* Base colors */
    --sf-background: {p["background"]};
    --sf-foreground: {p["foreground"]};
    --sf-background-alt: {p["background_alt"]};
    --sf-background-elevated: {p["background_elevated"]};
    --sf-foreground-alt: {p["foreground_alt"]};
    --sf-foreground-dim: {p["foreground_dim"]};

    /* Accent colors */
    --sf-primary: {p["primary"]};
    --sf-secondary: {p["secondary"]};

    /* Semantic colors */
    --sf-success: {p["success"]};
    --sf-warning: {p["warning"]};
    --sf-error: {p["error"]};

    /* UI elements */
    --sf-border: {p["border"]};
  }}
}}

/* ===== About:Preferences ===== */
@-moz-document url-prefix(about:preferences) {{
  body {{
    background-color: var(--sf-background) !important;
    color: var(--sf-foreground) !important;
  }}

  .main-content {{
    background-color: var(--sf-background) !important;
  }}

  #categories {{
    background-color: var(--sf-background-alt) !important;
  }}

  .category {{
    color: var(--sf-foreground-alt) !important;
  }}

  .category[selected] {{
    background-color: var(--sf-primary) !important;
    color: var(--sf-foreground) !important;
  }}

  input[type="text"],
  input[type="email"],
  input[type="url"],
  textarea {{
    background-color: var(--sf-background-elevated) !important;
    color: var(--sf-foreground) !important;
    border: 1px solid var(--sf-border) !important;
  }}

  input[type="text"]:focus,
  input[type="email"]:focus,
  input[type="url"]:focus,
  textarea:focus {{
    border-color: var(--sf-primary) !important;
  }}

  button {{
    background-color: var(--sf-primary) !important;
    color: var(--sf-foreground) !important;
    border: none !important;
  }}

  button:hover {{
    background-color: var(--sf-secondary) !important;
  }}
}}

/* ===== About:Addons ===== */
@-moz-document url-prefix(about:addons) {{
  body {{
    background-color: var(--sf-background) !important;
    color: var(--sf-foreground) !important;
  }}

  .main-content {{
    background-color: var(--sf-background) !important;
  }}

  addon-card {{
    background-color: var(--sf-background-elevated) !important;
    border: 1px solid var(--sf-border) !important;
    color: var(--sf-foreground) !important;
  }}

  .addon-name {{
    color: var(--sf-foreground) !important;
  }}

  .addon-description {{
    color: var(--sf-foreground-alt) !important;
  }}

  button {{
    background-color: var(--sf-primary) !important;
    color: var(--sf-foreground) !important;
  }}
}}

/* ===== About:Home and About:NewTab ===== */
@-moz-document url(about:home),
url(about:newtab),
url(about:blank){{
body {{
  background-color: var(--sf-background) !important;
  color: var(--sf-foreground) !important;
}}

.search-wrapper input {{
  background-color: var(--sf-background-elevated) !important;
  color: var(--sf-foreground) !important;
  border: 1px solid var(--sf-border) !important;
}}

.search-wrapper input:focus {{
  border-color: var(--sf-primary) !important;
}}

.top-sites-list {{
  background-color: var(--sf-background) !important;
}}

.top-site-outer {{
  background-color: var(--sf-background-elevated) !important;
  border: 1px solid var(--sf-border) !important;
}}

.top-site-outer:hover {{
  background-color: var(--sf-background-alt) !important;
}}
}}

/* ===== Reader Mode ===== */
@-moz-document url-prefix(about:reader) {{
  body {{
    background-color: var(--sf-background) !important;
    color: var(--sf-foreground) !important;
  }}

  .container {{
    background-color: var(--sf-background) !important;
  }}

  .content {{
    color: var(--sf-foreground) !important;
    font-family: "SF Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif !important;
  }}

  h1, h2, h3, h4, h5, h6 {{
    color: var(--sf-primary) !important;
  }}

  a {{
    color: var(--sf-secondary) !important;
  }}

  a:hover {{
    color: var(--sf-primary) !important;
  }}

  code,
  pre {{
    background-color: var(--sf-background-elevated) !important;
    color: var(--sf-foreground) !important;
    border: 1px solid var(--sf-border) !important;
    font-family: "JetBrainsMono Nerd Font", monospace !important;
  }}

  blockquote {{
    border-left: 3px solid var(--sf-primary) !important;
    color: var(--sf-foreground-alt) !important;
    background-color: var(--sf-background-alt) !important;
  }}
}}

/* ===== About:Config ===== */
@-moz-document url(about:config){{
body {{
  background-color: var(--sf-background) !important;
  color: var(--sf-foreground) !important;
}}

#prefs {{
  background-color: var(--sf-background) !important;
}}

tr {{
  background-color: var(--sf-background) !important;
}}

tr:hover {{
  background-color: var(--sf-background-alt) !important;
}}

th {{
  background-color: var(--sf-background-elevated) !important;
  color: var(--sf-primary) !important;
}}

input[type="text"] {{
  background-color: var(--sf-background-elevated) !important;
  color: var(--sf-foreground) !important;
  border: 1px solid var(--sf-border) !important;
}}
}}

/* ===== About:Support ===== */
@-moz-document url(about:support){{
body {{
  background-color: var(--sf-background) !important;
  color: var(--sf-foreground) !important;
}}

h1, h2, h3 {{
  color: var(--sf-primary) !important;
}}

table {{
  background-color: var(--sf-background-elevated) !important;
  border: 1px solid var(--sf-border) !important;
}}

th {{
  background-color: var(--sf-background-alt) !important;
  color: var(--sf-primary) !important;
}}

button {{
  background-color: var(--sf-primary) !important;
  color: var(--sf-foreground) !important;
  border: none !important;
}}
}}

/* ===== Developer Tools (if embedded) ===== */
@-moz-document url-prefix(about:devtools) {{
  body {{
    background-color: var(--sf-background) !important;
    color: var(--sf-foreground) !important;
  }}
}}

/* ===== Scrollbars for content ===== */
* {{
  scrollbar-width: thin !important;
  scrollbar-color: var(--sf-foreground-dim) var(--sf-background) !important;
}}

/* ===== Custom styling for specific websites (optional) ===== */

/* GitHub Dark Mode Enhancement */
@-moz-document domain(github.com) {{
  :root {{
    color-scheme: {"dark" if is_dark else "light"} !important;
  }}
}}

/* Stack Overflow */
@-moz-document domain(stackoverflow.com) {{
  :root {{
    color-scheme: {"dark" if is_dark else "light"} !important;
  }}
}}

/* Reddit */
@-moz-document domain(reddit.com) {{
  :root {{
    color-scheme: {"dark" if is_dark else "light"} !important;
  }}
}}

/* YouTube */
@-moz-document domain(youtube.com) {{
  :root {{
    color-scheme: {"dark" if is_dark else "light"} !important;
  }}
}}
"""

        # Write files
        output_dir.mkdir(parents=True, exist_ok=True)
        
        with open(output_dir / "userChrome.css", "w") as f:
            f.write(userchrome_content)
        
        with open(output_dir / "userContent.css", "w") as f:
            f.write(usercontent_content)
        
        print(f"✓ Generated Firefox theme: {output_dir}")

    def generate_obsidian_theme(self, palette: Dict[str, Any], output_dir: Path):
        """Generate Obsidian theme files (manifest.json + theme.css)."""
        p = palette["palette"]
        t = p["terminal"]
        appearance = palette["appearance"]
        is_dark = appearance == "dark"
        
        # Generate manifest.json
        manifest = {
            "name": f"Soft Focus {appearance.title()}",
            "version": "1.0.0",
            "minAppVersion": "0.16.0",
            "author": "Hamza Kamal",
            "authorUrl": "https://github.com/kamal-hamza"
        }
        
        # Generate theme.css
        theme_css = f"""/*
 * Soft Focus {appearance.title()} Theme for Obsidian
 * Version: 1.0.0
 * Author: Hamza Kamal
 * Description: A minimalist {"dark" if is_dark else "light"} theme with blue accents for Obsidian
 * Auto-generated from central color palette
 */

.theme-{"dark" if is_dark else "light"} {{
  /* ========================================
   * Color Palette
   * ======================================== */

  /* Base Colors */
  --background-primary: {p["background"]};
  --background-primary-alt: {p["background_alt"]};
  --background-secondary: {p["background"]};
  --background-secondary-alt: {p["background_alt"]};
  --background-modifier-border: {p["border"]};
  --background-modifier-form-field: {p["background_elevated"]};
  --background-modifier-form-field-highlighted: {p["background_elevated"]};
  --background-modifier-box-shadow: rgba({"0, 0, 0, 0.3" if is_dark else "0, 0, 0, 0.1"});
  --background-modifier-success: {p["success"]};
  --background-modifier-error: {p["error"]};
  --background-modifier-error-hover: {t["bright_red"]};
  --background-modifier-cover: rgba({("5, 5, 5, 0.8" if is_dark else "255, 255, 255, 0.8")});

  /* Text Colors */
  --text-normal: {p["foreground"]};
  --text-muted: {p["foreground_alt"]};
  --text-faint: {p["foreground_dim"]};
  --text-error: {p["error"]};
  --text-accent: {p["primary"]};
  --text-accent-hover: {p["secondary"]};
  --text-on-accent: {p["background" if is_dark else "foreground"]};
  --text-selection: {p["primary"]}4D;

  /* Interactive Elements */
  --interactive-normal: {p["background_elevated"]};
  --interactive-hover: {p["background_alt"]};
  --interactive-accent: {p["primary"]};
  --interactive-accent-hover: {p["secondary"]};
  --interactive-success: {p["success"]};

  /* Scrollbar */
  --scrollbar-active-thumb-bg: {p["foreground_dim" if is_dark else "foreground_alt"]}{"50" if is_dark else "80"};
  --scrollbar-bg: {p["foreground_dim" if is_dark else "foreground_alt"]}{"0D" if is_dark else "20"};
  --scrollbar-thumb-bg: {p["foreground_dim" if is_dark else "foreground_alt"]}{"30" if is_dark else "40"};

  /* Syntax Highlighting */
  --code-normal: {p["foreground"]};
  --code-background: {p["background_elevated"]};
  --code-keyword: {p["keyword"]};
  --code-function: {p["function"]};
  --code-string: {p["string"]};
  --code-number: {p["constant"]};
  --code-property: {p["tertiary"]};
  --code-comment: {p["comment"]};
  --code-operator: {p["operator"]};

  /* UI Elements */
  --titlebar-text-color-focused: {p["foreground"]};
  --titlebar-text-color-unfocused: {p["foreground_dim"]};
  --titlebar-background-focused: {p["background"]};
  --titlebar-background-unfocused: {p["background_alt"]};

  /* Borders */
  --border-color: {p["border"]};
  --border-color-hover: {p["border_active"]};

  /* Tags */
  --tag-background: {p["background_elevated"]};
  --tag-background-hover: {p["primary"]};
  --tag-color: {p["secondary"]};
  --tag-color-hover: {p["background" if is_dark else "foreground"]};

  /* Links */
  --link-color: {p["primary"]};
  --link-color-hover: {p["secondary"]};
  --link-external-color: {p["tertiary"]};
  --link-external-color-hover: {p["secondary"]};
  --link-unresolved-color: {p["foreground_dim"]};

  /* Graph View */
  --graph-node: {p["primary"]};
  --graph-node-unresolved: {p["foreground_dim"]};
  --graph-node-tag: {p["success"]};
  --graph-node-attachment: {p["warning"]};
  --graph-line: {p["border"]};
  --graph-line-highlight: {p["primary"]};

  /* Checkboxes */
  --checkbox-color: {p["primary"]};
  --checkbox-color-hover: {p["secondary"]};
  --checkbox-border-color: {p["border"]};
  --checkbox-border-color-hover: {p["border_active"]};

  /* Tables */
  --table-border-color: {p["border"]};
  --table-header-background: {p["background_elevated"]};
  --table-header-background-hover: {p["background_alt"]};
  --table-row-even-background: {p["foreground_dim" if is_dark else "foreground_alt"]}{"05" if is_dark else "0D"};
  --table-row-odd-background: transparent;
  --table-row-hover-background: {p["primary"]}1A;

  /* Callouts */
  --callout-default: {p["primary"]};
  --callout-info: {p["info"]};
  --callout-todo: {p["tertiary"]};
  --callout-important: {p["warning"]};
  --callout-warning: {p["warning"]};
  --callout-success: {p["success"]};
  --callout-question: {p["secondary"]};
  --callout-failure: {p["error"]};
  --callout-error: {p["error"]};
  --callout-bug: {p["error"]};
  --callout-example: {t["magenta"]};
  --callout-quote: {p["foreground_dim"]};
}}

/* ========================================
 * Typography
 * ======================================== */

body {{
  --font-text: -apple-system, BlinkMacSystemFont, "Segoe UI", "SF Pro", Roboto, sans-serif;
  --font-monospace: "JetBrainsMono Nerd Font", "Fira Code", Consolas, monospace;
  --font-interface: -apple-system, BlinkMacSystemFont, "Segoe UI", "SF Pro", Roboto, sans-serif;
}}

.markdown-preview-view,
.markdown-source-view {{
  font-family: var(--font-text);
  font-size: 16px;
  line-height: 1.6;
  color: var(--text-normal);
}}

/* Headings */
.markdown-preview-view h1,
.cm-header-1 {{
  color: var(--text-accent);
  font-size: 2em;
  font-weight: 600;
  border-bottom: 2px solid var(--text-accent);
  padding-bottom: 0.3em;
  margin-bottom: 1em;
}}

.markdown-preview-view h2,
.cm-header-2 {{
  color: var(--text-accent);
  font-size: 1.6em;
  font-weight: 600;
  margin-top: 1.5em;
  margin-bottom: 0.75em;
}}

.markdown-preview-view h3,
.cm-header-3 {{
  color: var(--text-accent);
  font-size: 1.3em;
  font-weight: 600;
  margin-top: 1.25em;
}}

.markdown-preview-view h4,
.cm-header-4 {{
  color: var(--text-accent-hover);
  font-size: 1.1em;
  font-weight: 600;
}}

.markdown-preview-view h5,
.cm-header-5 {{
  color: var(--text-accent-hover);
  font-size: 1em;
  font-weight: 600;
}}

.markdown-preview-view h6,
.cm-header-6 {{
  color: var(--text-muted);
  font-size: 0.9em;
  font-weight: 600;
}}

/* ========================================
 * Code Blocks
 * ======================================== */

code {{
  background-color: var(--code-background);
  color: var(--code-normal);
  font-family: var(--font-monospace);
  font-size: 0.9em;
  padding: 0.2em 0.4em;
  border-radius: 3px;
}}

.markdown-preview-view pre {{
  background-color: var(--code-background);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  padding: 1em;
  overflow-x: auto;
}}

.markdown-preview-view pre code {{
  background-color: transparent;
  padding: 0;
}}

/* Syntax Highlighting */
.cm-s-obsidian span.cm-keyword {{
  color: var(--code-keyword);
}}

.cm-s-obsidian span.cm-def {{
  color: var(--code-function);
}}

.cm-s-obsidian span.cm-string {{
  color: var(--code-string);
}}

.cm-s-obsidian span.cm-number {{
  color: var(--code-number);
}}

.cm-s-obsidian span.cm-property {{
  color: var(--code-property);
}}

.cm-s-obsidian span.cm-comment {{
  color: var(--code-comment);
  font-style: italic;
}}

.cm-s-obsidian span.cm-operator {{
  color: var(--code-operator);
}}

/* ========================================
 * Links
 * ======================================== */

.markdown-preview-view a {{
  color: var(--link-color);
  text-decoration: none;
}}

.markdown-preview-view a:hover {{
  color: var(--link-color-hover);
  text-decoration: underline;
}}

.markdown-preview-view a.external-link {{
  color: var(--link-external-color);
}}

.markdown-preview-view a.external-link:hover {{
  color: var(--link-external-color-hover);
}}

.cm-link {{
  color: var(--link-color);
}}

/* Unresolved Links */
.markdown-preview-view .internal-link.is-unresolved {{
  color: var(--link-unresolved-color);
}}

/* ========================================
 * Lists
 * ======================================== */

.markdown-preview-view ul,
.markdown-preview-view ol {{
  padding-left: 2em;
}}

.markdown-preview-view li {{
  margin: 0.5em 0;
}}

/* Task Lists */
.markdown-preview-view input[type="checkbox"] {{
  width: 1.2em;
  height: 1.2em;
  margin-right: 0.5em;
  cursor: pointer;
  accent-color: var(--checkbox-color);
}}

.markdown-preview-view .task-list-item-checkbox {{
  border-color: var(--checkbox-border-color);
}}

.markdown-preview-view .task-list-item-checkbox:hover {{
  border-color: var(--checkbox-border-color-hover);
}}

.markdown-preview-view .task-list-item-checkbox:checked {{
  background-color: var(--checkbox-color);
  border-color: var(--checkbox-color);
}}

/* ========================================
 * Tables
 * ======================================== */

.markdown-preview-view table {{
  border-collapse: collapse;
  width: 100%;
  margin: 1em 0;
}}

.markdown-preview-view th {{
  background-color: var(--table-header-background);
  color: var(--text-accent);
  font-weight: 600;
  padding: 0.6em 1em;
  border: 1px solid var(--table-border-color);
}}

.markdown-preview-view td {{
  padding: 0.6em 1em;
  border: 1px solid var(--table-border-color);
}}

.markdown-preview-view tr:nth-child(even) {{
  background-color: var(--table-row-even-background);
}}

.markdown-preview-view tr:hover {{
  background-color: var(--table-row-hover-background);
}}

/* ========================================
 * Blockquotes
 * ======================================== */

.markdown-preview-view blockquote {{
  border-left: 3px solid var(--text-accent);
  background-color: {p["primary"]}0D;
  padding: 0.5em 1em;
  margin: 1em 0;
  color: var(--text-muted);
}}

.cm-quote {{
  color: var(--text-muted);
}}

/* ========================================
 * Horizontal Rules
 * ======================================== */

.markdown-preview-view hr {{
  border: none;
  border-top: 2px solid var(--border-color);
  margin: 2em 0;
}}

/* ========================================
 * Tags
 * ======================================== */

.tag {{
  background-color: var(--tag-background);
  color: var(--tag-color);
  padding: 0.2em 0.6em;
  border-radius: 12px;
  font-size: 0.85em;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}}

.tag:hover {{
  background-color: var(--tag-background-hover);
  color: var(--tag-color-hover);
}}

/* ========================================
 * Callouts
 * ======================================== */

.callout {{
  border-left: 3px solid var(--callout-default);
  border-radius: 6px;
  background-color: {p["foreground_dim" if is_dark else "foreground_alt"]}{"08" if is_dark else "05"};
  padding: 1em;
  margin: 1em 0;
}}

.callout-title {{
  font-weight: 600;
  margin-bottom: 0.5em;
}}

.callout[data-callout="info"] {{
  border-left-color: var(--callout-info);
}}

.callout[data-callout="todo"] {{
  border-left-color: var(--callout-todo);
}}

.callout[data-callout="important"] {{
  border-left-color: var(--callout-important);
}}

.callout[data-callout="warning"] {{
  border-left-color: var(--callout-warning);
}}

.callout[data-callout="success"] {{
  border-left-color: var(--callout-success);
}}

.callout[data-callout="question"] {{
  border-left-color: var(--callout-question);
}}

.callout[data-callout="failure"] {{
  border-left-color: var(--callout-failure);
}}

.callout[data-callout="error"] {{
  border-left-color: var(--callout-error);
}}

.callout[data-callout="bug"] {{
  border-left-color: var(--callout-bug);
}}

.callout[data-callout="example"] {{
  border-left-color: var(--callout-example);
}}

.callout[data-callout="quote"] {{
  border-left-color: var(--callout-quote);
}}

/* ========================================
 * UI Elements
 * ======================================== */

/* Sidebar */
.workspace-leaf {{
  border-right: 1px solid var(--border-color);
}}

.workspace-tab-header {{
  background-color: var(--background-primary);
  border-bottom: 1px solid var(--border-color);
}}

.workspace-tab-header-container {{
  background-color: var(--background-primary);
}}

/* Title Bar */
.titlebar {{
  background-color: var(--titlebar-background-focused);
  color: var(--titlebar-text-color-focused);
}}

/* Status Bar */
.status-bar {{
  background-color: var(--background-primary);
  border-top: 1px solid var(--border-color);
  font-size: 12px;
}}

/* File Explorer */
.nav-file-title,
.nav-folder-title {{
  color: var(--text-normal);
  border-radius: 4px;
  padding: 3px 6px;
}}

.nav-file-title:hover,
.nav-folder-title:hover {{
  background-color: var(--interactive-hover);
}}

.nav-file-title.is-active {{
  background-color: var(--interactive-accent);
  color: var(--text-on-accent);
}}

/* Search */
.search-result-file-title {{
  color: var(--text-accent);
  font-weight: 600;
}}

.search-result-file-match {{
  background-color: {p["primary"]}33;
}}

/* Buttons */
.button {{
  background-color: var(--interactive-accent);
  color: var(--text-on-accent);
  border-radius: 6px;
  padding: 6px 12px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s ease;
}}

.button:hover {{
  background-color: var(--interactive-accent-hover);
}}

/* Input Fields */
input[type="text"],
input[type="search"],
textarea {{
  background-color: var(--background-modifier-form-field);
  color: var(--text-normal);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  padding: 6px 12px;
}}

input[type="text"]:focus,
input[type="search"]:focus,
textarea:focus {{
  border-color: var(--border-color-hover);
  outline: none;
}}

/* Modals */
.modal {{
  background-color: var(--background-primary);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  box-shadow: 0 8px 32px rgba({"0, 0, 0, 0.5" if is_dark else "0, 0, 0, 0.2"});
}}

.modal-title {{
  color: var(--text-accent);
  font-weight: 600;
}}

/* ========================================
 * Graph View
 * ======================================== */

.graph-view.color-fill-unresolved {{
  color: var(--graph-node-unresolved);
}}

.graph-view.color-fill-tag {{
  color: var(--graph-node-tag);
}}

.graph-view.color-fill-attachment {{
  color: var(--graph-node-attachment);
}}

/* ========================================
 * Scrollbars
 * ======================================== */

::-webkit-scrollbar {{
  width: 10px;
  height: 10px;
}}

::-webkit-scrollbar-track {{
  background: var(--scrollbar-bg);
}}

::-webkit-scrollbar-thumb {{
  background: var(--scrollbar-thumb-bg);
  border-radius: 5px;
}}

::-webkit-scrollbar-thumb:hover {{
  background: var(--scrollbar-active-thumb-bg);
}}

/* ========================================
 * Cursor and Selection
 * ======================================== */

::selection {{
  background-color: var(--text-selection);
}}

.cm-cursor {{
  border-left: 2px solid {p["foreground"]};
}}

/* ========================================
 * Customizations
 * ======================================== */

/* Minimize visual clutter */
.view-header-icon {{
  color: {p["foreground_dim"]};
}}

.view-header-icon:hover {{
  color: {p["foreground"]};
}}

/* Smooth transitions */
* {{
  transition: background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease;
}}

/* Focus outlines */
*:focus-visible {{
  outline: 2px solid var(--interactive-accent);
  outline-offset: 2px;
}}
"""

        # Write files
        output_dir.mkdir(parents=True, exist_ok=True)
        
        with open(output_dir / "manifest.json", "w") as f:
            json.dump(manifest, f, indent=2)
        
        with open(output_dir / "theme.css", "w") as f:
            f.write(theme_css)
        
        print(f"✓ Generated Obsidian theme: {output_dir}")

    def generate_nvim_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Neovim Lua theme file."""
        p = palette["palette"]
        t = p["terminal"]
        appearance = palette["appearance"]
        is_dark = appearance == "dark"
        
        # Generate Lua theme content
        theme_lua = f"""-- Soft Focus {appearance.title()} Neovim Theme
-- Auto-generated from central color palette
-- Based on the Zed "Soft Focus {appearance.title()}" theme by Hamza Kamal

local M = {{}}

-- Define color palette (accessible outside setup function)
M.colors = {{
    -- Base colors
    bg = "{p["background"]}",      -- background
    fg = "{p["foreground"]}",      -- text
    bg_alt = "{p["background_alt"]}", -- element.background
    bg_elevated = "{p["background_elevated"]}", -- elevated_surface.background
    fg_alt = "{p["foreground_alt"]}",  -- text.muted
    fg_dim = "{p["foreground_dim"]}",  -- text.placeholder

    -- Accent colors
    blue = "{p["primary"]}",   -- primary accent
    blue_light = "{p["secondary"]}", -- text.accent, function
    green = "{p["success"]}",  -- string, success
    mint = "{p.get("accent_mint", p["tertiary"])}",   -- tertiary accent

    -- Syntax colors
    red = "{p["error"]}",       -- base red
    red_bright = "{t["bright_red"]}", -- keyword, error (bright)
    orange = "{p["constant"]}",    -- type, warning
    orange_bright = "{t["bright_yellow"]}", -- bright yellow
    cyan = "{p["secondary"]}",      -- function
    cyan_bright = "{t["bright_cyan"]}", -- bright cyan
    purple = "{t["magenta"]}",    -- magenta
    purple_bright = "{t["bright_magenta"]}", -- bright magenta

    -- UI colors
    border = "{p["border"]}",
    comment = "{p["comment"]}",
    line_nr = "{p["foreground_dim"]}",
    cursor_line = "{p["cursor_line"]}",
    visual = "{p["visual"]}",
    search = "{p["search"]}",

    -- Git colors
    git_add = "{p["success"]}",
    git_change = "{p["warning"]}",
    git_delete = "{p["error"]}",

    -- Diagnostic colors
    error = "{t["bright_red"]}",
    warn = "{p["warning"]}",
    info = "{p["success"]}",
    hint = "{p["secondary"]}",

    -- Terminal colors
    term_black = "{t["black"]}",
    term_red = "{t["red"]}",
    term_green = "{t["green"]}",
    term_yellow = "{t["yellow"]}",
    term_blue = "{t["blue"]}",
    term_magenta = "{t["magenta"]}",
    term_cyan = "{t["cyan"]}",
    term_white = "{t["white"]}",
    term_bright_black = "{t["bright_black"]}",
    term_bright_red = "{t["bright_red"]}",
    term_bright_green = "{t["bright_green"]}",
    term_bright_yellow = "{t["bright_yellow"]}",
    term_bright_blue = "{t["bright_blue"]}",
    term_bright_magenta = "{t["bright_magenta"]}",
    term_bright_cyan = "{t["bright_cyan"]}",
    term_bright_white = "{t["bright_white"]}",
}}

M.setup = function()
    -- Reset highlighting
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    -- Set theme name
    vim.g.colors_name = "soft-focus-{appearance}"

    -- Use the colors table
    local colors = M.colors

    -- Helper function to set highlight groups
    local function hl(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    -- Editor highlights
    hl("Normal", {{ fg = colors.fg, bg = colors.bg }})
    hl("NormalFloat", {{ fg = colors.fg, bg = colors.bg_elevated }})
    hl("NormalNC", {{ fg = colors.fg, bg = colors.bg }})
    hl("LineNr", {{ fg = colors.line_nr }})
    hl("CursorLine", {{ bg = colors.cursor_line }})
    hl("CursorLineNr", {{ fg = colors.fg, bold = true }})
    hl("Visual", {{ bg = colors.visual }})
    hl("VisualNOS", {{ bg = colors.visual }})
    hl("Search", {{ bg = colors.search }})
    hl("IncSearch", {{ bg = colors.search, fg = colors.fg }})
    hl("CurSearch", {{ bg = colors.blue, fg = colors.bg }})
    hl("Substitute", {{ bg = colors.red_bright, fg = colors.bg }})

    -- UI Elements
    hl("StatusLine", {{ fg = colors.fg, bg = colors.bg }})
    hl("StatusLineNC", {{ fg = colors.fg_alt, bg = colors.bg_elevated }})
    hl("TabLine", {{ fg = colors.fg_alt, bg = colors.bg }})
    hl("TabLineFill", {{ bg = colors.bg }})
    hl("TabLineSel", {{ fg = colors.fg, bg = colors.bg_elevated }})
    hl("WinSeparator", {{ fg = colors.border }})
    hl("VertSplit", {{ fg = colors.border }})
    hl("Pmenu", {{ fg = colors.fg, bg = colors.bg_elevated }})
    hl("PmenuSel", {{ fg = colors.fg, bg = colors.cursor_line, bold = true }})
    hl("PmenuSbar", {{ bg = colors.bg_alt }})
    hl("PmenuThumb", {{ bg = colors.border }})
    hl("WildMenu", {{ fg = colors.fg, bg = colors.cursor_line }})

    -- Folding
    hl("Folded", {{ fg = colors.comment, bg = colors.bg_elevated }})
    hl("FoldColumn", {{ fg = colors.comment }})

    -- Diff
    hl("DiffAdd", {{ bg = "{p["diff_add_bg"]}" }})
    hl("DiffChange", {{ bg = "{p["diff_change_bg"]}" }})
    hl("DiffDelete", {{ bg = "{p["diff_delete_bg"]}" }})
    hl("DiffText", {{ bg = "{p["warning"]}" }})

    -- Git signs
    hl("GitSignsAdd", {{ fg = colors.git_add }})
    hl("GitSignsChange", {{ fg = colors.git_change }})
    hl("GitSignsDelete", {{ fg = colors.git_delete }})

    -- Syntax highlighting
    hl("Comment", {{ fg = colors.comment, italic = true }})
    hl("Constant", {{ fg = colors.orange }})
    hl("String", {{ fg = colors.green }})
    hl("Character", {{ fg = colors.green }})
    hl("Number", {{ fg = colors.orange }})
    hl("Boolean", {{ fg = colors.red_bright }})
    hl("Float", {{ fg = colors.orange }})
    hl("Identifier", {{ fg = colors.fg }})
    hl("Function", {{ fg = colors.cyan }})
    hl("Statement", {{ fg = colors.red_bright }})
    hl("Conditional", {{ fg = colors.red_bright }})
    hl("Repeat", {{ fg = colors.red_bright }})
    hl("Label", {{ fg = colors.red_bright }})
    hl("Operator", {{ fg = colors.fg }})
    hl("Keyword", {{ fg = colors.red_bright }})
    hl("Exception", {{ fg = colors.red_bright }})
    hl("PreProc", {{ fg = colors.red_bright }})
    hl("Include", {{ fg = colors.red_bright }})
    hl("Define", {{ fg = colors.red_bright }})
    hl("Macro", {{ fg = colors.red_bright }})
    hl("PreCondit", {{ fg = colors.red_bright }})
    hl("Type", {{ fg = colors.orange }})
    hl("StorageClass", {{ fg = colors.red_bright }})
    hl("Structure", {{ fg = colors.orange }})
    hl("Typedef", {{ fg = colors.orange }})
    hl("Special", {{ fg = colors.cyan }})
    hl("SpecialChar", {{ fg = colors.cyan }})
    hl("Tag", {{ fg = colors.cyan }})
    hl("Delimiter", {{ fg = colors.fg }})
    hl("SpecialComment", {{ fg = colors.comment }})
    hl("Debug", {{ fg = colors.red_bright }})

    -- Treesitter highlights
    hl("@variable", {{ fg = colors.fg }})
    hl("@variable.builtin", {{ fg = colors.red_bright }})
    hl("@variable.parameter", {{ fg = colors.fg }})
    hl("@variable.member", {{ fg = colors.fg }})
    hl("@constant", {{ fg = colors.orange }})
    hl("@constant.builtin", {{ fg = colors.red_bright }})
    hl("@constant.macro", {{ fg = colors.orange }})
    hl("@string", {{ fg = colors.green }})
    hl("@string.escape", {{ fg = colors.cyan }})
    hl("@string.special", {{ fg = colors.cyan }})
    hl("@character", {{ fg = colors.green }})
    hl("@character.special", {{ fg = colors.cyan }})
    hl("@number", {{ fg = colors.orange }})
    hl("@boolean", {{ fg = colors.red_bright }})
    hl("@float", {{ fg = colors.orange }})
    hl("@function", {{ fg = colors.cyan }})
    hl("@function.builtin", {{ fg = colors.cyan }})
    hl("@function.call", {{ fg = colors.cyan }})
    hl("@function.macro", {{ fg = colors.red_bright }})
    hl("@method", {{ fg = colors.cyan }})
    hl("@method.call", {{ fg = colors.cyan }})
    hl("@constructor", {{ fg = colors.orange }})
    hl("@parameter", {{ fg = colors.fg }})
    hl("@keyword", {{ fg = colors.red_bright }})
    hl("@keyword.function", {{ fg = colors.red_bright }})
    hl("@keyword.operator", {{ fg = colors.red_bright }})
    hl("@keyword.return", {{ fg = colors.red_bright }})
    hl("@conditional", {{ fg = colors.red_bright }})
    hl("@repeat", {{ fg = colors.red_bright }})
    hl("@debug", {{ fg = colors.red_bright }})
    hl("@label", {{ fg = colors.red_bright }})
    hl("@include", {{ fg = colors.red_bright }})
    hl("@exception", {{ fg = colors.red_bright }})
    hl("@type", {{ fg = colors.orange }})
    hl("@type.builtin", {{ fg = colors.orange }})
    hl("@type.qualifier", {{ fg = colors.red_bright }})
    hl("@type.definition", {{ fg = colors.orange }})
    hl("@storageclass", {{ fg = colors.red_bright }})
    hl("@attribute", {{ fg = colors.cyan }})
    hl("@field", {{ fg = colors.fg }})
    hl("@property", {{ fg = colors.fg }})
    hl("@operator", {{ fg = colors.fg }})
    hl("@punctuation.delimiter", {{ fg = colors.fg }})
    hl("@punctuation.bracket", {{ fg = colors.fg }})
    hl("@punctuation.special", {{ fg = colors.cyan }})
    hl("@comment", {{ fg = colors.comment, italic = true }})
    hl("@comment.documentation", {{ fg = colors.comment, italic = true }})
    hl("@tag", {{ fg = colors.red_bright }})
    hl("@tag.attribute", {{ fg = colors.orange }})
    hl("@tag.delimiter", {{ fg = colors.fg }})

    -- LSP highlights
    hl("LspReferenceText", {{ bg = "{p["lsp_reference_bg"]}" }})
    hl("LspReferenceRead", {{ bg = "{p["lsp_reference_bg"]}" }})
    hl("LspReferenceWrite", {{ bg = "{p["lsp_reference_bg"]}" }})
    hl("LspCodeLens", {{ fg = colors.comment }})
    hl("LspCodeLensSeparator", {{ fg = colors.comment }})

    -- Diagnostics
    hl("DiagnosticError", {{ fg = colors.error }})
    hl("DiagnosticWarn", {{ fg = colors.warn }})
    hl("DiagnosticInfo", {{ fg = colors.info }})
    hl("DiagnosticHint", {{ fg = colors.hint }})
    hl("DiagnosticVirtualTextError", {{ fg = colors.error, bg = colors.bg }})
    hl("DiagnosticVirtualTextWarn", {{ fg = colors.warn, bg = colors.bg }})
    hl("DiagnosticVirtualTextInfo", {{ fg = colors.info, bg = colors.bg }})
    hl("DiagnosticVirtualTextHint", {{ fg = colors.hint, bg = colors.bg }})
    hl("DiagnosticUnderlineError", {{ sp = colors.error, undercurl = true }})
    hl("DiagnosticUnderlineWarn", {{ sp = colors.warn, undercurl = true }})
    hl("DiagnosticUnderlineInfo", {{ sp = colors.info, undercurl = true }})
    hl("DiagnosticUnderlineHint", {{ sp = colors.hint, undercurl = true }})

    -- Telescope
    hl("TelescopeNormal", {{ fg = colors.fg, bg = colors.bg_elevated }})
    hl("TelescopeBorder", {{ fg = colors.border, bg = colors.bg_elevated }})
    hl("TelescopePromptBorder", {{ fg = colors.border, bg = colors.bg_elevated }})
    hl("TelescopeResultsBorder", {{ fg = colors.border, bg = colors.bg_elevated }})
    hl("TelescopePreviewBorder", {{ fg = colors.border, bg = colors.bg_elevated }})
    hl("TelescopeSelection", {{ bg = colors.cursor_line, bold = true }})
    hl("TelescopeSelectionCaret", {{ fg = colors.cyan }})
    hl("TelescopeMultiSelection", {{ fg = colors.cyan }})
    hl("TelescopeMatching", {{ fg = colors.cyan, bold = true }})

    -- NvimTree
    hl("NvimTreeNormal", {{ fg = colors.fg, bg = colors.bg }})
    hl("NvimTreeRootFolder", {{ fg = colors.cyan, bold = true }})
    hl("NvimTreeGitDirty", {{ fg = colors.git_change }})
    hl("NvimTreeGitNew", {{ fg = colors.git_add }})
    hl("NvimTreeGitDeleted", {{ fg = colors.git_delete }})
    hl("NvimTreeSpecialFile", {{ fg = colors.cyan }})
    hl("NvimTreeIndentMarker", {{ fg = colors.comment }})
    hl("NvimTreeImageFile", {{ fg = colors.purple }})
    hl("NvimTreeSymlink", {{ fg = colors.cyan }})

    -- WhichKey
    hl("WhichKey", {{ fg = colors.cyan }})
    hl("WhichKeyGroup", {{ fg = colors.cyan }})
    hl("WhichKeyDesc", {{ fg = colors.fg }})
    hl("WhichKeySeperator", {{ fg = colors.comment }})
    hl("WhichKeySeparator", {{ fg = colors.comment }})
    hl("WhichKeyFloat", {{ bg = colors.bg_elevated }})
    hl("WhichKeyValue", {{ fg = colors.comment }})

    -- Indent Blankline
    hl("IndentBlanklineChar", {{ fg = "{p["indent_guide"]}" }})
    hl("IndentBlanklineContextChar", {{ fg = "{p["indent_guide_active"]}" }})
    hl("IndentBlanklineContextStart", {{ sp = colors.blue, underline = true }})

    -- Alpha (dashboard)
    hl("AlphaShortcut", {{ fg = colors.cyan }})
    hl("AlphaHeader", {{ fg = colors.cyan }})
    hl("AlphaHeaderLabel", {{ fg = colors.orange }})
    hl("AlphaFooter", {{ fg = colors.comment }})
    hl("AlphaButtons", {{ fg = colors.fg }})

    -- Notify
    hl("NotifyERRORBorder", {{ fg = colors.error }})
    hl("NotifyWARNBorder", {{ fg = colors.warn }})
    hl("NotifyINFOBorder", {{ fg = colors.info }})
    hl("NotifyDEBUGBorder", {{ fg = colors.comment }})
    hl("NotifyTRACEBorder", {{ fg = colors.hint }})
    hl("NotifyERRORIcon", {{ fg = colors.error }})
    hl("NotifyWARNIcon", {{ fg = colors.warn }})
    hl("NotifyINFOIcon", {{ fg = colors.info }})
    hl("NotifyDEBUGIcon", {{ fg = colors.comment }})
    hl("NotifyTRACEIcon", {{ fg = colors.hint }})
    hl("NotifyERRORTitle", {{ fg = colors.error }})
    hl("NotifyWARNTitle", {{ fg = colors.warn }})
    hl("NotifyINFOTitle", {{ fg = colors.info }})
    hl("NotifyDEBUGTitle", {{ fg = colors.comment }})
    hl("NotifyTRACETitle", {{ fg = colors.hint }})

    -- Bufferline
    hl("BufferLineIndicatorSelected", {{ fg = colors.blue }})
    hl("BufferLineFill", {{ bg = colors.bg }})

    -- Neo-tree
    hl("NeoTreeNormal", {{ fg = colors.fg, bg = colors.bg }})
    hl("NeoTreeNormalNC", {{ fg = colors.fg, bg = colors.bg }})
    hl("NeoTreeDirectoryName", {{ fg = colors.cyan }})
    hl("NeoTreeDirectoryIcon", {{ fg = colors.cyan }})
    hl("NeoTreeRootName", {{ fg = colors.cyan, bold = true }})
    hl("NeoTreeGitAdded", {{ fg = colors.git_add }})
    hl("NeoTreeGitDeleted", {{ fg = colors.git_delete }})
    hl("NeoTreeGitModified", {{ fg = colors.git_change }})
    hl("NeoTreeGitConflict", {{ fg = colors.error }})
    hl("NeoTreeGitUntracked", {{ fg = colors.comment }})
    hl("NeoTreeIndentMarker", {{ fg = colors.comment }})
    hl("NeoTreeExpander", {{ fg = colors.comment }})

    -- nvim-cmp (completion)
    hl("CmpItemAbbrMatch", {{ fg = colors.cyan, bold = true }})
    hl("CmpItemAbbrMatchFuzzy", {{ fg = colors.cyan, bold = true }})
    hl("CmpItemKind", {{ fg = colors.orange }})
    hl("CmpItemMenu", {{ fg = colors.comment }})
    hl("CmpItemAbbrDeprecated", {{ fg = colors.comment, strikethrough = true }})
    
    -- nvim-cmp kind-specific highlights (semantic coloring like Zed)
    hl("CmpItemKindText", {{ fg = colors.fg }})
    hl("CmpItemKindMethod", {{ fg = colors.cyan }})
    hl("CmpItemKindFunction", {{ fg = colors.cyan }})
    hl("CmpItemKindConstructor", {{ fg = colors.orange }})
    hl("CmpItemKindField", {{ fg = colors.fg }})
    hl("CmpItemKindVariable", {{ fg = colors.fg }})
    hl("CmpItemKindClass", {{ fg = colors.orange }})
    hl("CmpItemKindInterface", {{ fg = colors.orange }})
    hl("CmpItemKindModule", {{ fg = colors.orange }})
    hl("CmpItemKindProperty", {{ fg = colors.fg }})
    hl("CmpItemKindUnit", {{ fg = colors.orange }})
    hl("CmpItemKindValue", {{ fg = colors.orange }})
    hl("CmpItemKindEnum", {{ fg = colors.orange }})
    hl("CmpItemKindKeyword", {{ fg = colors.red_bright }})
    hl("CmpItemKindSnippet", {{ fg = colors.cyan }})
    hl("CmpItemKindColor", {{ fg = colors.green }})
    hl("CmpItemKindFile", {{ fg = colors.fg }})
    hl("CmpItemKindReference", {{ fg = colors.fg }})
    hl("CmpItemKindFolder", {{ fg = colors.cyan }})
    hl("CmpItemKindEnumMember", {{ fg = colors.orange }})
    hl("CmpItemKindConstant", {{ fg = colors.orange }})
    hl("CmpItemKindStruct", {{ fg = colors.orange }})
    hl("CmpItemKindEvent", {{ fg = colors.orange }})
    hl("CmpItemKindOperator", {{ fg = colors.fg }})
    hl("CmpItemKindTypeParameter", {{ fg = colors.orange }})
    hl("CmpItemKindCopilot", {{ fg = colors.cyan }})
    hl("CmpItemKindCodeium", {{ fg = colors.cyan }})
    hl("CmpItemKindTabNine", {{ fg = colors.cyan }})

    -- Terminal colors
    vim.g.terminal_color_0 = colors.term_black
    vim.g.terminal_color_1 = colors.term_red
    vim.g.terminal_color_2 = colors.term_green
    vim.g.terminal_color_3 = colors.term_yellow
    vim.g.terminal_color_4 = colors.term_blue
    vim.g.terminal_color_5 = colors.term_magenta
    vim.g.terminal_color_6 = colors.term_cyan
    vim.g.terminal_color_7 = colors.term_white
    vim.g.terminal_color_8 = colors.term_bright_black
    vim.g.terminal_color_9 = colors.term_bright_red
    vim.g.terminal_color_10 = colors.term_bright_green
    vim.g.terminal_color_11 = colors.term_bright_yellow
    vim.g.terminal_color_12 = colors.term_bright_blue
    vim.g.terminal_color_13 = colors.term_bright_magenta
    vim.g.terminal_color_14 = colors.term_bright_cyan
    vim.g.terminal_color_15 = colors.term_bright_white
end

return M
"""

        # Write file
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(theme_lua)
        print(f"✓ Generated Neovim theme: {output_path}")

    def generate_ly_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Ly (display manager) theme file."""
        p = palette["palette"]
        appearance = palette["appearance"]
        
        # Generate INI theme content
        theme_ini = f"""# Soft Focus {appearance.title()} Theme for Ly Display Manager
# Auto-generated from central color palette

# Background & text
bg = {p["background"][1:]}
fg = {p["foreground"][1:]}

# Boxes & borders
box = {p["background_elevated"][1:]}
border = {p["border_active"][1:]}
shadow = {p["foreground_dim"][1:]}

# Text roles
input = {p["foreground"][1:]}
prompt = {p["primary"][1:]}
error = {p["error"][1:]}
info = {p["info"][1:]}

# UI elements
high = {p["primary"][1:]}
cursor = {p["primary"][1:]}
button = {p["secondary"][1:]}
"""

        # Write file
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(theme_ini)
        print(f"✓ Generated Ly theme: {output_path}")

    def generate_mako_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Mako (notification daemon) theme file."""
        p = palette["palette"]
        t = p["terminal"]
        appearance = palette["appearance"]
        is_dark = appearance == "dark"
        
        # Generate Mako config content
        theme_config = f"""# Soft Focus {appearance.title()} Theme for Mako
# Auto-generated from central color palette

# Default style
background-color={p["background"]}
text-color={p["foreground"]}
border-color={p["primary"]}
border-size=2
border-radius=8
padding=12
margin=10
font=JetBrainsMono Nerd Font 11

# Icons
icon-location=left
max-icon-size=48

# Progress bar
progress-color=over {p["primary"]}

# Default timeout
default-timeout=5000

# Grouping
group-by=app-name

# Urgency: low
[urgency=low]
background-color={p["background_elevated"]}
text-color={p["foreground_alt"]}
border-color={p["success"]}
default-timeout=3000

# Urgency: normal (uses default colors)
[urgency=normal]
background-color={p["background"]}
text-color={p["foreground"]}
border-color={p["info"]}
default-timeout=5000

# Urgency: critical
[urgency=critical]
background-color={p["error"]}26
text-color={p["foreground"]}
border-color={t["bright_red"]}
default-timeout=0

# App-specific styles
[app-name="Volume"]
border-color={p["warning"]}

[app-name="Brightness"]
border-color={p["warning"]}

[app-name="Network"]
border-color={p["info"]}

[app-name="Battery"]
border-color={p["success"]}
"""

        # Write file
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(theme_config)
        print(f"✓ Generated Mako theme: {output_path}")

    def generate_all_themes(self, theme_name: str):
        """Generate all application themes for a given palette."""
        print(f"\n🎨 Generating themes for: {theme_name}")
        print("=" * 60)

        palette = self.load_palette(theme_name)

        # Terminal emulators
        kitty_output = self.themes_dir / "kitty" / "themes" / f"{theme_name}.conf"
        self.generate_kitty_theme(palette, kitty_output)

        wezterm_output = self.themes_dir / "wezterm" / "colors" / f"{theme_name}.toml"
        self.generate_wezterm_theme(palette, wezterm_output)

        # Terminal multiplexer
        tmux_output = self.themes_dir / "tmux" / "themes" / f"{theme_name}.conf"
        self.generate_tmux_theme(palette, tmux_output)

        # File manager
        yazi_output = self.themes_dir / "yazi" / "themes" / f"{theme_name}.toml"
        self.generate_yazi_theme(palette, yazi_output)

        # System monitor
        btop_output = self.themes_dir / "btop" / "themes" / f"{theme_name}.theme"
        self.generate_btop_theme(palette, btop_output)

        # Window manager and desktop (Linux)
        hyprland_output = self.themes_dir / "hypr" / "themes" / f"{theme_name}.conf"
        self.generate_hyprland_theme(palette, hyprland_output)

        waybar_output = self.themes_dir / "waybar" / "themes" / f"{theme_name}.css"
        self.generate_waybar_theme(palette, waybar_output)

        ly_output = self.themes_dir / "ly" / "themes" / f"{theme_name}.ini"
        self.generate_ly_theme(palette, ly_output)

        mako_output = self.themes_dir / "mako" / "themes" / f"{theme_name}"
        self.generate_mako_theme(palette, mako_output)

        # Application launcher
        rofi_output = self.themes_dir / "rofi" / "themes" / f"{theme_name}.rasi"
        self.generate_rofi_theme(palette, rofi_output)

        # Code editors
        vscode_output = self.themes_dir / "Code" / "User" / "themes" / f"{theme_name}.json"
        self.generate_vscode_settings(palette, vscode_output)

        zed_output = self.themes_dir / "zed" / "themes" / f"{theme_name}.json"
        self.generate_zed_theme(palette, zed_output)

        nvim_output = self.themes_dir / "nvim" / "lua" / "plugins" / "themes" / f"{theme_name}.lua"
        self.generate_nvim_theme(palette, nvim_output)

        # Shell
        zsh_output = self.themes_dir / "zsh" / "themes" / f"{theme_name}.zsh"
        self.generate_zsh_theme(palette, zsh_output)

        # Browser
        firefox_output = self.themes_dir / "firefox" / "chrome"
        self.generate_firefox_theme(palette, firefox_output)

        # Note-taking app
        obsidian_output = self.themes_dir / "obsidian" / "themes" / theme_name
        self.generate_obsidian_theme(palette, obsidian_output)

        print("=" * 60)
        print(f"✨ All themes generated successfully for {theme_name}!\n")


def main():
    """Main entry point for theme generation."""
    # Detect platform for helpful messages
    system = platform.system()
    
    parser = argparse.ArgumentParser(
        description="Generate application-specific theme files from color palettes (Cross-platform: Windows, macOS, Linux)"
    )
    parser.add_argument(
        "theme",
        nargs="?",
        choices=["soft-focus-dark", "soft-focus-light", "all"],
        default="all",
        help="Theme to generate (default: all)",
    )
    parser.add_argument(
        "--chezmoi-root",
        type=Path,
        default=None,
        help="Path to chezmoi source directory (default: auto-detect)",
    )

    args = parser.parse_args()

    if args.chezmoi_root is None:
        home = Path.home()
        
        # Platform-specific chezmoi locations
        if system == "Windows":
            possible_roots = [
                home / "AppData" / "Local" / "chezmoi",
                home / ".local" / "share" / "chezmoi",
                Path.cwd(),
            ]
        else:  # macOS and Linux
            possible_roots = [
                home / ".local" / "share" / "chezmoi",
                home / ".chezmoi",
                Path.cwd(),
            ]

        for root in possible_roots:
            if (root / ".chezmoidata" / "colors").exists():
                args.chezmoi_root = root
                break

        if args.chezmoi_root is None:
            print("❌ Could not auto-detect chezmoi root directory.")
            print("   Please specify --chezmoi-root")
            print(f"\n   Searched in:")
            for root in possible_roots:
                print(f"   - {root}")
            sys.exit(1)

    print(f"🔧 Platform: {system}")
    print(f"📁 Chezmoi root: {args.chezmoi_root}\n")

    generator = ThemeGenerator(args.chezmoi_root)

    try:
        if args.theme == "all":
            generator.generate_all_themes("soft-focus-dark")
            generator.generate_all_themes("soft-focus-light")
        else:
            generator.generate_all_themes(args.theme)

        print("✅ Theme generation complete!")
        print("\n💡 Next steps:")
        if system == "Windows":
            print("   1. Review generated theme files")
            print("   2. Run 'chezmoi apply' to deploy changes")
            print("   3. Use PowerShell theme-switch script to activate themes")
        else:
            print("   1. Review generated theme files")
            print("   2. Run 'chezmoi apply' to deploy changes")
            print("   3. Use theme-switch script to activate themes")
        print()

    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
