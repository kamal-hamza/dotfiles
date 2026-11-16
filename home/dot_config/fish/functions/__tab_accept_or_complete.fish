# Tab: accept the grey autosuggestion if one is showing, otherwise do fish's
# normal completion. Completion is untouched whenever there's no suggestion
# (e.g. `cd <Tab>` with an empty/unsuggested line) and while the completion
# pager is open (Tab keeps cycling through candidates). Hands normal
# completion to autopair.fish's _autopair_tab when that plugin is installed,
# so both behaviours survive whichever binding loads last.
function __tab_accept_or_complete
    if commandline --paging-mode
        commandline -f complete
    else if commandline --showing-suggestion
        commandline -f accept-autosuggestion
    else if functions -q _autopair_tab
        _autopair_tab
    else
        commandline -f complete
    end
end
