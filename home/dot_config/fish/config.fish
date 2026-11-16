# =============================================================================
# fish config (macOS + Linux)
# =============================================================================
# Almost everything lives in conf.d/ (sourced alphabetically before this file)
# and functions/ (autoloaded on first use):
#   conf.d/00-homebrew.fish     macOS only (chezmoi skips it on Linux)
#   conf.d/10-env.fish          env vars + PATH  <- .chezmoidata/shell.yaml
#   conf.d/20-tools.fish        mise / zoxide / fzf init
#   conf.d/30-aliases.fish      abbreviations    <- .chezmoidata/shell.yaml
#   conf.d/90-dev-tools.fish    machine-specific dev-tools/*.fish (not in git)
# Per-OS differences are chosen by chezmoi (.chezmoiignore / templates), not
# by runtime `uname` checks here.
# =============================================================================

if status is-interactive
    set -g fish_greeting
end
