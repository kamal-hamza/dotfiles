#!/usr/bin/env bash

# =============================================================================
# Pi Extensions - Setup All
# =============================================================================
# Copies extensions to ~/.pi/ and optionally installs them via Pi CLI
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PI_EXTENSIONS_DIR="$HOME/.pi/agent/extensions"

print_info "Setting up Pi extensions from chezmoi source..."
echo ""

# Create extensions directory
mkdir -p "$PI_EXTENSIONS_DIR"
print_success "Extensions directory ready: $PI_EXTENSIONS_DIR"

# List of extensions with their source directories
declare -a EXTENSIONS=(
    "lib-docs"
    "permission-gates"
    "file-diff-and-approval"
)

# Copy each extension
for ext in "${EXTENSIONS[@]}"; do
    src="$SCRIPT_DIR/agent/extensions/$ext"
    dst="$PI_EXTENSIONS_DIR/$ext"
    
    if [[ ! -d "$src" ]]; then
        print_warning "Skipping $ext - source not found: $src"
        continue
    fi
    
    print_info "Installing extension: $ext"
    
    # Create destination and copy files
    mkdir -p "$dst"
    cp -r "$src"/* "$dst/"
    
    print_success "Copied: $ext"
done

echo ""
print_success "All extensions copied to: $PI_EXTENSIONS_DIR"
echo ""

print_info "Recommended next steps:"
echo ""
echo "  To use extensions in Pi, you have two options:"
echo ""
echo "  Option 1 - Use Pi CLI (recommended, handles dependencies):"
echo "    pi install npm:pi-show-diffs"
echo "    pi install npm:permission-gates"
echo "    pi install npm:lib-docs"
echo ""
echo "  Option 2 - Extensions auto-load from ~/.pi/agent/extensions/"
echo "    Just start Pi: pi"
echo ""

print_info "After installation, in Pi use:"
echo ""
echo "  /diff-approval on       # File diff approval"
echo "  /permission-gates on    # Permission gates"
echo "  /fetch-docs <library>   # Library docs fetcher"
echo ""

print_success "Setup complete!"
