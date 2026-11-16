function fish_user_key_bindings
    # Tab: accept the grey autosuggestion if shown, else normal completion
    bind tab __tab_accept_or_complete
    # Alt+Tab: always complete the current word, ignoring any suggestion
    bind alt-tab complete
end
