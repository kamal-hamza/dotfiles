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
        self.emacs_dir = chezmoi_root / "dot_emacs.d"

    def validate_palette(self, palette: Dict[str, Any], theme_name: str):
        """Validate that palette contains all required base colors."""
        required_base_colors = [
            "red", "green", "yellow", "blue", "cyan", "magenta",
            "bright_red", "bright_green", "bright_yellow",
            "bright_blue", "bright_cyan", "bright_magenta"
        ]

        required_ui_colors = [
            "background", "foreground", "background_alt", "background_elevated",
            "foreground_alt", "foreground_dim", "border"
        ]

        required_terminal_colors = [
            "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
            "bright_black", "bright_red", "bright_green", "bright_yellow",
            "bright_blue", "bright_magenta", "bright_cyan", "bright_white"
        ]

        if "palette" not in palette:
            raise ValueError(f"Theme '{theme_name}' missing 'palette' key")

        p = palette["palette"]
        missing_colors = []

        # Check base colors
        for color in required_base_colors:
            if color not in p:
                missing_colors.append(f"palette.{color}")

        # Check UI colors
        for color in required_ui_colors:
            if color not in p:
                missing_colors.append(f"palette.{color}")

        # Check terminal colors
        if "terminal" not in p:
            raise ValueError(f"Theme '{theme_name}' missing 'palette.terminal' key")

        t = p["terminal"]
        for color in required_terminal_colors:
            if color not in t:
                missing_colors.append(f"palette.terminal.{color}")

        if missing_colors:
            raise ValueError(
                f"Theme '{theme_name}' is missing required base colors:\n  " +
                "\n  ".join(missing_colors) +
                "\n\nPalette files should only contain base colors (red, green, yellow, blue, cyan, magenta, bright_*)" +
                "\nSemantic colors (keyword, function, string, etc.) are derived by the generator."
            )

    def load_palette(self, theme_name: str) -> Dict[str, Any]:
        """Load color palette from JSON or YAML file."""
        # Try JSON first
        palette_file = self.colors_dir / f"{theme_name}.json"
        if palette_file.exists():
            with open(palette_file, "r") as f:
                palette = json.load(f)
                self.validate_palette(palette, theme_name)
                return palette

        # Fall back to YAML if available
        palette_file = self.colors_dir / f"{theme_name}.yaml"
        if palette_file.exists():
            try:
                import yaml
                with open(palette_file, "r") as f:
                    palette = yaml.safe_load(f)
                    self.validate_palette(palette, theme_name)
                    return palette
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

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]
        warning_color = p["yellow"]

        content = f"""# Soft Focus {appearance.title()} Theme for Kitty
# Auto-generated from central color palette

foreground              {p["foreground"]}
background              {p["background"]}
selection_foreground    {p.get("cursor_text", p["background"])}
selection_background    {primary}

cursor                  {p.get("cursor", p["foreground"])}
cursor_text_color       {p.get("cursor_text", p["background"])}

url_color               {secondary}

active_border_color     {primary}
inactive_border_color   {p["border"]}
bell_border_color       {warning_color}

wayland_titlebar_color  {p["background"]}
macos_titlebar_color    {p["background"]}

active_tab_foreground   {overrides.get("active_tab_fg", p["foreground"])}
active_tab_background   {overrides.get("active_tab_bg", p["background_elevated"])}
inactive_tab_foreground {overrides.get("inactive_tab_fg", p["foreground_alt"])}
inactive_tab_background {overrides.get("inactive_tab_bg", p["background"])}
tab_bar_background      {overrides.get("tab_bar_background", p["background"])}

mark1_foreground        {p["background"]}
mark1_background        {secondary}
mark2_foreground        {p["background"]}
mark2_background        {p["red"]}
mark3_foreground        {p["background"]}
mark3_background        {warning_color}

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

        # Derive semantic colors from base palette
        primary = p["blue"]

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
selection_bg = "{primary}"

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
bg_color = "{overrides.get('new_tab_hover_bg', primary)}"
fg_color = "{overrides.get('new_tab_hover_fg', p['background'])}"
italic = true

[colors.tab_bar.new_tab]
bg_color = "{p['background']}"
fg_color = "{p['foreground_alt']}"

[colors.tab_bar.new_tab_hover]
bg_color = "{overrides.get('new_tab_hover_bg', primary)}"
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

        # Derive semantic colors from base palette
        primary = p["blue"]

        content = f"""# Soft Focus {appearance.title()} Theme for tmux
# Auto-generated from central color palette

# Status bar colors
set -g status-style "bg={overrides.get('status_bg', p['background'])},fg={overrides.get('status_fg', p['foreground'])}"

# Window status colors
set -g window-status-style "bg={overrides.get('status_bg', p['background'])},fg={p['foreground_alt']}"
set -g window-status-current-style "bg={overrides.get('window_status_current_bg', p['background_elevated'])},fg={overrides.get('window_status_current_fg', primary)}"
set -g window-status-activity-style "bg={overrides.get('status_bg', p['background'])},fg={p['yellow']}"
set -g window-status-bell-style "bg={overrides.get('status_bg', p['background'])},fg={p['red']}"

# Pane borders
set -g pane-border-style "fg={overrides.get('pane_border', p['border'])}"
set -g pane-active-border-style "fg={overrides.get('pane_active_border', primary)}"

# Messages
set -g message-style "bg={overrides.get('message_bg', p['background_elevated'])},fg={overrides.get('message_fg', primary)},bold"
set -g message-command-style "bg={overrides.get('message_bg', p['background_elevated'])},fg={overrides.get('message_fg', primary)}"

# Copy mode
set -g mode-style "bg={primary},fg={p['background']}"

# Clock
set -g clock-mode-colour "{primary}"
set -g clock-mode-style 24
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated tmux theme: {output_path}")

    def generate_yazi_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Yazi file manager theme (TOML format)."""
        p = palette["palette"]
        appearance = palette["appearance"]
        overrides = palette.get("overrides", {}).get("yazi", {})

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]
        success_color = p["green"]
        warning_color = p["yellow"]
        error_color = p["red"]

        content = f"""# Soft Focus {appearance.title()} Theme for Yazi
# Auto-generated from central color palette

[manager]
cwd = {{ fg = "{primary}", bold = true }}
hovered = {{ fg = "{p["foreground"]}", bg = "{overrides.get('hovered_bg', p['background_elevated'])}" }}
preview_hovered = {{ underline = true }}
find_keyword = {{ fg = "{warning_color}", bold = true }}
find_position = {{ fg = "{secondary}", bg = "reset", bold = true }}
marker_selected = {{ fg = "{success_color}", bg = "{overrides.get('selected_bg', primary)}" }}
marker_copied = {{ fg = "{warning_color}", bg = "{warning_color}" }}
marker_cut = {{ fg = "{error_color}", bg = "{error_color}" }}
tab_active = {{ fg = "{p["foreground"]}", bg = "{p["background_elevated"]}", bold = true }}
tab_inactive = {{ fg = "{p["foreground_alt"]}", bg = "{p["background"]}" }}
tab_width = 1
border_symbol = "│"
border_style = {{ fg = "{overrides.get("border", p["border"])}" }}
syntect_theme = ""

[status]
separator_open = ""
separator_close = ""
separator_style = {{ fg = "{p["border"]}", bg = "{p["background"]}" }}

mode_normal = {{ fg = "{p["background"]}", bg = "{primary}", bold = true }}
mode_select = {{ fg = "{p["background"]}", bg = "{success_color}", bold = true }}
mode_unset = {{ fg = "{p["background"]}", bg = "{warning_color}", bold = true }}

progress_label = {{ fg = "{p["foreground"]}", bold = true }}
progress_normal = {{ fg = "{primary}", bg = "{p["background_elevated"]}" }}
progress_error = {{ fg = "{error_color}", bg = "{p["background_elevated"]}" }}

permissions_t = {{ fg = "{success_color}" }}
permissions_r = {{ fg = "{warning_color}" }}
permissions_w = {{ fg = "{error_color}" }}
permissions_x = {{ fg = "{secondary}" }}
permissions_s = {{ fg = "{p["foreground_dim"]}" }}

