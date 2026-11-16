# No syntax highlighting: everything is plain terminal text, like zsh in macOS
# Terminal. Exceptions only where the color carries meaning:
#   - autosuggestion stays grey (Tab accepts it, so it must look different)
#   - selections / search matches / the selected pager entry are reversed
# Global (-g), so nothing lands in fish_variables.
status is-interactive; or return

for var in normal command keyword quote redirection end error param valid_path \
        option comment operator escape cwd cwd_root user host host_remote status \
        cancel history_current
    set -g fish_color_$var normal
end
set -g fish_color_autosuggestion brblack
set -g fish_color_selection --reverse
set -g fish_color_search_match --reverse

for var in progress background prefix completion description \
        secondary_background secondary_prefix secondary_completion secondary_description \
        selected_prefix selected_completion selected_description
    set -g fish_pager_color_$var normal
end
set -g fish_pager_color_selected_background --reverse
