#!/usr/bin/env bash
# =============================================================================
# Font Switcher - Interactive font selection with fzf
# =============================================================================
# This script allows you to quickly switch fonts across all configured apps
# using fzf for selection. After selection, it updates the fonts.yaml file
# and applies changes with chezmoi.
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
CHEZMOI_DATA_DIR="${HOME}/.local/share/chezmoi/.chezmoidata"
FONTS_CONFIG="${CHEZMOI_DATA_DIR}/fonts.yaml"

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo -e "${RED}Error: fzf is not installed${NC}"
    echo "Please install fzf: brew install fzf"
    exit 1
fi

# Check if yq is installed (for YAML manipulation)
if ! command -v yq &> /dev/null; then
    echo -e "${YELLOW}Warning: yq is not installed. Will use sed for updates.${NC}"
    echo "For better YAML handling, install yq: brew install yq"
    USE_SED=1
else
    USE_SED=0
fi

# Function to get system fonts (macOS)
get_system_fonts() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Get font families from system and filter to likely monospace fonts
        # Look for common monospace font keywords
        system_profiler SPFontsDataType 2>/dev/null | \
            grep "Family:" | \
            sed 's/.*Family: //' | \
            grep -iE "mono|consolas|courier|menlo|monaco|inconsolata|source.*code|fira.*code|jetbrains|hack|SF.*Mono|liga|meslo|cascadia|roboto.*mono|ubuntu.*mono|droid.*sans.*mono|liberation.*mono|nerd.*font|iosevka|victor.*mono|fantasque|comic.*mono|commit.*mono|input.*mono|operator.*mono|dank.*mono|anonymous.*pro|pt.*mono" | \
            sort -u
    else
        # Linux - use fc-list with monospace filter
        fc-list :mono family | cut -d, -f1 | sort -u
    fi
}

# Function to get current font
get_current_font() {
    if [[ -f "$FONTS_CONFIG" ]]; then
        if [[ $USE_SED -eq 1 ]]; then
            grep "^font_family:" "$FONTS_CONFIG" | sed 's/font_family: *"\(.*\)"/\1/'
        else
            yq eval '.font_family' "$FONTS_CONFIG" | tr -d '"'
        fi
    else
        echo "Menlo"
    fi
}

# Function to create a list of popular monospace fonts
get_popular_fonts() {
    cat << 'EOF'
Menlo
Monaco
JetBrains Mono
JetBrainsMono Nerd Font
Fira Code
FiraCode Nerd Font
Hack
Hack Nerd Font
Source Code Pro
SourceCodePro Nerd Font
IBM Plex Mono
Cascadia Code
Cascadia Mono
SF Mono
Inconsolata
Inconsolata Nerd Font
Consolas
Courier New
DejaVu Sans Mono
Ubuntu Mono
UbuntuMono Nerd Font
Roboto Mono
RobotoMono Nerd Font
Anonymous Pro
Meslo LG
MesloLGS Nerd Font
Fantasque Sans Mono
Victor Mono
VictorMono Nerd Font
Iosevka
Intel One Mono
Monaspace Neon
Monaspace Argon
Monaspace Xenon
Monaspace Radon
Monaspace Krypton
Commit Mono
Comic Mono
Operator Mono
Dank Mono
Liga SFMono Nerd Font
EOF
}

# Function to update font in fonts.yaml
update_font_config() {
    local new_font="$1"
    
    if [[ ! -f "$FONTS_CONFIG" ]]; then
        echo -e "${RED}Error: fonts.yaml not found at $FONTS_CONFIG${NC}"
        exit 1
    fi
    
    if [[ $USE_SED -eq 1 ]]; then
        # Use sed to update the font_family line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^font_family: .*$/font_family: \"$new_font\"/" "$FONTS_CONFIG"
        else
            sed -i "s/^font_family: .*$/font_family: \"$new_font\"/" "$FONTS_CONFIG"
        fi
    else
        # Use yq for proper YAML manipulation
        yq eval ".font_family = \"$new_font\"" -i "$FONTS_CONFIG"
    fi
}

