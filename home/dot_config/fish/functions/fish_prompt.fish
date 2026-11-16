# macOS Terminal/zsh default prompt: `user@host dir % ` (zsh's '%n@%m %1~ %# ').
function fish_prompt
    set -l dir (string replace -r "^$HOME\$" '~' -- $PWD)
    test "$dir" != '~' -a "$dir" != /; and set dir (path basename -- $dir)
    set -l char '%'
    fish_is_root_user; and set char '#'
    printf '%s@%s %s %s ' $USER (prompt_hostname) $dir $char
end
