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
# Repo root of the real chezmoi checkout (source-path is its home/ subdir,
# because of .chezmoiroot)
CHEZMOI_SOURCE="$(chezmoi execute-template '{{ .chezmoi.workingTree }}')"

if [[ "$REPO_DIR" -ef "$CHEZMOI_SOURCE" ]]; then
    echo "This checkout IS the chezmoi source directory - nothing to sync."
    exit 0
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Syncing to Chezmoi Source Directory${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}From:${NC} $REPO_DIR"
echo -e "${GREEN}To:${NC}   $CHEZMOI_SOURCE"
echo ""

# Source state (home/ = .chezmoiroot) and files installed outside $HOME (system/)
for dir in home system docs; do
    if [[ -d "$REPO_DIR/$dir" ]]; then
        echo -e "${YELLOW}Syncing $dir/...${NC}"
        rsync -av --delete --exclude '__pycache__/' "$REPO_DIR/$dir/" "$CHEZMOI_SOURCE/$dir/"
    fi
done

# Top-level files
echo -e "${YELLOW}Syncing top-level files...${NC}"
for file in .chezmoiroot .gitignore .gitattributes README.md CLAUDE.md AGENTS.md; do
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