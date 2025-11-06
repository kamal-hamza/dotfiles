#!/usr/bin/env python3
"""
Extended Theme Generator for Soft Focus Dotfiles
Generates application-specific theme files from central color palette files.

Author: Hamza Kamal
License: MIT
"""

import json
import os
import sys
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
        transp = palette.get("transparency", {})

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

[colors.ansi]
"{t['black']}"
"{t['red']}"
"{t['green']}"
"{t['yellow']}"
"{t['blue']}"
"{t['magenta']}"
"{t['cyan']}"
"{t['white']}"

[colors.brights]
"{t['bright_black']}"
"{t['bright_red']}"
"{t['bright_green']}"
"{t['bright_yellow']}"
"{t['bright_blue']}"
"{t['bright_magenta']}"
"{t['bright_cyan']}"
"{t['bright_white']}"

[colors.tab_bar]
background = "{overrides.get('tab_bar_background', p['background'])}"

[[colors.tab_bar.active_tab]]
bg_color = "{overrides.get('active_tab_bg', p['background_elevated'])}"
fg_color = "{overrides.get('active_tab_fg', p['foreground'])}"
intensity = "Bold"

[[colors.tab_bar.inactive_tab]]
bg_color = "{overrides.get('inactive_tab_bg', p['background'])}"
fg_color = "{overrides.get('inactive_tab_fg', p['foreground_alt'])}"

[[colors.tab_bar.inactive_tab_hover]]
bg_color = "{overrides.get('new_tab_hover_bg', p['primary'])}"
fg_color = "{overrides.get('new_tab_hover_fg', p['background'])}"
italic = true

[[colors.tab_bar.new_tab]]
bg_color = "{p['background']}"
fg_color = "{p['foreground_alt']}"

[[colors.tab_bar.new_tab_hover]]
bg_color = "{overrides.get('new_tab_hover_bg', p['primary'])}"
fg_color = "{overrides.get('new_tab_hover_fg', p['background'])}"

[metadata]
background_opacity = {transp.get('background_opacity', 0.95)}
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
        transp = palette.get("transparency", {})

        # Convert hex to rgba
        def hex_to_rgba(hex_color: str, alpha: float = 1.0) -> str:
            hex_color = hex_color.lstrip("#")
            r, g, b = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
            return f"rgba({r}, {g}, {b}, {alpha})"

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
    background: {hex_to_rgba(p["background"], transp.get("background_opacity", 0.95))};
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
        transp = palette.get("transparency", {})

        # Convert hex to rgba
        def hex_to_rgba(hex_color: str, alpha_percent: int = 100) -> str:
            return f"{hex_color}{alpha_percent:02x}"

        bg_alpha = int(transp.get("background_opacity", 0.95) * 100)

        content = f"""/* Soft Focus {appearance.title()} Theme for Rofi */
/* Auto-generated from central color palette */

* {{
    background: {hex_to_rgba(p["background"], bg_alpha)};
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

        # Application launcher
        rofi_output = self.themes_dir / "rofi" / "themes" / f"{theme_name}.rasi"
        self.generate_rofi_theme(palette, rofi_output)

        print("=" * 60)
        print(f"✨ All themes generated successfully for {theme_name}!\n")


def main():
    parser = argparse.ArgumentParser(
        description="Generate application-specific theme files from color palettes"
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

    # Auto-detect chezmoi root if not provided
    if args.chezmoi_root is None:
        home = Path.home()
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
            sys.exit(1)

    generator = ThemeGenerator(args.chezmoi_root)

    try:
        if args.theme == "all":
            generator.generate_all_themes("soft-focus-dark")
            generator.generate_all_themes("soft-focus-light")
        else:
            generator.generate_all_themes(args.theme)

        print("✅ Theme generation complete!")
        print("\n💡 Next steps:")
        print("   1. Review generated theme files")
        print("   2. Run 'chezmoi apply' to deploy changes")
        print("   3. Use theme-switch script to activate themes\n")

    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