[input]
border = {{ fg = "{overrides.get('border_active', primary)}" }}
title = {{ fg = "{primary}" }}
value = {{ fg = "{p["foreground"]}" }}
selected = {{ bg = "{primary}", fg = "{p["background"]}" }}

[select]
border = {{ fg = "{overrides.get('border_active', primary)}" }}
active = {{ fg = "{primary}", bold = true }}
inactive = {{ fg = "{p["foreground_alt"]}" }}

[tasks]
border = {{ fg = "{overrides.get('border_active', primary)}" }}
title = {{ fg = "{primary}" }}
hovered = {{ fg = "{p["foreground"]}", bg = "{p["background_elevated"]}" }}

[which]
cols = 3
mask = {{ bg = "{p["background_elevated"]}" }}
cand = {{ fg = "{primary}" }}
rest = {{ fg = "{p["foreground_dim"]}" }}
desc = {{ fg = "{p["foreground_alt"]}" }}
separator = "  "
separator_style = {{ fg = "{p["border"]}" }}

[help]
on = {{ fg = "{success_color}" }}
run = {{ fg = "{secondary}" }}
desc = {{ fg = "{p["foreground_alt"]}" }}
hovered = {{ bg = "{p["background_elevated"]}", bold = true }}
footer = {{ fg = "{p["foreground_alt"]}", bg = "{p["background"]}" }}

[filetype]
rules = [
  {{ name = "*/", fg = "{primary}", bold = true }},
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
        appearance = palette["appearance"]
        overrides = palette.get("overrides", {}).get("btop", {})

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]
        success_color = p["green"]
        warning_color = p["yellow"]
        error_color = p["red"]

        def to_btop_color(hex_color: str) -> str:
            """Convert hex color to btop format (remove #)."""
            return hex_color.lstrip('#')

        content = f"""# Soft Focus {appearance.title()} Theme for btop
# Auto-generated from central color palette

# Main colors
theme[main_bg]="{to_btop_color(overrides.get('main_bg', p['background']))}"
theme[main_fg]="{to_btop_color(overrides.get('main_fg', p['foreground']))}"
theme[title]="{to_btop_color(overrides.get('title', primary))}"
theme[hi_fg]="{to_btop_color(overrides.get('selected_fg', primary))}"
theme[selected_bg]="{to_btop_color(overrides.get('selected_bg', p['background_elevated']))}"
theme[selected_fg]="{to_btop_color(overrides.get('selected_fg', primary))}"
theme[inactive_fg]="{to_btop_color(overrides.get('inactive_fg', p['foreground_dim']))}"
theme[proc_misc]="{to_btop_color(overrides.get('proc_misc', secondary))}"
theme[cpu_box]="{to_btop_color(overrides.get('cpu_box', primary))}"
theme[cpu_graph_upper]="{to_btop_color(primary)}"
theme[cpu_graph_lower]="{to_btop_color(secondary)}"
theme[mem_box]="{to_btop_color(overrides.get('mem_box', success_color))}"
theme[mem_graph_upper]="{to_btop_color(success_color)}"
theme[mem_graph_lower]="{to_btop_color(p['green'])}"
theme[net_box]="{to_btop_color(overrides.get('net_box', warning_color))}"
theme[net_graph_upper]="{to_btop_color(warning_color)}"
theme[net_graph_lower]="{to_btop_color(p['yellow'])}"
theme[proc_box]="{to_btop_color(overrides.get('proc_box', p['magenta']))}"
theme[graph_text]="{to_btop_color(overrides.get('graph_text', p['foreground']))}"
theme[meter_bg]="{to_btop_color(p['background_alt'])}"
theme[gradient_c0]="{to_btop_color(p['blue'])}"
theme[gradient_c1]="{to_btop_color(secondary)}"
theme[gradient_c2]="{to_btop_color(p['cyan'])}"
theme[gradient_c3]="{to_btop_color(p['green'])}"
theme[gradient_c4]="{to_btop_color(p['yellow'])}"
theme[gradient_c5]="{to_btop_color(p['red'])}"
theme[div_line]="{to_btop_color(p['border'])}"
theme[temp_start]="{to_btop_color(p['green'])}"
theme[temp_mid]="{to_btop_color(p['yellow'])}"
theme[temp_end]="{to_btop_color(p['red'])}"
"""
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(content)
        print(f"✓ Generated btop theme: {output_path}")

    def generate_hyprland_theme(self, palette: Dict[str, Any], output_path: Path):
        """Generate Hyprland window manager theme."""
        p = palette["palette"]
        appearance = palette["appearance"]

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]

        content = f"""# Soft Focus {appearance.title()} Theme for Hyprland
# Auto-generated from central color palette

$background = rgb({p["background"].lstrip("#")})
$foreground = rgb({p["foreground"].lstrip("#")})
$primary = rgb({primary.lstrip("#")})
$secondary = rgb({secondary.lstrip("#")})
$border = rgb({p["border"].lstrip("#")})
$border_active = rgb({primary.lstrip("#")})
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
        """Generate Waybar status bar theme (CSS)."""
        p = palette["palette"]
        appearance = palette["appearance"]

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]
        success_color = p["green"]
        warning_color = p["yellow"]
        error_color = p["red"]

        content = f"""/* Soft Focus {appearance.title()} Theme for Waybar */
/* Auto-generated from central color palette */

* {{
    font-family: "FiraCode Nerd Font", monospace;
    font-size: 13px;
    min-height: 0;
}}

window#waybar {{
    background: {p["background"]};
    color: {p["foreground"]};
    border-bottom: 1px solid {p["border"]};
}}

/* Workspace buttons */
#workspaces button {{
    padding: 0 8px;
    color: {p["foreground_alt"]};
    background: transparent;
    border: none;
    border-radius: 0;
}}

#workspaces button.active {{
    color: {primary};
    background: {p["background_elevated"]};
    border-bottom: 2px solid {primary};
}}

#workspaces button.urgent {{
    color: {error_color};
    background: {p["background_elevated"]};
}}

#workspaces button:hover {{
    background: {p["background_elevated"]};
    color: {secondary};
}}

#clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #mode {{
    padding: 0 10px;
    margin: 0 5px;
}}

/* Module colors */
#clock {{
    color: {p["foreground"]};
}}

#battery {{
    color: {success_color};
}}

#battery.charging {{
    color: {primary};
}}

#battery.warning:not(.charging) {{
    color: {warning_color};
}}

#battery.critical:not(.charging) {{
    color: {error_color};
}}

#cpu {{
    color: {primary};
}}

#memory {{
    color: {secondary};
}}

#network {{
    color: {success_color};
}}

#network.disconnected {{
    color: {error_color};
}}

#pulseaudio {{
    color: {primary};
}}

#pulseaudio.muted {{
    color: {p["foreground_dim"]};
}}

#tray {{
    color: {p["foreground"]};
}}

#custom-notification {{
    color: {warning_color};
}}

