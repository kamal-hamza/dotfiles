# Tab: accept the grey autosuggestion if one is showing, otherwise do fish's
# normal completion. Completion is untouched whenever there's no suggestion
# (e.g. `cd <Tab>` with an empty/unsuggested line) and while the completion
# pager is open (Tab keeps cycling through candidates).
function __tab_accept_or_complete
    if commandline --paging-mode
        commandline -f complete
    else if commandline --showing-suggestion
        commandline -f accept-autosuggestion
    else
        commandline -f complete
    end
end
