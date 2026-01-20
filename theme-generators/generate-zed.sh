#!/usr/bin/env bash

# =============================================================================
# Zed Theme Generator
# =============================================================================
# Generates Zed theme JSON from central color palette
# =============================================================================

set -e

MODE="${1:-all}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_FILE="$SCRIPT_DIR/../.chezmoidata/themes/colors.sh"
OUTPUT_DIR="$HOME/.config/zed/themes"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Source color definitions
if [[ ! -f "$COLORS_FILE" ]]; then
    echo "Error: Colors file not found: $COLORS_FILE" >&2
    exit 1
fi

generate_zed_theme() {
    local theme_name="$1"
    local output_file="$OUTPUT_DIR/soft-focus-${theme_name}.json"
    
    # Load colors for this theme
    source "$COLORS_FILE"
    get_colors "$theme_name"
    
    # Determine appearance
    local appearance="dark"
    if [[ "$theme_name" == "light" ]]; then
        appearance="light"
    fi
    
    # Generate Zed theme JSON
    cat > "$output_file" << EOF
{
    "\$schema": "https://zed.dev/schema/themes/v0.2.0.json",
    "name": "Soft Focus",
    "author": "Hamza Kamal",
    "themes": [
        {
            "name": "Soft Focus ${theme_name^}",
            "appearance": "$appearance",
            "style": {
                "accents": [
                    "$ACCENT",
                    "$ANSI_BLUE",
                    "$ANSI_CYAN"
                ],
                "background": "$BG",
                "border": "$BORDER",
                "border.variant": "#00000000",
                "border.focused": "$BORDER_FOCUSED",
                "border.selected": "$BORDER_FOCUSED",
                "border.transparent": "transparent",
                "border.disabled": "$COMMENT",
                "elevated_surface.background": "$BG",
                "surface.background": "$BG",
                "element.background": "$BG",
                "element.hover": "${BORDER}40",
                "element.active": "${BORDER}60",
                "element.selected": "${BORDER}80",
                "element.disabled": "$COMMENT",
                "drop_target.background": "$ACCENT",
                "ghost_element.background": "$BG",
                "ghost_element.hover": "${BORDER}40",
                "ghost_element.active": "${BORDER}60",
                "ghost_element.selected": "${BORDER}80",
                "ghost_element.disabled": "$COMMENT",
                "text": "$FG",
                "text.muted": "$MUTED",
                "text.placeholder": "$COMMENT",
                "text.disabled": "$COMMENT",
                "text.accent": "$ACCENT",
                "icon": "$FG",
                "icon.muted": "$MUTED",
                "icon.disabled": "$COMMENT",
                "icon.placeholder": "$COMMENT",
                "icon.accent": "$ACCENT",
                "status_bar.background": "$BG",
                "title_bar.background": "$BG",
                "title_bar.inactive_background": "$BG",
                "toolbar.background": "$BG",
                "tab_bar.background": "$BG",
                "tab.active_background": "$BG",
                "tab.inactive_background": "$BG",
                "search.match_background": "${SELECTION}40",
                "panel.background": "$BG",
                "panel.focused_border": "$BORDER_FOCUSED",
                "panel.indent_guide": "$BORDER",
                "panel.indent_guide_active": "$MUTED",
                "panel.indent_guide_hover": "$BORDER_FOCUSED",
                "panel.overlay_background": "${BG}f0",
                "pane.focused_border": "$BORDER_FOCUSED",
                "pane_group.border": "$BORDER",
                "scrollbar.thumb.background": "$COMMENT",
                "scrollbar.thumb.hover_background": "$MUTED",
                "scrollbar.thumb.border": "$BORDER_FOCUSED",
                "scrollbar.track.background": "$BG",
                "scrollbar.track.border": "#00000000",
                "editor.background": "$BG",
                "editor.foreground": "$FG",
                "editor.gutter.background": "$BG",
                "editor.subheader.background": "${BORDER}40",
                "editor.active_line.background": "transparent",
                "editor.highlighted_line.background": "transparent",
                "editor.line_number": "$COMMENT",
                "editor.active_line_number": "$FG",
                "editor.invisible": "$COMMENT",
                "editor.wrap_guide": "$BORDER",
                "editor.active_wrap_guide": "$COMMENT",
                "editor.document_highlight.bracket_background": "${BORDER}60",
                "editor.document_highlight.read_background": "${BORDER}40",
                "editor.document_highlight.write_background": "${BORDER}60",
                "editor.indent_guide": "$BORDER",
                "editor.indent_guide_active": "$MUTED",
                "virtual_text": "$COMMENT",
                "inlay_hint": "$COMMENT",
                "terminal.background": "$BG",
                "terminal.ansi.background": "$BG",
                "terminal.foreground": "$FG",
                "terminal.dim_foreground": "$MUTED",
                "terminal.bright_foreground": "$FG",
                "terminal.ansi.black": "$ANSI_BLACK",
                "terminal.ansi.red": "$ANSI_RED",
                "terminal.ansi.green": "$ANSI_GREEN",
                "terminal.ansi.yellow": "$ANSI_YELLOW",
                "terminal.ansi.blue": "$ANSI_BLUE",
                "terminal.ansi.magenta": "$ANSI_MAGENTA",
                "terminal.ansi.cyan": "$ANSI_CYAN",
                "terminal.ansi.white": "$ANSI_WHITE",
                "terminal.ansi.bright_black": "$ANSI_BRIGHT_BLACK",
                "terminal.ansi.bright_red": "$ANSI_BRIGHT_RED",
                "terminal.ansi.bright_green": "$ANSI_BRIGHT_GREEN",
                "terminal.ansi.bright_yellow": "$ANSI_BRIGHT_YELLOW",
                "terminal.ansi.bright_blue": "$ANSI_BRIGHT_BLUE",
                "terminal.ansi.bright_magenta": "$ANSI_BRIGHT_MAGENTA",
                "terminal.ansi.bright_cyan": "$ANSI_BRIGHT_CYAN",
                "terminal.ansi.bright_white": "$ANSI_BRIGHT_WHITE",
                "terminal.ansi.dim_black": "$ANSI_BRIGHT_BLACK",
                "terminal.ansi.dim_red": "$ANSI_RED",
                "terminal.ansi.dim_green": "$ANSI_GREEN",
                "terminal.ansi.dim_yellow": "$ANSI_YELLOW",
                "terminal.ansi.dim_blue": "$ANSI_BLUE",
                "terminal.ansi.dim_magenta": "$ANSI_MAGENTA",
                "terminal.ansi.dim_cyan": "$ANSI_CYAN",
                "terminal.ansi.dim_white": "$ANSI_BRIGHT_BLACK",
                "link_text.hover": "$ACCENT",
                "conflict": "$ERROR",
                "conflict.border": "$ERROR",
                "conflict.background": "${ERROR}26",
                "created": "$GIT_ADDED",
                "created.border": "$GIT_ADDED",
                "created.background": "${GIT_ADDED}26",
                "deleted": "$GIT_DELETED",
                "deleted.border": "$GIT_DELETED",
                "deleted.background": "${GIT_DELETED}26",
                "hidden": "$COMMENT",
                "hidden.border": "$COMMENT",
                "hidden.background": "${BG}f0",
                "ignored": "$COMMENT",
                "ignored.border": "$COMMENT",
                "ignored.background": "${BG}f0",
                "modified": "$GIT_MODIFIED",
                "modified.border": "$GIT_MODIFIED",
                "modified.background": "${GIT_MODIFIED}26",
                "predictive": "$MUTED",
                "predictive.border": "$COMMENT",
                "predictive.background": "${BORDER}40",
                "renamed": "$GIT_RENAMED",
                "renamed.border": "$GIT_RENAMED",
                "renamed.background": "$GIT_RENAMED",
                "success": "$SUCCESS",
                "success.border": "$SUCCESS",
                "success.background": "$SUCCESS",
                "unreachable": "$ERROR",
                "unreachable.border": "$ERROR",
                "unreachable.background": "$ERROR",
                "players": [
                    {
                        "cursor": "$FG",
                        "selection": "$SELECTION",
                        "background": "$BG"
                    }
                ],
                "version_control.added": "$GIT_ADDED",
                "version_control.added_background": "${GIT_ADDED}26",
                "version_control.deleted": "$GIT_DELETED",
                "version_control.deleted_background": "${GIT_DELETED}26",
                "version_control.modified": "$GIT_MODIFIED",
                "version_control.modified_background": "${GIT_MODIFIED}26",
                "version_control.renamed": "$GIT_RENAMED",
                "version_control.conflict": "$GIT_CONFLICT",
                "version_control.conflict_background": "${GIT_CONFLICT}26",
                "version_control.ignored": "$COMMENT",
                "error": "$ERROR",
                "error.background": "$BG",
                "error.border": "$ERROR",
                "warning": "$WARNING",
                "warning.background": "$BG",
                "warning.border": "$WARNING",
                "hint": "$COMMENT",
                "hint.background": "$BG",
                "hint.border": "$COMMENT",
                "info": "$INFO",
                "info.background": "$BG",
                "info.border": "$INFO",
                "syntax": {
                    "comment": {
                        "color": "$COMMENT",
                        "font_style": "italic",
                        "font_weight": null
                    },
                    "keyword": {
                        "color": "$KEYWORD",
                        "font_style": null,
                        "font_weight": null
                    },
                    "function": {
                        "color": "$FUNCTION",
                        "font_style": null,
                        "font_weight": null
                    },
                    "string": {
                        "color": "$STRING",
                        "font_style": null,
                        "font_weight": null
                    },
                    "variable": {
                        "color": "$VARIABLE",
                        "font_style": null,
                        "font_weight": null
                    },
                    "type": {
                        "color": "$TYPE",
                        "font_style": null,
                        "font_weight": null
                    },
                    "constant": {
                        "color": "$NUMBER",
                        "font_style": null,
                        "font_weight": null
                    },
                    "operator": {
                        "color": "$OPERATOR",
                        "font_style": null,
                        "font_weight": null
                    },
                    "number": {
                        "color": "$NUMBER",
                        "font_style": null,
                        "font_weight": null
                    },
                    "boolean": {
                        "color": "$NUMBER",
                        "font_style": null,
                        "font_weight": null
                    },
                    "property": {
                        "color": "$FUNCTION",
                        "font_style": null,
                        "font_weight": null
                    },
                    "attribute": {
                        "color": "$NUMBER",
                        "font_style": null,
                        "font_weight": null
                    },
                    "tag": {
                        "color": "$KEYWORD",
                        "font_style": null,
                        "font_weight": null
                    },
                    "punctuation": {
                        "color": "$OPERATOR",
                        "font_style": null,
                        "font_weight": null
                    },
                    "punctuation.bracket": {
                        "color": "$OPERATOR",
                        "font_style": null,
                        "font_weight": null
                    },
                    "punctuation.delimiter": {
                        "color": "$OPERATOR",
                        "font_style": null,
                        "font_weight": null
                    }
                }
            }
        }
    ]
}
EOF

    return 0
}

# Generate themes based on mode
case "$MODE" in
    dark)
        generate_zed_theme "dark"
        ;;
    light)
        generate_zed_theme "light"
        ;;
    all)
        generate_zed_theme "dark"
        generate_zed_theme "light"
        ;;
esac

exit 0