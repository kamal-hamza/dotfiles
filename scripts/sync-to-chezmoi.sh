#!/usr/bin/env bash
# =============================================================================
# Sync Development Changes to Chezmoi
# =============================================================================
# This script syncs changes from your Git repository to the chezmoi source
# directory for testing. Useful during development of dotfiles.
#
# Usage: ./scripts/sync-to-chezmoi.sh
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHEZMOI_SOURCE="$(chezmoi source-path)"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Syncing to Chezmoi Source Directory${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}From:${NC} $REPO_DIR"
echo -e "${GREEN}To:${NC}   $CHEZMOI_SOURCE"
echo ""

# Sync .chezmoidata
echo -e "${YELLOW}Syncing .chezmoidata...${NC}"
rsync -av --delete "$REPO_DIR/.chezmoidata/" "$CHEZMOI_SOURCE/.chezmoidata/"

# Sync dot_config
echo -e "${YELLOW}Syncing dot_config...${NC}"
rsync -av --delete "$REPO_DIR/dot_config/" "$CHEZMOI_SOURCE/dot_config/"

# Sync dot_local
echo -e "${YELLOW}Syncing dot_local...${NC}"
rsync -av --delete "$REPO_DIR/dot_local/" "$CHEZMOI_SOURCE/dot_local/"

# Sync docs
if [[ -d "$REPO_DIR/docs" ]]; then
    echo -e "${YELLOW}Syncing docs...${NC}"
    rsync -av --delete "$REPO_DIR/docs/" "$CHEZMOI_SOURCE/docs/"
fi

# Sync other files
echo -e "${YELLOW}Syncing other files...${NC}"
for file in dot_* run_* .chezmoi* .gitignore README.md; do
    if [[ -f "$REPO_DIR/$file" ]]; then
        cp "$REPO_DIR/$file" "$CHEZMOI_SOURCE/"
    fi
done

echo ""
echo -e "${GREEN}✓ Sync complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review changes: chezmoi diff"
echo "  2. Apply changes:  chezmoi apply"
echo ""