#!/usr/bin/env bash

# =============================================================================
# Permission Gates Extension - Setup Script
# =============================================================================
# Automated installation and configuration
#
# Usage:
#   ./setup.sh [--global] [--project] [--check]
# =============================================================================

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}*${NC} $1"; }
print_error() { echo -e "${RED}X${NC} $1"; }
print_info() { echo -e "${BLUE}>${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }

# Defaults
INSTALL_GLOBAL=true
INSTALL_PROJECT=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --global) INSTALL_GLOBAL=true; INSTALL_PROJECT=false; shift ;;
        --project) INSTALL_GLOBAL=false; INSTALL_PROJECT=true; shift ;;
        --check) CHECK_ONLY=true; shift ;;
        --help) grep "^# Usage:" -A 3 "$0"; exit 0 ;;
        *) print_error "Unknown option: $1"; exit 1 ;;
    esac
done

print_info "Permission Gates Extension Setup"
echo ""

# ============================================================================
# CHECK ONLY MODE
# ============================================================================

if [[ "${CHECK_ONLY:-false}" == "true" ]]; then
    print_info "Checking installation..."
    
    FOUND=false
    
    if [[ -f "$HOME/.pi/agent/extensions/permission-gates/index.ts" ]]; then
        print_success "Global installation: ~/.pi/agent/extensions/permission-gates/index.ts"
        FOUND=true
    fi
    
    if [[ -f ".pi/extensions/permission-gates/index.ts" ]]; then
        print_success "Project installation: ./.pi/extensions/permission-gates/index.ts"
        FOUND=true
    fi
    
    if [[ -f "$HOME/.pi/permission-gates-config.json" ]]; then
        print_info "Configuration: ~/.pi/permission-gates-config.json"
    fi
    
    if [[ -f "$HOME/.pi/permission-gates-audit.log" ]]; then
        LOG_SIZE=$(wc -l < "$HOME/.pi/permission-gates-audit.log")
        print_info "Audit log: ~/.pi/permission-gates-audit.log ($LOG_SIZE lines)"
    fi
    
    if [[ "$FOUND" == "true" ]]; then
        print_success "Installation verified"
        exit 0
    else
        print_warning "No installation found"
        exit 1
    fi
fi

# ============================================================================
# INSTALLATION MODE
# ============================================================================

# Verify required files
print_info "Verifying extension files..."
if [[ ! -f "$SCRIPT_DIR/index.ts" ]]; then
    print_error "Extension file not found: $SCRIPT_DIR/index.ts"
    exit 1
fi
print_success "Extension file found"

# Create directories
if [[ "$INSTALL_GLOBAL" == "true" ]]; then
    print_info "Installing globally..."
    
    GLOBAL_DIR="$HOME/.pi/agent/extensions/permission-gates"
    
    if [[ -d "$GLOBAL_DIR" ]]; then
        print_warning "Directory already exists: $GLOBAL_DIR"
        print_info "Updating files..."
    else
        print_info "Creating directory: $GLOBAL_DIR"
        mkdir -p "$GLOBAL_DIR"
        print_success "Directory created"
    fi
    
    # Copy extension
    print_info "Copying extension files..."
    cp "$SCRIPT_DIR/index.ts" "$GLOBAL_DIR/index.ts"
    cp "$SCRIPT_DIR/package.json" "$GLOBAL_DIR/package.json" 2>/dev/null || true
    
    # Copy documentation
    for doc in README.md QUICK-REFERENCE.md EXAMPLES.md INSTALL.md; do
        if [[ -f "$SCRIPT_DIR/$doc" ]]; then
            cp "$SCRIPT_DIR/$doc" "$GLOBAL_DIR/$doc"
        fi
    done
    
    chmod 644 "$GLOBAL_DIR"/*.ts "$GLOBAL_DIR"/*.md 2>/dev/null || true
    print_success "Extension installed: $GLOBAL_DIR"
    
    INSTALL_LOCATION="$GLOBAL_DIR/index.ts"
fi

if [[ "$INSTALL_PROJECT" == "true" ]]; then
    print_info "Installing in project..."
    
    PROJECT_DIR=".pi/extensions/permission-gates"
    
    if [[ ! -d "$PROJECT_DIR" ]]; then
        print_info "Creating directory: $PROJECT_DIR"
        mkdir -p "$PROJECT_DIR"
    fi
    
    # Copy extension
    print_info "Copying extension files..."
    cp "$SCRIPT_DIR/index.ts" "$PROJECT_DIR/index.ts"
    cp "$SCRIPT_DIR/package.json" "$PROJECT_DIR/package.json" 2>/dev/null || true
    
    # Copy docs
    for doc in README.md QUICK-REFERENCE.md EXAMPLES.md; do
        if [[ -f "$SCRIPT_DIR/$doc" ]]; then
            cp "$SCRIPT_DIR/$doc" "$PROJECT_DIR/$doc"
        fi
    done
    
    print_success "Extension installed: $PROJECT_DIR"
    
    INSTALL_LOCATION="$PROJECT_DIR/index.ts"
fi

# Create audit directory
print_info "Setting up audit directory..."
mkdir -p "$HOME/.pi"
chmod 755 "$HOME/.pi"
print_success "Audit directory ready: ~/.pi"

# ============================================================================
# VERIFICATION
# ============================================================================

print_info "Verifying installation..."
echo ""

if [[ -f "$INSTALL_LOCATION" ]]; then
    print_success "Extension installed"
    
    # Check file size
    SIZE=$(wc -c < "$INSTALL_LOCATION")
    print_info "Extension size: $SIZE bytes"
    
    # Check syntax
    if grep -q "export default function" "$INSTALL_LOCATION"; then
        print_success "Extension format verified"
    fi
else
    print_error "Installation failed!"
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
    echo "     pi"
    echo ""
elif [[ "$INSTALL_PROJECT" == "true" ]]; then
    echo "  1. Start Pi in this project:"
    echo "     pi"
    echo ""
fi

echo "  2. You should see:"
echo "     [PERMISSION GATES] active (strict mode)"
echo ""
echo "  3. Try a dangerous command:"
echo "     rm -rf /tmp/test"
echo ""
echo "  4. Confirm when prompted"
echo ""

echo "Documentation:"
echo "  Quick start: QUICK-REFERENCE.md"
echo "  Examples: EXAMPLES.md"
echo "  Full docs: README.md"
echo "  Setup help: INSTALL.md"
echo ""

print_success "Ready to use! Start Pi and try it out."
echo ""