#mode {{
    background: {primary};
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

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]
        success_color = p["green"]
        error_color = p["red"]

        content = f"""/* Soft Focus {appearance.title()} Theme for Rofi */
/* Auto-generated from central color palette */

* {{
    background: {p["background"]};
    foreground: {p["foreground"]};
    background-alt: {p["background_elevated"]};
    foreground-alt: {p["foreground_alt"]};
    primary: {primary};
    secondary: {secondary};
    urgent: {error_color};
    active: {success_color};
    border: {p["border"]};
    border-active: {primary};

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
        """Generate VS Code color theme."""
        p = palette["palette"]
        t = p["terminal"]
        appearance = palette["appearance"]

        # Derive semantic colors from base palette
        is_dark = appearance == "dark"
        primary = p["blue"]
        secondary = p["cyan"]
        keyword_color = p["bright_red"] if is_dark else p["red"]
        function_color = p["cyan"]
        string_color = p["bright_green"] if is_dark else p["green"]
        type_color = p["bright_blue"] if is_dark else p["blue"]
        constant_color = p["bright_yellow"] if is_dark else p["yellow"]
        success_color = p["green"]
        warning_color = p["yellow"]
        error_color = p["red"]

        # VS Code uses # prefix for colors
        colors = {
            # Editor colors
            "editor.background": p["background"],
            "editor.foreground": p["foreground"],
            "editorLineNumber.foreground": p["foreground_dim"],
            "editorLineNumber.activeForeground": p["foreground"],
            "editorCursor.foreground": primary,
            "editor.selectionBackground": p["visual"],
            "editor.inactiveSelectionBackground": p["cursor_line"],
            "editor.lineHighlightBackground": p["cursor_line"],
            "editorWhitespace.foreground": p["foreground_dim"],
            "editorIndentGuide.background": p["border"],
            "editorIndentGuide.activeBackground": primary,
            "editorRuler.foreground": p["border"],
            "editorBracketMatch.background": p["visual"],
            "editorBracketMatch.border": primary,
            "editorGutter.background": p["background"],
            "editorGutter.modifiedBackground": warning_color,
            "editorGutter.addedBackground": success_color,
            "editorGutter.deletedBackground": error_color,

            # Inlay hints - use grey/comment color
            "editorInlayHint.foreground": p["foreground_dim"],
            "editorInlayHint.background": p["background"],
            "editorInlayHint.typeForeground": p["foreground_dim"],
            "editorInlayHint.typeBackground": p["background"],
            "editorInlayHint.parameterForeground": p["foreground_dim"],
            "editorInlayHint.parameterBackground": p["background"],

            # Sidebar colors
            "sideBar.background": p["background"],
            "sideBar.foreground": p["foreground_alt"],
            "sideBar.border": p["border"],
            "sideBarTitle.foreground": primary,
            "sideBarSectionHeader.background": p["background_elevated"],
            "sideBarSectionHeader.foreground": p["foreground"],
            "sideBarSectionHeader.border": p["border"],

            # Activity bar
            "activityBar.background": p["background"],
            "activityBar.foreground": primary,
            "activityBar.inactiveForeground": p["foreground_dim"],
            "activityBar.border": p["border"],
            "activityBarBadge.background": primary,
            "activityBarBadge.foreground": p["background"],

            # Status bar
            "statusBar.background": p["background"],
            "statusBar.foreground": p["foreground_alt"],
            "statusBar.border": p["border"],
            "statusBar.debuggingBackground": warning_color,
            "statusBar.debuggingForeground": p["background"],
            "statusBar.noFolderBackground": p["background"],
            "statusBar.noFolderForeground": p["foreground_alt"],

            # Tabs
            "tab.activeBackground": p["background"],
            "tab.activeForeground": p["foreground"],
            "tab.activeBorder": primary,
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
            "panelTitle.activeBorder": primary,
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
            "gitDecoration.modifiedResourceForeground": warning_color,
            "gitDecoration.deletedResourceForeground": error_color,
            "gitDecoration.untrackedResourceForeground": success_color,
            "gitDecoration.ignoredResourceForeground": p["foreground_dim"],
            "gitDecoration.conflictingResourceForeground": error_color,

            # Buttons
            "button.background": primary,
            "button.foreground": p["background"],
            "button.hoverBackground": secondary,

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
            "peekView.border": primary,
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

        # Derive semantic colors from base palette
        is_dark = appearance == "dark"
        primary = p["blue"]
        secondary = p["cyan"]
        keyword_color = p["bright_red"] if is_dark else p["red"]
        string_color = p["bright_green"] if is_dark else p["green"]
        warning_color = p["yellow"]
        success_color = p["green"]

        content = f"""# Soft Focus {appearance.title()} Theme for Zsh Syntax Highlighting
# Auto-generated from central color palette

typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[default]=fg={p["foreground"]}
ZSH_HIGHLIGHT_STYLES[comment]=fg={p["foreground_dim"]},italic
ZSH_HIGHLIGHT_STYLES[command]=fg={primary},bold
ZSH_HIGHLIGHT_STYLES[alias]=fg={primary}
ZSH_HIGHLIGHT_STYLES[builtin]=fg={secondary}
ZSH_HIGHLIGHT_STYLES[function]=fg={secondary}
ZSH_HIGHLIGHT_STYLES[keyword]=fg={keyword_color}
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg={keyword_color}
ZSH_HIGHLIGHT_STYLES[string]=fg={string_color}
ZSH_HIGHLIGHT_STYLES[param]=fg={p["foreground"]}
ZSH_HIGHLIGHT_STYLES[command-substitution]=fg={secondary}
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=fg={secondary}
ZSH_HIGHLIGHT_STYLES[operator]=fg={p["foreground_alt"]}
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg={warning_color},bold
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

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]
        tertiary = p["bright_blue"] if is_dark else p["bright_cyan"]

        # Syntax colors mapped from base palette
        keyword_color = p["bright_red"] if is_dark else p["red"]
        function_color = p["cyan"]
        string_color = p["bright_green"] if is_dark else p["green"]
        type_color = p["bright_blue"] if is_dark else p["blue"]
        constant_color = p["bright_yellow"] if is_dark else p["yellow"]
        success_color = p["green"]
        warning_color = p["yellow"]
        error_color = p["red"]
        info_color = p["cyan"]

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
                            p.get("accent_mint", tertiary),
                            primary,
                            secondary
                        ],
                        "background": p["background"],
                        "border": p["border"],
                        "border.variant": "#00000000",
                        "border.focused": primary,
                        "border.selected": primary,
                        "border.transparent": "transparent",
                        "border.disabled": p["foreground_dim"],
                        "elevated_surface.background": p["background"],
                        "surface.background": p["background"],
                        "element.background": p["background"],
                        "element.hover": p["background_elevated"],
                        "element.active": p["background_elevated"],
                        "element.selected": p["background_elevated"],
                        "element.disabled": p["foreground_dim"],
                        "drop_target.background": secondary,
                        "ghost_element.background": p["background"],
                        "ghost_element.hover": p["background_elevated"],
                        "ghost_element.active": p["background_elevated"],
                        "ghost_element.selected": p["background_elevated"],
                        "ghost_element.disabled": p["foreground_dim"],
                        "text": p["foreground"],
                        "text.muted": p["foreground_alt"],
                        "text.placeholder": p["foreground_dim"],
                        "text.disabled": p["foreground_dim"],
                        "text.accent": secondary,
                        "icon": p["foreground"],
                        "icon.muted": p["foreground_alt"],
                        "icon.disabled": p["foreground_dim"],
                        "icon.placeholder": p["foreground_dim"],
                        "icon.accent": secondary,
                        "status_bar.background": p["background"],
                        "title_bar.background": p["background"],
                        "title_bar.inactive_background": p["background"],
                        "toolbar.background": p["background"],
                        "tab_bar.background": p["background"],
                        "tab.active_background": p["background"],
                        "tab.inactive_background": p["background"],
                        "search.match_background": p["search"],
                        "panel.background": p["background"],
                        "panel.focused_border": primary,
                        "panel.indent_guide": p["indent_guide"],
                        "panel.indent_guide_active": p["indent_guide_active"],
                        "panel.indent_guide_hover": primary,
                        "panel.overlay_background": p["background_alt"],
                        "pane.focused_border": primary,
                        "pane_group.border": p["border"],
                        "scrollbar.thumb.background": p["foreground_dim"],
                        "scrollbar.thumb.hover_background": p["foreground_alt"],
                        "scrollbar.thumb.border": primary,
                        "scrollbar.track.background": p["background"],
                        "scrollbar.track.border": "#00000000",
                        "editor.background": p["background"],
                        "editor.foreground": p["foreground"],
                        "editor.gutter.background": p["background"],
                        "editor.subheader.background": p["background_elevated"],
                        "editor.active_line.background": "transparent",
                        "editor.highlighted_line.background": "transparent",
                        "editor.line_number": p["foreground_dim"],
                        "editor.active_line_number": p["foreground"],
                        "editor.invisible": p["foreground_dim"],
                        "editor.wrap_guide": p["border"],
                        "editor.active_wrap_guide": p["foreground_dim"],
                        "editor.document_highlight.bracket_background": p["visual"],
                        "editor.document_highlight.read_background": p["background_elevated"],
                        "editor.document_highlight.write_background": p["visual"],
                        "editor.indent_guide": p["indent_guide"],
                        "editor.indent_guide_active": p["indent_guide_active"],
                        "virtual_text": p["foreground_dim"],
                        "inlay_hint": p["foreground_dim"],
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
                        "link_text.hover": secondary,
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
                        "predictive": p["foreground_alt"],
                        "predictive.border": p["foreground_dim"],
                        "predictive.background": p["background_elevated"],
                        "renamed": p.get("accent_mint", tertiary),
                        "renamed.border": p.get("accent_mint", tertiary),
                        "renamed.background": f"{p.get('accent_mint', tertiary)}",
                        "success": t["green"],
                        "success.border": t["green"],
                        "success.background": f"{t['green']}",
                        "unreachable": t["red"],
                        "unreachable.border": t["red"],
                        "unreachable.background": f"{t['red']}",
                        "players": [
                            {
                                "cursor": p["foreground"],
                                "selection": f"{primary}",
                                "background": p["background"]
                            }
                        ],
                        "version_control.added": t["green"],
                        "version_control.added_background": f"{t['green']}26",
                        "version_control.deleted": t["red"],
                        "version_control.deleted_background": f"{t['red']}26",
                        "version_control.modified": warning_color,
                        "version_control.modified_background": f"{warning_color}26",
                        "version_control.renamed": p.get("accent_mint", tertiary),
                        "version_control.conflict": t["bright_red"],
                        "version_control.conflict_background": f"{t['bright_red']}26",
                        "version_control.ignored": p["foreground_dim"],
                        "error": t["bright_red"],
                        "error.background": p["background"],
                        "error.border": t["bright_red"],
                        "warning": warning_color,
                        "warning.background": p["background"],
                        "warning.border": warning_color,
                        "hint": p["foreground_dim"],
                        "hint.background": p["background"],
                        "hint.border": p["foreground_dim"],
                        "info": info_color,
                        "info.background": p["background"],
                        "info.border": info_color,
                        "syntax": {
                            "comment": {
                                "color": p["foreground_dim"],
                                "font_style": "italic",
                                "font_weight": None
                            },
                            "keyword": {
                                "color": keyword_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "function": {
                                "color": function_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "string": {
                                "color": string_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "variable": {
                                "color": p["foreground"] if is_dark else "#000000",
                                "font_style": None,
                                "font_weight": None
                            },
                            "type": {
                                "color": type_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "constant": {
                                "color": constant_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "operator": {
                                "color": p["foreground_alt"],
                                "font_style": None,
                                "font_weight": None
                            },
                            "number": {
                                "color": constant_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "boolean": {
                                "color": constant_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "property": {
                                "color": function_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "attribute": {
                                "color": constant_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "tag": {
                                "color": keyword_color,
                                "font_style": None,
                                "font_weight": None
                            },
                            "punctuation": {
                                "color": p["foreground_alt"],
                                "font_style": None,
                                "font_weight": None
                            },
                            "punctuation.bracket": {
                                "color": p["foreground_alt"],
                                "font_style": None,
                                "font_weight": None
                            },
                            "punctuation.delimiter": {
                                "color": p["foreground_alt"],
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

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]
        tertiary = p["bright_blue"] if is_dark else p["bright_cyan"]
        success_color = p["green"]
        warning_color = p["yellow"]
        error_color = p["red"]

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
  --sf-primary: {primary};
  --sf-secondary: {secondary};
  --sf-tertiary: {tertiary};

  /* Semantic colors */
  --sf-success: {success_color};
  --sf-warning: {warning_color};
  --sf-error: {error_color};
  --sf-info: {secondary};

  /* UI elements */
  --sf-border: {p["border"]};
  --sf-border-active: {primary};

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
    --sf-primary: {primary};
    --sf-secondary: {secondary};
    --sf-tertiary: {tertiary};

    /* Semantic colors */
    --sf-success: {success_color};
    --sf-warning: {warning_color};
    --sf-error: {error_color};

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

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]
        tertiary = p["bright_blue"] if is_dark else p["bright_cyan"]
        keyword_color = p["bright_red"] if is_dark else p["red"]
        function_color = p["cyan"]
        string_color = p["bright_green"] if is_dark else p["green"]
        constant_color = p["bright_yellow"] if is_dark else p["yellow"]
        operator_color = p["foreground"]
        comment_color = p["foreground_dim"]
        success_color = p["green"]
        warning_color = p["yellow"]
        error_color = p["red"]

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
  --background-modifier-success: {success_color};
  --background-modifier-error: {error_color};
  --background-modifier-error-hover: {keyword_color};
  --background-modifier-cover: rgba({("5, 5, 5, 0.8" if is_dark else "255, 255, 255, 0.8")});

  /* Text Colors */
  --text-normal: {p["foreground"]};
  --text-muted: {p["foreground_alt"]};
  --text-faint: {p["foreground_dim"]};
  --text-error: {error_color};
  --text-accent: {primary};
  --text-accent-hover: {secondary};
  --text-on-accent: {p["background" if is_dark else "foreground"]};
  --text-selection: {primary}4D;

  /* Interactive Elements */
  --interactive-normal: {p["background_elevated"]};
  --interactive-hover: {p["background_alt"]};
  --interactive-accent: {primary};
  --interactive-accent-hover: {secondary};
  --interactive-success: {success_color};

  /* Scrollbar */
  --scrollbar-active-thumb-bg: {p["foreground_dim" if is_dark else "foreground_alt"]}{"50" if is_dark else "80"};
  --scrollbar-bg: {p["foreground_dim" if is_dark else "foreground_alt"]}{"0D" if is_dark else "20"};
  --scrollbar-thumb-bg: {p["foreground_dim" if is_dark else "foreground_alt"]}{"30" if is_dark else "40"};

  /* Syntax Highlighting */
  --code-normal: {p["foreground"]};
  --code-background: {p["background_elevated"]};
  --code-keyword: {keyword_color};
  --code-function: {function_color};
  --code-string: {string_color};
  --code-number: {constant_color};
  --code-property: {tertiary};
  --code-comment: {comment_color};
  --code-operator: {operator_color};

  /* UI Elements */
  --titlebar-text-color-focused: {p["foreground"]};
  --titlebar-text-color-unfocused: {p["foreground_dim"]};
  --titlebar-background-focused: {p["background"]};
  --titlebar-background-unfocused: {p["background_alt"]};

  /* Borders */
  --border-color: {p["border"]};
  --border-color-hover: {primary};

  /* Tags */
  --tag-background: {p["background_elevated"]};
  --tag-background-hover: {primary};
  --tag-color: {secondary};
  --tag-color-hover: {p["background" if is_dark else "foreground"]};

  /* Links */
  --link-color: {secondary};
  --link-color-hover: {tertiary};
  --link-external-color: {secondary};
  --link-unresolved-color: {p["foreground_dim"]};

  /* Graph View */
  --graph-node: {primary};
  --graph-node-unresolved: {p["foreground_dim"]};
  --graph-node-tag: {success_color};
  --graph-node-attachment: {warning_color};
  --graph-line: {p["border"]};
  --graph-line-highlight: {primary};

  /* Checkboxes */
  --checkbox-color: {primary};
  --checkbox-color-hover: {secondary};
  --checkbox-border-color: {p["border"]};
  --checkbox-border-color-hover: {primary};

  /* Tables */
  --table-border-color: {p["border"]};
  --table-header-background: {p["background_elevated"]};
  --table-header-background-hover: {p["background_alt"]};
  --table-row-even-background: {p["foreground_dim" if is_dark else "foreground_alt"]}{"05" if is_dark else "0D"};
  --table-row-odd-background: transparent;
  --table-row-hover-background: {primary}1A;

  /* Callouts */
  --callout-default: {primary};
  --callout-info: {secondary};
  --callout-todo: {tertiary};
  --callout-important: {warning_color};
  --callout-warning: {warning_color};
  --callout-success: {success_color};
  --callout-question: {secondary};
  --callout-failure: {error_color};
  --callout-error: {error_color};
  --callout-bug: {error_color};
  --callout-example: {p["magenta"]};
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
  background-color: {primary}0D;
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
  background-color: {primary}33;
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

        # Derive semantic colors from base palette
        primary = p["blue"]
        secondary = p["cyan"]
        tertiary = p["bright_blue"] if is_dark else p["bright_cyan"]
        keyword_color = p["bright_red"] if is_dark else p["red"]
        function_color = p["cyan"]
        string_color = p["bright_green"] if is_dark else p["green"]
        type_color = p["bright_blue"] if is_dark else p["blue"]
        constant_color = p["bright_yellow"] if is_dark else p["yellow"]
        success_color = p["green"]
        warning_color = p["yellow"]
        error_color = p["red"]

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
    blue = "{primary}",   -- primary accent
    blue_light = "{secondary}", -- text.accent, function
    green = "{success_color}",  -- string, success
    mint = "{p.get("accent_mint", tertiary)}",   -- tertiary accent

    -- Syntax colors
    red = "{error_color}",       -- base red
    red_bright = "{keyword_color}", -- keyword, error (bright)
    orange = "{constant_color}",    -- type, warning
    orange_bright = "{constant_color}", -- bright yellow
    cyan = "{secondary}",      -- function
    cyan_bright = "{p["bright_cyan"]}", -- bright cyan
    purple = "{p["magenta"]}",    -- magenta
    purple_bright = "{p["bright_magenta"]}", -- bright magenta

    -- UI colors
    border = "{p["border"]}",
    comment = "{p["foreground_dim"]}",
    line_nr = "{p["foreground_dim"]}",
    cursor_line = "{p["cursor_line"]}",
    visual = "{p["visual"]}",
    search = "{p["search"]}",

    -- Git colors
    git_add = "{success_color}",
    git_change = "{warning_color}",
    git_delete = "{error_color}",

    -- Diagnostic colors
    error = "{keyword_color}",
    warn = "{warning_color}",
    info = "{secondary}",
    hint = "{p["foreground_dim"]}",

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
    hl("DiffText", {{ bg = "{warning_color}" }})

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

    -- LSP Inlay Hints (grey virtual text)
    hl("LspInlayHint", {{ fg = colors.comment, bg = colors.bg }})

    -- Diagnostics
    hl("DiagnosticError", {{ fg = colors.error }})
    hl("DiagnosticWarn", {{ fg = colors.warn }})
    hl("DiagnosticInfo", {{ fg = colors.info }})
    hl("DiagnosticHint", {{ fg = colors.hint }})
    hl("DiagnosticVirtualTextError", {{ fg = colors.comment, bg = colors.bg }})
    hl("DiagnosticVirtualTextWarn", {{ fg = colors.comment, bg = colors.bg }})
    hl("DiagnosticVirtualTextInfo", {{ fg = colors.comment, bg = colors.bg }})
    hl("DiagnosticVirtualTextHint", {{ fg = colors.comment, bg = colors.bg }})
    hl("DiagnosticUnderlineError", {{ sp = colors.error, undercurl = true }})
    hl("DiagnosticUnderlineWarn", {{ sp = colors.warn, undercurl = true }})
    hl("DiagnosticUnderlineInfo", {{ sp = colors.info, undercurl = true }})
    hl("DiagnosticUnderlineHint", {{ sp = colors.comment, undercurl = true }})

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
    hl("NotifyTRACEBorder", {{ fg = colors.comment }})
    hl("NotifyERRORIcon", {{ fg = colors.error }})
    hl("NotifyWARNIcon", {{ fg = colors.warn }})
    hl("NotifyINFOIcon", {{ fg = colors.info }})
    hl("NotifyDEBUGIcon", {{ fg = colors.comment }})
    hl("NotifyTRACEIcon", {{ fg = colors.comment }})
    hl("NotifyERRORTitle", {{ fg = colors.error }})
    hl("NotifyWARNTitle", {{ fg = colors.warn }})
    hl("NotifyINFOTitle", {{ fg = colors.info }})
    hl("NotifyDEBUGTitle", {{ fg = colors.comment }})
    hl("NotifyTRACETitle", {{ fg = colors.comment }})

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

    -- Floating windows (generic)
    hl("FloatBorder", {{ fg = colors.border, bg = colors.bg }})
    hl("FloatTitle", {{ fg = colors.blue_light, bg = colors.bg, bold = true }})

    -- coc.nvim (completion)
    hl("CocSearch", {{ fg = colors.cyan }})
    hl("CocMenuSel", {{ bg = colors.cursor_line, fg = colors.fg, bold = true }})
    hl("CocFloating", {{ bg = colors.bg_elevated, fg = colors.fg }})
    hl("CocFloatDividingLine", {{ fg = colors.border }})

    -- Completion menu items
    hl("CocPumMenu", {{ bg = colors.bg_elevated, fg = colors.fg }})
    hl("CocPumSearch", {{ fg = colors.blue_light }})
    hl("CocPumDetail", {{ fg = colors.fg_alt }})
    hl("CocPumShortcut", {{ fg = colors.comment }})
    hl("CocPumVirtualText", {{ fg = colors.comment }})
    hl("CocPumSelected", {{ bg = colors.cursor_line, fg = colors.fg, bold = true }})
    hl("CocPumDeprecated", {{ fg = colors.comment, strikethrough = true }})

    -- Kind icons and labels with semantic coloring
    hl("CocSymbolText", {{ fg = colors.fg }})
    hl("CocSymbolMethod", {{ fg = colors.cyan }})
    hl("CocSymbolFunction", {{ fg = colors.cyan }})
    hl("CocSymbolConstructor", {{ fg = colors.orange }})
    hl("CocSymbolField", {{ fg = colors.fg }})
    hl("CocSymbolVariable", {{ fg = colors.fg }})
    hl("CocSymbolClass", {{ fg = colors.orange }})
    hl("CocSymbolInterface", {{ fg = colors.orange }})
    hl("CocSymbolModule", {{ fg = colors.orange }})
    hl("CocSymbolProperty", {{ fg = colors.fg }})
    hl("CocSymbolUnit", {{ fg = colors.orange }})
    hl("CocSymbolValue", {{ fg = colors.orange }})
    hl("CocSymbolEnum", {{ fg = colors.orange }})
    hl("CocSymbolKeyword", {{ fg = colors.red_bright }})
    hl("CocSymbolSnippet", {{ fg = colors.cyan }})
    hl("CocSymbolColor", {{ fg = colors.green }})
    hl("CocSymbolFile", {{ fg = colors.fg }})
    hl("CocSymbolReference", {{ fg = colors.fg }})
    hl("CocSymbolFolder", {{ fg = colors.cyan }})
    hl("CocSymbolEnumMember", {{ fg = colors.orange }})
    hl("CocSymbolConstant", {{ fg = colors.orange }})
    hl("CocSymbolStruct", {{ fg = colors.orange }})
    hl("CocSymbolEvent", {{ fg = colors.orange }})
    hl("CocSymbolOperator", {{ fg = colors.fg }})
    hl("CocSymbolTypeParameter", {{ fg = colors.orange }})

    -- Diagnostics
    hl("CocErrorSign", {{ fg = colors.red_bright }})
    hl("CocWarningSign", {{ fg = colors.orange }})
    hl("CocInfoSign", {{ fg = colors.blue_light }})
    hl("CocHintSign", {{ fg = colors.comment }})
    hl("CocErrorFloat", {{ fg = colors.red_bright }})
    hl("CocWarningFloat", {{ fg = colors.orange }})
    hl("CocInfoFloat", {{ fg = colors.blue_light }})
    hl("CocHintFloat", {{ fg = colors.comment }})

    -- CoC virtual text (inlay hints - grey)
    hl("CocInlayHint", {{ fg = colors.comment, bg = colors.bg }})
    hl("CocInlayHintType", {{ fg = colors.comment, bg = colors.bg }})
    hl("CocInlayHintParameter", {{ fg = colors.comment, bg = colors.bg }})

    -- Highlight references
    hl("CocHighlightText", {{ bg = colors.select }})
    hl("CocHighlightRead", {{ bg = colors.select }})
    hl("CocHighlightWrite", {{ bg = colors.select }})

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
        """Generate Ly display manager theme."""
        p = palette["palette"]
        appearance = palette["appearance"]

        # Derive semantic colors from base palette
        primary = p["blue"]
        error_color = p["red"]
        info_color = p["cyan"]

        # Generate INI theme content
        theme_ini = f"""# Soft Focus {appearance.title()} Theme for Ly Display Manager
# Auto-generated from central color palette

# Background & text
bg = {p["background"][1:]}
fg = {p["foreground"][1:]}

# Boxes & borders
box = {p["background_elevated"][1:]}
border = {primary[1:]}
shadow = {p["foreground_dim"][1:]}

# Text roles
input = {p["foreground"][1:]}
prompt = {primary[1:]}
error = {error_color[1:]}
info = {info_color[1:]}

# UI elements
high = {primary[1:]}
cursor = {primary[1:]}
button = {info_color[1:]}
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

        # Derive semantic colors from base palette
        primary = p["blue"]
        success_color = p["green"]
        warning_color = p["yellow"]
        error_color = p["red"]

        # Generate Mako config content
        theme_config = f"""# Soft Focus {appearance.title()} Theme for Mako
# Auto-generated from central color palette

# Default style
background-color={p["background"]}
text-color={p["foreground"]}
border-color={primary}
border-size=2
border-radius=8
padding=12
margin=10
font=JetBrainsMono Nerd Font 11

# Icons
icon-location=left
max-icon-size=48

# Progress bar
progress-color=over {primary}

# Default timeout
default-timeout=5000

# Grouping
group-by=app-name

# Urgency: low
[urgency=low]
background-color={p["background_elevated"]}
text-color={p["foreground_alt"]}
border-color={success_color}
default-timeout=3000

# Urgency: normal (uses default colors)
[urgency=normal]
background-color={p["background"]}
text-color={p["foreground"]}
border-color={primary}
default-timeout=5000

# Urgency: critical
[urgency=critical]
background-color={error_color}26
text-color={p["foreground"]}
border-color={error_color}
default-timeout=0

# App-specific styles
[app-name="Volume"]
border-color={warning_color}

[app-name="Brightness"]
border-color={warning_color}

[app-name="Network"]
border-color={primary}

[app-name="Battery"]
border-color={success_color}
"""

        # Write file
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(theme_config)
        print(f"✓ Generated Mako theme: {output_path}")

    def generate_emacs_theme(self, palette: Dict[str, Any], output_path: Path):
            """Generate Emacs theme."""
            p = palette["palette"]
            t = p["terminal"]
            appearance = palette["appearance"]
            theme_name = f"soft-focus-{appearance}"
            is_dark = appearance == "dark"

            # Derive semantic colors from base palette
            primary = p["blue"]
            secondary = p["cyan"]
            tertiary = p["bright_blue"] if is_dark else p["bright_cyan"]
            mint = p.get("accent_mint", tertiary)

            # Syntax colors mapped from base palette
            keyword_color = p["bright_red"] if is_dark else p["red"]
            function_color = p["cyan"]
            string_color = p["bright_green"] if is_dark else p["green"]
            type_color = p["bright_blue"] if is_dark else p["blue"]
            constant_color = p["bright_yellow"] if is_dark else p["yellow"]
            success_color = p["green"]
            warning_color = p["yellow"]
            error_color = p["red"]
            info_color = p["cyan"]

            content = f"""(deftheme {theme_name}
      "Soft Focus {appearance.title()} Theme for Emacs.
       Auto-generated from central color palette.")

    (let ((class '((class color) (min-colors 89)))
          ;; Palette Variables
          (bg      "{p["background"]}")
          (bg-alt  "{p["background_alt"]}")
          (bg-hl   "{p["background_elevated"]}")
          (fg      "{p["foreground"]}")
          (fg-alt  "{p["foreground_alt"]}")
          (fg-dim  "{p["foreground_dim"]}")
          (primary "{primary}")
          (second  "{secondary}")
          (third   "{tertiary}")
          (mint    "{mint}")

          ;; Semantic
          (success "{success_color}")
          (warning "{warning_color}")
          (err     "{error_color}")
          (info    "{info_color}")

          ;; UI Elements
          (cursor  "{p.get("cursor", primary)}")
          (region  "{p["visual"]}")
          (ln-bg   "{p["cursor_line"]}")
          (border  "{p["border"]}")
          (border-active "{primary}")
          (search  "{p["search"]}")

           ;; Syntax (derived from base palette colors)
          (comment "{p["foreground_dim"]}")
          (keyword "{keyword_color}")
          (func    "{function_color}")
          (string  "{string_color}")
          (type    "{type_color}")
          (const   "{constant_color}")
          (var     "{p["foreground"] if is_dark else "#000000"}")
          (operator "{p["foreground_alt"]}")
          (property "{function_color}")
          (attribute "{constant_color}")
          (tag "{keyword_color}")
          (punctuation "{p["foreground_alt"]}")

          ;; Diff
          (diff-add-bg "{p["diff_add_bg"]}")
          (diff-add-fg "{success_color}")
          (diff-chg-bg "{p["diff_change_bg"]}")
          (diff-chg-fg "{warning_color}")
          (diff-del-bg "{p["diff_delete_bg"]}")
          (diff-del-fg "{error_color}")

          ;; Terminal Colors
          (ansi-black   "{t["black"]}")
          (ansi-red     "{t["red"]}")
          (ansi-green   "{t["green"]}")
          (ansi-yellow  "{t["yellow"]}")
          (ansi-blue    "{t["blue"]}")
          (ansi-magenta "{t["magenta"]}")
          (ansi-cyan    "{t["cyan"]}")
          (ansi-white   "{t["white"]}")
          (ansi-br-black   "{t["bright_black"]}")
          (ansi-br-red     "{t["bright_red"]}")
          (ansi-br-green   "{t["bright_green"]}")
          (ansi-br-yellow  "{t["bright_yellow"]}")
          (ansi-br-blue    "{t["bright_blue"]}")
          (ansi-br-magenta "{t["bright_magenta"]}")
          (ansi-br-cyan    "{t["bright_cyan"]}")
          (ansi-br-white   "{t["bright_white"]}"))

      (custom-theme-set-faces
       '{theme_name}

       ;; --- Core UI ---
       `(default ((,class (:foreground ,fg :background ,bg))))
       `(cursor ((,class (:background ,cursor))))
       `(region ((,class (:background ,region :extend t))))
       `(highlight ((,class (:background ,ln-bg :foreground ,fg))))
       `(hl-line ((,class (:background ,ln-bg :extend t))))
       `(fringe ((,class (:background ,bg :foreground ,fg-dim))))
       `(vertical-border ((,class (:foreground ,border))))
       `(window-divider ((,class (:foreground ,border))))
       `(window-divider-first-pixel ((,class (:foreground ,border))))
       `(window-divider-last-pixel ((,class (:foreground ,border))))
       `(minibuffer-prompt ((,class (:foreground ,primary :weight bold))))
       `(link ((,class (:foreground ,second :underline t))))
       `(link-visited ((,class (:foreground ,third :underline t))))
       `(error ((,class (:foreground ,err :weight bold))))
       `(warning ((,class (:foreground ,warning :weight bold))))
       `(success ((,class (:foreground ,success :weight bold))))
       `(shadow ((,class (:foreground ,fg-dim))))

       ;; --- Mode Line ---
       `(mode-line ((,class (:background ,bg-hl :foreground ,fg :box (:line-width 1 :color ,border)))))
       `(mode-line-inactive ((,class (:background ,bg :foreground ,fg-alt :box (:line-width 1 :color ,border)))))
       `(mode-line-buffer-id ((,class (:weight bold :foreground ,primary))))
       `(mode-line-emphasis ((,class (:weight bold :foreground ,second))))
       `(header-line ((,class (:inherit mode-line-inactive))))

       ;; --- Font Lock (Syntax Highlighting) ---
       `(font-lock-builtin-face ((,class (:foreground ,func))))
       `(font-lock-comment-face ((,class (:foreground ,comment :slant italic))))
       `(font-lock-comment-delimiter-face ((,class (:foreground ,comment))))
       `(font-lock-constant-face ((,class (:foreground ,const))))
       `(font-lock-doc-face ((,class (:foreground ,comment :slant italic))))
       `(font-lock-function-name-face ((,class (:foreground ,func))))
       `(font-lock-keyword-face ((,class (:foreground ,keyword))))
       `(font-lock-negation-char-face ((,class (:foreground ,operator))))
       `(font-lock-preprocessor-face ((,class (:foreground ,keyword))))
       `(font-lock-string-face ((,class (:foreground ,string))))
       `(font-lock-type-face ((,class (:foreground ,type))))
       `(font-lock-variable-name-face ((,class (:foreground ,var))))
       `(font-lock-warning-face ((,class (:foreground ,warning :weight bold))))
       `(font-lock-regexp-grouping-backslash ((,class (:foreground ,const))))
       `(font-lock-regexp-grouping-construct ((,class (:foreground ,const))))
       `(font-lock-operator-face ((,class (:foreground ,operator))))
       `(font-lock-property-face ((,class (:foreground ,property))))
       `(font-lock-punctuation-face ((,class (:foreground ,punctuation))))
       `(font-lock-bracket-face ((,class (:foreground ,punctuation))))
       `(font-lock-delimiter-face ((,class (:foreground ,punctuation))))

       ;; --- Line Numbers ---
       `(line-number ((,class (:foreground ,fg-dim :background ,bg))))
       `(line-number-current-line ((,class (:foreground ,primary :background ,ln-bg :weight bold))))

       ;; --- Search ---
       `(isearch ((,class (:background ,search :foreground ,fg :weight bold))))
       `(isearch-fail ((,class (:background ,err :foreground ,bg))))
       `(lazy-highlight ((,class (:background ,region :foreground ,fg))))
       `(match ((,class (:background ,search :foreground ,fg))))

       ;; --- Parens / Smartparens ---
       `(show-paren-match ((,class (:background ,region :weight bold))))
       `(show-paren-mismatch ((,class (:background ,err :foreground ,bg :weight bold))))
       `(sp-show-pair-match-face ((,class (:background ,region))))

       ;; --- Org Mode ---
       `(org-level-1 ((,class (:foreground ,primary :weight bold :height 1.3))))
       `(org-level-2 ((,class (:foreground ,second :weight bold :height 1.15))))
       `(org-level-3 ((,class (:foreground ,mint :weight bold :height 1.05))))
       `(org-level-4 ((,class (:foreground ,ansi-blue :weight bold))))
       `(org-level-5 ((,class (:foreground ,ansi-magenta :weight bold))))
       `(org-level-6 ((,class (:foreground ,ansi-cyan :weight bold))))
       `(org-level-7 ((,class (:foreground ,ansi-green :weight bold))))
       `(org-level-8 ((,class (:foreground ,ansi-yellow :weight bold))))
       `(org-date ((,class (:foreground ,second :underline t))))
       `(org-footnote ((,class (:foreground ,third :underline t))))
       `(org-link ((,class (:foreground ,second :underline t))))
       `(org-special-keyword ((,class (:foreground ,fg-alt))))
       `(org-block ((,class (:background ,bg-alt :extend t))))
       `(org-block-begin-line ((,class (:foreground ,fg-dim :background ,bg-alt :extend t))))
       `(org-block-end-line ((,class (:foreground ,fg-dim :background ,bg-alt :extend t))))
       `(org-quote ((,class (:inherit org-block :slant italic))))
       `(org-code ((,class (:foreground ,success :background ,bg-alt))))
       `(org-verbatim ((,class (:foreground ,success :background ,bg-alt))))
       `(org-table ((,class (:foreground ,fg))))
       `(org-formula ((,class (:foreground ,const))))
       `(org-checkbox ((,class (:foreground ,primary :weight bold))))
       `(org-todo ((,class (:foreground ,warning :weight bold))))
       `(org-done ((,class (:foreground ,success :weight bold))))
       `(org-tag ((,class (:foreground ,fg-alt :weight bold))))
       `(org-priority ((,class (:foreground ,warning))))
       `(org-document-title ((,class (:foreground ,primary :weight bold :height 1.5))))
       `(org-document-info ((,class (:foreground ,fg-alt))))
       `(org-meta-line ((,class (:foreground ,fg-dim))))

       ;; --- Markdown ---
       `(markdown-header-face-1 ((,class (:inherit org-level-1))))
       `(markdown-header-face-2 ((,class (:inherit org-level-2))))
       `(markdown-header-face-3 ((,class (:inherit org-level-3))))
       `(markdown-code-face ((,class (:inherit org-code))))
       `(markdown-markup-face ((,class (:foreground ,fg-dim))))
       `(markdown-url-face ((,class (:foreground ,second))))

       ;; --- Tree Sitter ---
       `(tree-sitter-hl-face:attribute ((,class (:foreground ,attribute))))
       `(tree-sitter-hl-face:method.call ((,class (:foreground ,func))))
       `(tree-sitter-hl-face:function.call ((,class (:foreground ,func))))
       `(tree-sitter-hl-face:operator ((,class (:foreground ,operator))))
       `(tree-sitter-hl-face:type.builtin ((,class (:foreground ,type))))
       `(tree-sitter-hl-face:number ((,class (:foreground ,const))))
       `(tree-sitter-hl-face:property ((,class (:foreground ,property))))
       `(tree-sitter-hl-face:punctuation ((,class (:foreground ,punctuation))))
       `(tree-sitter-hl-face:punctuation.bracket ((,class (:foreground ,punctuation))))
       `(tree-sitter-hl-face:punctuation.delimiter ((,class (:foreground ,punctuation))))
       `(tree-sitter-hl-face:constructor ((,class (:foreground ,type))))
       `(tree-sitter-hl-face:keyword ((,class (:foreground ,keyword))))
       `(tree-sitter-hl-face:string ((,class (:foreground ,string))))
       `(tree-sitter-hl-face:tag ((,class (:foreground ,tag))))
       `(tree-sitter-hl-face:variable ((,class (:foreground ,var))))
       `(tree-sitter-hl-face:constant ((,class (:foreground ,const))))
       `(tree-sitter-hl-face:type ((,class (:foreground ,type))))

       ;; --- LSP Mode / Flycheck ---
       `(lsp-face-highlight-textual ((,class (:background ,region))))
       `(lsp-face-highlight-read ((,class (:background ,region))))
       `(lsp-face-highlight-write ((,class (:background ,region))))
       `(flycheck-error ((,class (:underline (:style wave :color ,err)))))
       `(flycheck-warning ((,class (:underline (:style wave :color ,warning)))))
       `(flycheck-info ((,class (:underline (:style wave :color ,info)))))
       `(flymake-error ((,class (:underline (:style wave :color ,err)))))
       `(flymake-warning ((,class (:underline (:style wave :color ,warning)))))
       `(flymake-note ((,class (:underline (:style wave :color ,info)))))

       ;; --- Magit ---
       `(magit-section-heading ((,class (:foreground ,primary :weight bold))))
       `(magit-branch-local ((,class (:foreground ,success))))
       `(magit-branch-remote ((,class (:foreground ,second))))
       `(magit-tag ((,class (:foreground ,third))))
       `(magit-hash ((,class (:foreground ,fg-dim))))
       `(magit-diff-added ((,class (:background ,diff-add-bg :foreground ,diff-add-fg))))
       `(magit-diff-added-highlight ((,class (:background ,diff-add-bg :foreground ,diff-add-fg :weight bold))))
       `(magit-diff-removed ((,class (:background ,diff-del-bg :foreground ,diff-del-fg))))
       `(magit-diff-removed-highlight ((,class (:background ,diff-del-bg :foreground ,diff-del-fg :weight bold))))
       `(magit-diff-context ((,class (:foreground ,fg-dim))))
       `(magit-diff-context-highlight ((,class (:background ,bg-hl :foreground ,fg))))
       `(magit-diff-hunk-heading ((,class (:background ,bg-hl :foreground ,fg))))
       `(magit-diff-hunk-heading-highlight ((,class (:background ,ln-bg :foreground ,fg :weight bold))))
       `(magit-process-ok ((,class (:foreground ,success :weight bold))))
       `(magit-process-ng ((,class (:foreground ,err :weight bold))))

       ;; --- Git Gutter / Diff-HL ---
       `(git-gutter:added ((,class (:foreground ,success))))
       `(git-gutter:deleted ((,class (:foreground ,err))))
       `(git-gutter:modified ((,class (:foreground ,warning))))
       `(diff-hl-insert ((,class (:foreground ,success :background ,diff-add-bg))))
       `(diff-hl-delete ((,class (:foreground ,err :background ,diff-del-bg))))
       `(diff-hl-change ((,class (:foreground ,warning :background ,diff-chg-bg))))

       ;; --- Vertico / Selectrum / Ivy ---
       `(vertico-current ((,class (:background ,ln-bg :weight bold))))
       `(vertico-group-title ((,class (:foreground ,fg-alt :weight bold))))
       `(vertico-group-separator ((,class (:foreground ,border))))
       `(ivy-current-match ((,class (:background ,ln-bg :weight bold))))
       `(ivy-minibuffer-match-face-1 ((,class (:foreground ,fg-dim))))
       `(ivy-minibuffer-match-face-2 ((,class (:foreground ,success :weight bold))))
       `(ivy-minibuffer-match-face-3 ((,class (:foreground ,warning :weight bold))))
       `(ivy-minibuffer-match-face-4 ((,class (:foreground ,err :weight bold))))

       ;; --- Company (Completion) ---
       `(company-tooltip ((,class (:background ,bg-hl :foreground ,fg))))
       `(company-tooltip-selection ((,class (:background ,primary :foreground ,bg))))
       `(company-tooltip-annotation ((,class (:foreground ,fg-alt))))
       `(company-tooltip-common ((,class (:foreground ,second :weight bold))))
       `(company-scrollbar-bg ((,class (:background ,bg-alt))))
       `(company-scrollbar-fg ((,class (:background ,fg-dim))))
       `(company-preview ((,class (:foreground ,fg-dim))))
       `(company-preview-common ((,class (:foreground ,fg-dim))))

       ;; --- Corfu ---
       `(corfu-default ((,class (:background ,bg-hl :foreground ,fg))))
       `(corfu-current ((,class (:background ,primary :foreground ,bg))))
       `(corfu-bar ((,class (:background ,fg-dim))))
       `(corfu-border ((,class (:background ,border))))

       ;; --- Rainbow Delimiters ---
       `(rainbow-delimiters-depth-1-face ((,class (:foreground ,primary))))
       `(rainbow-delimiters-depth-2-face ((,class (:foreground ,second))))
       `(rainbow-delimiters-depth-3-face ((,class (:foreground ,third))))
       `(rainbow-delimiters-depth-4-face ((,class (:foreground ,success))))
       `(rainbow-delimiters-depth-5-face ((,class (:foreground ,warning))))
       `(rainbow-delimiters-depth-6-face ((,class (:foreground ,info))))
       `(rainbow-delimiters-depth-7-face ((,class (:foreground ,fg-alt))))
       `(rainbow-delimiters-depth-8-face ((,class (:foreground ,fg-dim))))
       `(rainbow-delimiters-unmatched-face ((,class (:foreground ,err :weight bold))))

       ;; --- NeoTree / Treemacs ---
       `(neo-root-dir-face ((,class (:foreground ,primary :weight bold))))
       `(neo-file-link-face ((,class (:foreground ,fg))))
       `(neo-dir-link-face ((,class (:foreground ,second))))
       `(treemacs-root-face ((,class (:foreground ,primary :weight bold :height 1.2))))
       `(treemacs-file-face ((,class (:foreground ,fg))))
       `(treemacs-directory-face ((,class (:foreground ,second))))
       `(treemacs-git-modified-face ((,class (:foreground ,warning))))
       `(treemacs-git-added-face ((,class (:foreground ,success))))
       `(treemacs-git-untracked-face ((,class (:foreground ,success))))
       `(treemacs-git-conflict-face ((,class (:foreground ,err :weight bold))))

       ;; --- Terminal (vterm) ---
       `(vterm-color-default ((,class (:foreground ,fg :background ,bg))))
       `(vterm-color-black ((,class (:foreground ,ansi-black :background ,ansi-black))))
       `(vterm-color-red ((,class (:foreground ,ansi-red :background ,ansi-red))))
       `(vterm-color-green ((,class (:foreground ,ansi-green :background ,ansi-green))))
       `(vterm-color-yellow ((,class (:foreground ,ansi-yellow :background ,ansi-yellow))))
       `(vterm-color-blue ((,class (:foreground ,ansi-blue :background ,ansi-blue))))
       `(vterm-color-magenta ((,class (:foreground ,ansi-magenta :background ,ansi-magenta))))
       `(vterm-color-cyan ((,class (:foreground ,ansi-cyan :background ,ansi-cyan))))
       `(vterm-color-white ((,class (:foreground ,ansi-white :background ,ansi-white))))

       ;; --- Web Mode ---
       `(web-mode-html-tag-face ((,class (:foreground ,primary))))
       `(web-mode-html-attr-name-face ((,class (:foreground ,second))))
       `(web-mode-html-attr-value-face ((,class (:foreground ,string))))
       `(web-mode-doctype-face ((,class (:foreground ,fg-dim))))
       `(web-mode-keyword-face ((,class (:foreground ,keyword))))
       `(web-mode-function-name-face ((,class (:foreground ,func))))

       ;; --- Dired ---
       `(dired-directory ((,class (:foreground ,second :weight bold))))
       `(dired-symlink ((,class (:foreground ,third :slant italic))))
       `(dired-ignored ((,class (:foreground ,fg-dim))))
       `(dired-header ((,class (:foreground ,primary :weight bold))))
      ))

    ;;;###autoload
    (and load-file-name
        (boundp 'custom-theme-load-path)
        (add-to-list 'custom-theme-load-path
                     (file-name-as-directory
                      (file-name-directory load-file-name))))

    (provide-theme '{theme_name})

    ;;; {theme_name}-theme.el ends here
    """
            output_path.parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, "w") as f:
                f.write(content)
            print(f"✓ Generated Emacs theme: {output_path}")

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

        # Emacs
        emacs_output = self.emacs_dir / "themes" / f"{theme_name}-theme.el"
        self.generate_emacs_theme(palette, emacs_output)

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
        "--root",
        type=Path,
        default=None,
        help="Path to project root directory (default: current directory)",
    )

    args = parser.parse_args()

    # Use current directory as default root
    if args.root is None:
        args.root = Path.cwd()

    # Verify the directory structure exists
    if not (args.root / ".chezmoidata" / "colors").exists():
        print(f"❌ Could not find .chezmoidata/colors in: {args.root}")
        print("   Make sure you're running this from the project root directory")
        sys.exit(1)

    print(f"🔧 Platform: {system}")
    print(f"📁 Project root: {args.root}\n")

    args.chezmoi_root = args.root

    generator = ThemeGenerator(args.chezmoi_root)

    try:
        if args.theme == "all":
            generator.generate_all_themes("soft-focus-dark")
            generator.generate_all_themes("soft-focus-light")
        else:
            generator.generate_all_themes(args.theme)

        print("✅ Theme generation complete!")
        print("\n💡 Next steps:")
        print("   1. Review generated theme files in dot_config/")
        print("   2. Commit changes to git if desired")
        print()

    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
