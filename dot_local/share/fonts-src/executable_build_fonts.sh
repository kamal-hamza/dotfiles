#!/usr/bin/env bash

# =============================================================================
# Build Fonts - Patch fonts with Nerd Font glyphs
# =============================================================================
# Patches specific fonts (name + weight) with Nerd Font glyphs.
# Avoids variable fonts which cause fontforge to segfault.
#
# Requirements:
#   - fontforge (install via Homebrew or pacman)
#   - git
#
# Usage:
#   build-fonts
#
# Output:
#   Patched fonts are installed to ~/.local/share/fonts
# =============================================================================

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Configuration - fonts to patch with (name, weight) pairs
declare -a FONT_SPECS=(
  "SourceSans3:Regular"
  "SourceSans3:Bold"
  "SourceSans3:Italic"
  "SourceSerif4:Regular"
  "SourceSerif4:Bold"
  "SourceSerif4:Italic"
)

OUT="$HOME/.local/share/fonts"
NERD_DIR="$HOME/.cache/nerd-fonts"
PATCHER="$NERD_DIR/font-patcher"
OS="$(uname -s)"

# Trap errors
trap 'print_error "Script failed at line $LINENO"' ERR

# Pre-flight checks
print_info "Running pre-flight checks..."

# Check fontforge
if ! command -v fontforge &>/dev/null; then
  print_error "Fontforge not found"
  print_info "Install with: brew install fontforge (macOS) or pacman -S fontforge (Arch)"
  exit 1
fi

# Check git
if ! command -v git &>/dev/null; then
  print_error "Git not found"
  exit 1
fi

# Setup Nerd Fonts repository
print_info "Setting up Nerd Fonts repository..."

if [[ ! -d "$NERD_DIR" ]]; then
  print_info "Cloning Nerd Fonts repository..."
  if ! git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git "$NERD_DIR"; then
    print_error "Failed to clone Nerd Fonts repository"
    exit 1
  fi
else
  print_info "Updating Nerd Fonts repository..."
  if git -C "$NERD_DIR" pull --rebase 2>&1 | grep -q "Already up to date"; then
    print_info "Repository already up to date"
  else
    print_success "Repository updated"
  fi
fi

# Verify font-patcher exists
if [[ ! -f "$PATCHER" ]]; then
  print_error "font-patcher not found at $PATCHER"
  print_info "Verify Nerd Fonts repository cloned correctly"
  exit 1
fi
print_success "font-patcher found"

# Platform-specific font directories
if [[ "$OS" == "Linux" ]]; then
  FONT_DIRS=(
    "/usr/share/fonts"
    "$HOME/.local/share/fonts"
  )
elif [[ "$OS" == "Darwin" ]]; then
  FONT_DIRS=(
    "/Library/Fonts"
    "$HOME/Library/Fonts"
  )
else
  print_error "Unsupported OS: $OS"
  exit 1
fi

# Create output directory
mkdir -p "$OUT" || {
  print_error "Failed to create output directory: $OUT"
  exit 1
}

# Helper function to find font by name and weight
# Excludes variable fonts (files with [wght], [opsz], etc.)
find_font_by_weight() {
  local name="$1"
  local weight="$2"
  local result

  for dir in "${FONT_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
      continue
    fi

    # Search for name-weight pattern, excluding variable fonts
    # Pattern: Name-Weight.ext or Name Weight.ext (case-insensitive)
    result="$(find "$dir" -maxdepth 1 -type f \
      \( -iname "${name}-${weight}.ttf" -o -iname "${name}-${weight}.otf" \
         -o -iname "${name} ${weight}.ttf" -o -iname "${name} ${weight}.otf" \) \
      2>/dev/null | head -n 1)"
    
    if [[ -n "$result" ]]; then
      echo "$result"
      return 0
    fi
  done

  return 1
}

# Patch fonts
print_info "Patching fonts..."
found_count=0
patched_count=0
failed_fonts=()

for spec in "${FONT_SPECS[@]}"; do
  IFS=':' read -r font_name weight <<< "$spec"
  
  print_info "Processing: $font_name $weight"

  if ! FONT_PATH="$(find_font_by_weight "$font_name" "$weight")"; then
    print_warning "Font not found: $font_name $weight"
    failed_fonts+=("$font_name $weight")
    continue
  fi

  ((found_count++))
  print_info "  Source: $FONT_PATH"

  # Run font-patcher with error handling
  if fontforge -script "$PATCHER" "$FONT_PATH" --complete --extension ttf -out "$OUT" &>/dev/null; then
    ((patched_count++))
    print_success "Patched: $font_name $weight"
  else
    print_error "Patching failed for: $font_name $weight"
    failed_fonts+=("$font_name $weight")
  fi
done

# Refresh font cache
if [[ "$OS" == "Linux" ]]; then
  print_info "Refreshing font cache..."
  if command -v fc-cache &>/dev/null; then
    if fc-cache -fv &>/dev/null; then
      print_success "Font cache refreshed"
    else
      print_warning "Font cache refresh encountered issues"
    fi
  else
    print_warning "fc-cache not found, skipping cache refresh"
  fi
elif [[ "$OS" == "Darwin" ]]; then
  print_info "Font cache will be updated automatically on macOS"
fi

# Summary
echo ""
print_info "=== Summary ==="
echo "Found:   $found_count fonts"
echo "Patched: $patched_count fonts"
echo "Output:  $OUT"

if [[ ${#failed_fonts[@]} -gt 0 ]]; then
  echo ""
  print_warning "Failed to process:"
  for font in "${failed_fonts[@]}"; do
    echo "  - $font"
  done
fi

if [[ $patched_count -eq 0 ]]; then
  print_error "No fonts were successfully patched"
  print_info ""
  print_info "Troubleshooting:"
  print_info "1. Check font names: ls $FONT_DIRS"
  print_info "2. Variable fonts may not work with font-patcher"
  print_info "3. Try using pre-patched fonts from https://www.nerdfonts.com"
  exit 1
fi

print_success "Font patching complete"
