# Minimal prompt: `dir (branch) % ` - same look as the old zsh prompt.
function fish_prompt
    set -l branch (command git symbolic-ref --short HEAD 2>/dev/null; or command git rev-parse --short HEAD 2>/dev/null)
    printf '%s ' (path basename -- (string replace -r "^$HOME\$" '~' -- $PWD))
    test -n "$branch"; and printf '(%s) ' $branch
    printf '%% '
end
