#!/usr/bin/env bash

# =============================================================================
# Pi File Diff and Approval Extension - Setup Script
# =============================================================================
# Automated installation and configuration for the file diff approval extension
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

# Check if in extension directory
if [[ -f "$SCRIPT_DIR/index.ts" && -f "$SCRIPT_DIR/package.json" ]]; then
    EXTENSION_DIR="$SCRIPT_DIR"
else
    print_error "setup.sh must be run from the extension directory"
    exit 1
fi

print_info "Pi File Diff and Approval Extension Setup"
echo ""

# ============================================================================
# CHECK ONLY MODE
# ============================================================================

if [[ "${CHECK_ONLY:-false}" == "true" ]]; then
    print_info "Checking installation..."
    
    FOUND=false
    
    # Check global
    if [[ -d "$HOME/.pi/agent/extensions/file-diff-and-approval" ]]; then
        print_success "Global installation: ~/.pi/agent/extensions/file-diff-and-approval"
        FOUND=true
    fi
    
    # Check project
    if [[ -d ".pi/extensions/file-diff-and-approval" ]]; then
        print_success "Project installation: ./.pi/extensions/file-diff-and-approval"
        FOUND=true
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

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is required but not installed"
    exit 1
fi

print_success "Node.js found: $(node --version)"

# Install npm dependencies
print_info "Installing npm dependencies..."
if [[ -f "$EXTENSION_DIR/package.json" ]]; then
    # Install only the runtime dependencies to avoid conflict with other extensions
    npm install --no-save --ignore-scripts cli-highlight@2.1.11 diff@8.0.2 --legacy-peer-deps 2>&1 | tail -5 || true
    
    # Copy node_modules to extension if not already there
    if [[ ! -d "$EXTENSION_DIR/node_modules" ]]; then
        TEMP_MODULES="$(npm root)/node_modules"
        if [[ -d "$TEMP_MODULES" ]]; then
            mkdir -p "$EXTENSION_DIR/node_modules"
            cp -R "$TEMP_MODULES/cli-highlight" "$EXTENSION_DIR/node_modules/" 2>/dev/null || true
            cp -R "$TEMP_MODULES/diff" "$EXTENSION_DIR/node_modules/" 2>/dev/null || true
            # Copy all transitive dependencies
            find "$TEMP_MODULES" -maxdepth 1 -type d | while read dep; do
                name=$(basename "$dep")
                [[ "$name" != "." && "$name" != ".." ]] && cp -R "$dep" "$EXTENSION_DIR/node_modules/$name" 2>/dev/null || true
            done
        fi
    fi
    print_success "Dependencies installed"
fi

# Create directories
if [[ "$INSTALL_GLOBAL" == "true" ]]; then
    print_info "Installing globally..."
    
    GLOBAL_DIR="$HOME/.pi/agent/extensions/file-diff-and-approval"
    
    if [[ ! -d "$GLOBAL_DIR" ]]; then
        print_info "Creating directory: $GLOBAL_DIR"
        mkdir -p "$GLOBAL_DIR"
        print_success "Directory created"
    fi
    
    # Copy all extension files
    print_info "Copying extension files..."
    cp -r "$EXTENSION_DIR/"* "$GLOBAL_DIR/" 2>/dev/null || true
    chmod 755 "$GLOBAL_DIR"
    chmod 644 "$GLOBAL_DIR"/* 2>/dev/null || true
    find "$GLOBAL_DIR" -name "*.ts" -type f -exec chmod 644 {} \;
    find "$GLOBAL_DIR" -name "package.json" -type f -exec chmod 644 {} \;
    
    print_success "Extension installed: $GLOBAL_DIR"
    
    INSTALL_LOCATION="$GLOBAL_DIR"
fi

if [[ "$INSTALL_PROJECT" == "true" ]]; then
    print_info "Installing in project..."
    
    PROJECT_DIR=".pi/extensions/file-diff-and-approval"
    
    if [[ ! -d "$PROJECT_DIR" ]]; then
        print_info "Creating directory: $PROJECT_DIR"
        mkdir -p "$PROJECT_DIR"
        print_success "Directory created"
    fi
    
    # Copy extension
    print_info "Copying extension files..."
    cp -r "$EXTENSION_DIR/"* "$PROJECT_DIR/" 2>/dev/null || true
    chmod 755 "$PROJECT_DIR"
    chmod 644 "$PROJECT_DIR"/* 2>/dev/null || true
    
    print_success "Extension installed: $PROJECT_DIR"
    
    INSTALL_LOCATION="$PROJECT_DIR"
fi

# Create config directory
print_info "Setting up config directory..."
CONFIG_DIR="$HOME/.pi/agent/extensions"
if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir -p "$CONFIG_DIR"
    chmod 755 "$CONFIG_DIR"
    print_success "Config directory created: $CONFIG_DIR"
else
    print_info "Config directory already exists: $CONFIG_DIR"
fi

# ============================================================================
# VERIFICATION
# ============================================================================

print_info "Verifying installation..."
echo ""

if [[ -f "$INSTALL_LOCATION/index.ts" ]]; then
    print_success "Extension file exists"
    
    # Check dependencies installed
    if [[ -d "$INSTALL_LOCATION/node_modules" ]]; then
        print_success "Dependencies installed"
    else
        print_warning "Dependencies not found in node_modules (will be lazy-loaded by Pi)"
    fi
    
    # Check syntax (basic)
    if grep -q "export default" "$INSTALL_LOCATION/index.ts"; then
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
print_info "What this extension does:"
echo ""
echo "  • Intercepts file write, edit, and hashline_edit operations"
echo "  • Shows split diff viewer before changes are applied"
echo "  • Supports inline editing directly in the diff modal"
echo "  • Provides syntax-aware ANSI highlighting"
echo "  • Allows approval, rejection, or feedback steering"
echo ""

print_info "Quick start:"
echo ""

if [[ "$INSTALL_GLOBAL" == "true" ]]; then
    echo "  1. Start Pi in any project:"
    echo "     cd ~/my-project && pi"
    echo ""
fi

echo "  2. Configure diff approval:"
echo "     /diff-approval on      # Enable auto-checking"
echo "     /diff-approval off     # Disable"
echo "     /diff-approval status  # Check current setting"
echo ""
echo "  3. Use the approval workflow:"
echo "     - Agent makes changes"
echo "     - Modal appears showing the diff"
echo "     - Review with arrow keys / page up/down"
echo "     - Press 'a' or Enter to approve"
echo "     - Press 'r' or Esc to reject"
echo "     - Press 'e' to edit inline"
echo ""

print_info "Key shortcuts in diff modal:"
echo ""
echo "  Approval:   a/y (approve) | r (reject) | e (edit) | s (steer)"
echo "  Navigation: ↑/↓ (scroll) | n/p (next/prev hunk) | Home/End"
echo "  Views:      Tab (split/unified) | ←/→ (context) | w (wrap)"
echo ""

print_info "Documentation:"
echo ""
echo "  • README.md - Full feature overview"
echo "  • Config: ~/.pi/agent/extensions/pi-show-diffs.json"
echo ""

print_success "All set! Start Pi and file changes will now show diffs for approval."
echo ""
