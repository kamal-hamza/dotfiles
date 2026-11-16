# Tool integrations - only for interactive shells, only if installed.
status is-interactive; or return

command -q mise; and mise activate fish | source
command -q zoxide; and zoxide init fish --cmd cd | source
command -q fzf; and fzf --fish | source
