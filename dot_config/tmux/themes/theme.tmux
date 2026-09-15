# Copy mode
set -g mode-style "fg=#101010,bg=#458ee6,bold"

# Status bar
set -g status-style "fg=#b0b0b0,bg=#101010"
set -g message-style "fg=#ffffff,bg=#272727"
set -g message-command-style "fg=#d9ba73,bg=#272727"

# Status left: session name
set -g status-left "#[fg=#101010,bg=#458ee6,bold] #S #[default] "

# Status right: current path and time
set -g status-right "#[fg=#458ee6]#{=/-32/...:#{b:pane_current_path}} #[fg=#272727]│#[fg=#777777] %H:%M "

# Window status
set -g window-status-style "fg=#777777,bg=#101010"
set -g window-status-current-style "fg=#458ee6,bg=#101010,bold"
set -g window-status-activity-style "fg=#ff7676,bg=#101010"

# Pane borders
set -g pane-border-style "fg=#272727"
set -g pane-active-border-style "fg=#458ee6"