# Function to preview font (if possible)
preview_font() {
    local font="$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Font: $font"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "The quick brown fox jumps over the lazy dog"
    echo "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG"
    echo "0123456789 !@#$%^&*()_+-=[]{}|;:',.<>?/~\`"
    echo "iI1lL oO0 \"'\` ,;:. != () {} [] <>"
    echo ""
    echo "Code Sample:"
    echo "function fibonacci(n) {"
    echo "    if (n <= 1) return n;"
    echo "    return fibonacci(n - 1) + fibonacci(n - 2);"
    echo "}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Main function
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           Font Switcher - Select a Font              ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Get current font
    current_font=$(get_current_font)
    echo -e "${GREEN}Current font:${NC} $current_font"
    echo ""
    
    # Build font list
    echo -e "${YELLOW}Loading available fonts...${NC}"
    
    # Get only actually installed system fonts (more reliable)
    all_fonts=$(get_system_fonts)
    
    # If no fonts found, fall back to popular list
    if [[ -z "$all_fonts" ]]; then
        echo -e "${YELLOW}Could not detect system fonts, using popular list...${NC}"
        all_fonts=$(get_popular_fonts | sort -u)
    fi
    
    # Use fzf to select a font
    selected_font=$(echo "$all_fonts" | fzf \
        --prompt="Select font: " \
        --height=20 \
        --layout=reverse \
        --border=rounded \
        --preview='echo "Font: {}"; echo ""; echo "The quick brown fox jumps over the lazy dog"; echo "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG"; echo "0123456789 !@#$%^&*()_+-=[]{}|;:,.<>?/~"; echo "iI1lL oO0 \"\` ,;:. != () {} [] <>"; echo ""; echo "function fibonacci(n) {"; echo "    if (n <= 1) return n;"; echo "    return fibonacci(n - 1) + fibonacci(n - 2);"; echo "}"' \
        --preview-window=up:12 \
        --header="Current: $current_font | ↑↓: Navigate | Enter: Select | Esc: Cancel" \
        --pointer="▶" \
        --marker="✓")
    
    # Check if a font was selected
    if [[ -z "$selected_font" ]]; then
        echo -e "${YELLOW}No font selected. Exiting.${NC}"
        exit 0
    fi
    
    # Check if the selected font is the same as current
    if [[ "$selected_font" == "$current_font" ]]; then
        echo -e "${YELLOW}Selected font is already the current font. No changes made.${NC}"
        exit 0
    fi
    
    # Verify the font exists on the system (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! system_profiler SPFontsDataType 2>/dev/null | grep -q "Family: $selected_font"; then
            echo -e "${YELLOW}Warning: Font '$selected_font' may not be installed on your system.${NC}"
            echo -e "${YELLOW}WezTerm may fall back to another font.${NC}"
            read -p "Continue anyway? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}Font change cancelled.${NC}"
                exit 0
            fi
        fi
    fi
    
    echo ""
    echo -e "${GREEN}Selected font:${NC} $selected_font"
    echo ""
    
    # Update the configuration
    echo -e "${YELLOW}Updating fonts.yaml...${NC}"
    update_font_config "$selected_font"
    
    # Apply with chezmoi
    echo -e "${YELLOW}Applying changes with chezmoi...${NC}"
    if chezmoi apply; then
        echo ""
        echo -e "${GREEN}✓ Font successfully changed to: $selected_font${NC}"
        echo ""
        echo -e "${BLUE}Note:${NC} You may need to restart or reload your applications:"
        echo "  • WezTerm: Reload config (Cmd+R or restart)"
        echo "  • Zed: Will reload automatically"
        echo "  • Neovim/Neovide: Restart the editor"
        echo ""
    else
        echo -e "${RED}✗ Error applying changes with chezmoi${NC}"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Font Switcher - Interactive font selection with fzf"
        echo ""
        echo "Usage: font-switcher.sh [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --list, -l     List all available fonts"
        echo "  --current, -c  Show current font"
        echo "  --preview, -p  Preview current font"
        echo ""
        echo "Examples:"
        echo "  font-switcher.sh           # Interactive font selection"
        echo "  font-switcher.sh --list    # List available fonts"
        echo "  font-switcher.sh --current # Show current font"
        exit 0
        ;;
    --list|-l)
        echo "Available fonts:"
        fonts=$(get_system_fonts)
        if [[ -z "$fonts" ]]; then
            get_popular_fonts
        else
            echo "$fonts"
        fi
        exit 0
        ;;
    --current|-c)
        echo "Current font: $(get_current_font)"
        exit 0
        ;;
    --preview|-p)
        preview_font "$(get_current_font)"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac