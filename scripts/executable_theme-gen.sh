#!/usr/bin/env bash

# =============================================================================
# Theme Generator - Main Orchestrator
# =============================================================================
# This script generates theme configurations for all applications from the
# source Zed theme JSON files.
#
# Usage:
#   theme-gen.sh [dark|light|all]
#
# Examples:
#   theme-gen.sh dark    # Generate only dark theme
#   theme-gen.sh light   # Generate only light theme
#   theme-gen.sh all     # Generate both themes (default)
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_GEN_DIR="$SCRIPT_DIR/theme-generators"
THEME_SOURCE_DIR="$SCRIPT_DIR/.chezmoidata/themes"
CONFIG_DIR="$HOME/.config"

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if theme generators directory exists
if [[ ! -d "$THEME_GEN_DIR" ]]; then
    print_error "Theme generators directory not found: $THEME_GEN_DIR"
    exit 1
fi

# Parse arguments
MODE="${1:-all}"

case "$MODE" in
    dark|light|all)
        ;;
    *)
        print_error "Invalid argument. Use: dark, light, or all"
        echo "Usage: theme-gen.sh [dark|light|all]"
        exit 1
        ;;
esac

print_header "Soft Focus Theme Generator"
print_info "Mode: $MODE"
echo ""

# Track success/failure
declare -a SUCCESS_LIST
declare -a FAILED_LIST

# Find all theme generators
GENERATORS=()
while IFS= read -r -d '' generator; do
    GENERATORS+=("$generator")
done < <(find "$THEME_GEN_DIR" -name "*.sh" -type f -print0 | sort -z)

if [[ ${#GENERATORS[@]} -eq 0 ]]; then
    print_warning "No theme generators found in $THEME_GEN_DIR"
    exit 0
fi

print_info "Found ${#GENERATORS[@]} theme generator(s)"
echo ""

# Run each generator
for generator in "${GENERATORS[@]}"; do
    generator_name=$(basename "$generator" .sh)
    app_name="${generator_name#generate-}"
    
    print_info "Generating $app_name theme..."
    
    if bash "$generator" "$MODE" 2>&1; then
        print_success "$app_name theme generated"
        SUCCESS_LIST+=("$app_name")
    else
        print_error "$app_name theme generation failed"
        FAILED_LIST+=("$app_name")
    fi
done

# Summary
echo ""
print_header "Generation Summary"

if [[ ${#SUCCESS_LIST[@]} -gt 0 ]]; then
    echo -e "${GREEN}✓ Successfully generated:${NC}"
    for app in "${SUCCESS_LIST[@]}"; do
        echo "  • $app"
    done
fi

if [[ ${#FAILED_LIST[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}✗ Failed to generate:${NC}"
    for app in "${FAILED_LIST[@]}"; do
        echo "  • $app"
    done
    echo ""
    print_warning "Some themes failed to generate. Check the errors above."
    exit 1
fi

echo ""
print_success "All themes generated successfully!"
echo ""
print_info "To apply themes, run: chezmoi apply"
echo ""