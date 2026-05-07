#!/usr/bin/env bash

# =============================================================================
# Pi Library Documentation Fetcher - Setup Script
# =============================================================================
# Automated installation and configuration for the library docs extension
#
# Usage:
#   ./setup.sh [--global] [--project] [--check]
#
# Options:
#   --global   Install globally (default)
#   --project  Install in current project only
#   --check    Verify existing installation
# =============================================================================

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# Defaults
INSTALL_GLOBAL=true
INSTALL_PROJECT=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --global)
            INSTALL_GLOBAL=true
            INSTALL_PROJECT=false
            shift
            ;;
        --project)
            INSTALL_GLOBAL=false
            INSTALL_PROJECT=true
            shift
            ;;
        --check)
            CHECK_ONLY=true
            shift
            ;;
        --help)
            grep "^# Usage:" -A 10 "$0"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if in chezmoi source directory
if [[ -f "$SCRIPT_DIR/lib-docs.ts" ]]; then
    EXTENSION_FILE="$SCRIPT_DIR/lib-docs.ts"
    DOCS_DIR="$SCRIPT_DIR"
else
    print_error "setup.sh must be run from the extension directory"
    exit 1
fi

print_info "Pi Library Documentation Fetcher Setup"
echo ""

# ============================================================================
# CHECK ONLY MODE
# ============================================================================

if [[ "${CHECK_ONLY:-false}" == "true" ]]; then
    print_info "Checking installation..."
    
    FOUND=false
    
    # Check global
    if [[ -f "$HOME/.pi/agent/extensions/lib-docs.ts" ]]; then
        print_success "Global installation: ~/.pi/agent/extensions/lib-docs.ts"
        FOUND=true
    fi
    
    # Check project
    if [[ -f ".pi/extensions/lib-docs.ts" ]]; then
        print_success "Project installation: ./.pi/extensions/lib-docs.ts"
        FOUND=true
    fi
    
    # Check cache
    if [[ -d "$HOME/.pi/doc-cache" ]]; then
        CACHE_SIZE=$(du -sh "$HOME/.pi/doc-cache" 2>/dev/null | cut -f1)
        print_info "Cache directory exists (Size: $CACHE_SIZE)"
    fi
    
    if [[ "$FOUND" == "true" ]]; then
        print_success "Installation found and verified"
        exit 0
    else
        print_warning "No installation found. Run without --check to install."
        exit 1
    fi
fi

# ============================================================================
# INSTALLATION MODE
# ============================================================================

# Verify required files
print_info "Verifying extension files..."
if [[ ! -f "$EXTENSION_FILE" ]]; then
    print_error "Extension file not found: $EXTENSION_FILE"
    exit 1
fi
print_success "Extension file found"

# Create directories
if [[ "$INSTALL_GLOBAL" == "true" ]]; then
    print_info "Installing globally..."
    
    GLOBAL_DIR="$HOME/.pi/agent/extensions"
    
    if [[ ! -d "$GLOBAL_DIR" ]]; then
        print_info "Creating directory: $GLOBAL_DIR"
        mkdir -p "$GLOBAL_DIR"
        print_success "Directory created"
    fi
    
    # Copy extension
    print_info "Copying extension file..."
    cp "$EXTENSION_FILE" "$GLOBAL_DIR/lib-docs.ts"
    chmod 644 "$GLOBAL_DIR/lib-docs.ts"
    print_success "Extension installed: $GLOBAL_DIR/lib-docs.ts"
    
    # Copy documentation
    print_info "Copying documentation..."
    for doc in README.md EXAMPLES.md INSTALL.md ARCHITECTURE.md QUICK-REFERENCE.md INDEX.md; do
        if [[ -f "$DOCS_DIR/$doc" ]]; then
            cp "$DOCS_DIR/$doc" "$GLOBAL_DIR/$doc" 2>/dev/null || true
        fi
    done
    print_success "Documentation copied"
    
    INSTALL_LOCATION="$GLOBAL_DIR/lib-docs.ts"
fi

if [[ "$INSTALL_PROJECT" == "true" ]]; then
    print_info "Installing in project..."
    
    PROJECT_DIR=".pi/extensions"
    
    if [[ ! -d "$PROJECT_DIR" ]]; then
        print_info "Creating directory: $PROJECT_DIR"
        mkdir -p "$PROJECT_DIR"
        print_success "Directory created"
    fi
    
    # Copy extension
    print_info "Copying extension file..."
    cp "$EXTENSION_FILE" "$PROJECT_DIR/lib-docs.ts"
    chmod 644 "$PROJECT_DIR/lib-docs.ts"
    print_success "Extension installed: $PROJECT_DIR/lib-docs.ts"
    
    INSTALL_LOCATION="$PROJECT_DIR/lib-docs.ts"
fi

# Create cache directory
print_info "Setting up cache directory..."
CACHE_DIR="$HOME/.pi/doc-cache"
if [[ ! -d "$CACHE_DIR" ]]; then
    mkdir -p "$CACHE_DIR"
    chmod 755 "$CACHE_DIR"
    print_success "Cache directory created: $CACHE_DIR"
else
    print_info "Cache directory already exists: $CACHE_DIR"
fi

# ============================================================================
# VERIFICATION
# ============================================================================

print_info "Verifying installation..."
echo ""

if [[ -f "$INSTALL_LOCATION" ]]; then
    print_success "Extension file exists"
    
    # Check file size
    SIZE=$(wc -c < "$INSTALL_LOCATION")
    print_success "Extension size: $(numfmt --to=iec-i --suffix=B $SIZE 2>/dev/null || echo "$SIZE bytes")"
    
    # Check syntax (basic)
    if grep -q "export default function" "$INSTALL_LOCATION"; then
        print_success "Extension format verified"
    else
        print_warning "Could not verify extension format"
    fi
else
    print_error "Extension file not found after installation!"
    exit 1
fi

# ============================================================================
# NEXT STEPS
# ============================================================================

echo ""
print_success "Installation complete!"
echo ""
print_info "Quick start:"
echo ""

if [[ "$INSTALL_GLOBAL" == "true" ]]; then
    echo "  1. Start Pi in any project:"
    echo "     cd ~/my-project && pi"
    echo ""
elif [[ "$INSTALL_PROJECT" == "true" ]]; then
    echo "  1. Start Pi in this project:"
    echo "     pi"
    echo ""
fi

echo "  2. Fetch documentation:"
echo "     /fetch-docs requests       # Python"
echo "     /fetch-docs express        # Node.js"
echo ""
echo "  3. Ask the agent:"
echo "     'Using the fetched documentation, write a ...'"
echo ""

# Documentation files
if [[ -f "$GLOBAL_DIR/QUICK-REFERENCE.md" ]] || [[ -f "$PROJECT_DIR/QUICK-REFERENCE.md" ]]; then
    DOC_DIR="${GLOBAL_DIR:-$PROJECT_DIR}"
    echo "📚 Documentation available at: $DOC_DIR/"
    echo ""
    echo "  Start with: QUICK-REFERENCE.md (quick lookup)"
    echo "  Then read:  EXAMPLES.md (real-world usage)"
    echo "  Deep dive:  ARCHITECTURE.md (how it works)"
    echo ""
fi

# Recommended next steps
echo "📋 Recommended next steps:"
echo ""
echo "  • Read QUICK-REFERENCE.md for common commands"
echo "  • Check EXAMPLES.md for usage scenarios"
echo "  • Try: /fetch-docs <library> in Pi"
echo ""

# Integration tips
if [[ "$INSTALL_GLOBAL" == "true" ]]; then
    echo "💡 Dotfiles tip:"
    echo ""
    echo "  To include this in chezmoi dotfiles:"
    echo "    1. Add to: ~/.local/share/chezmoi/dot_pi/extensions/"
    echo "    2. Run: chezmoi apply"
    echo ""
fi

print_success "All set! Start Pi and use /fetch-docs to get started."
echo ""
