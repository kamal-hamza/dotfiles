# Matches wezterm.lua (macOS Terminal.app "Basic", dark): greys only, no
# accent colors. Status bar = Terminal's title/tab bar grey, selection = its
# selection blue, borders = wezterm's split color.

# Copy mode / selection
set -g mode-style "fg=#ffffff,bg=#3f638b"

# Status bar
set -g status-style "fg=#a0a0a0,bg=#2b2b2b"
set -g message-style "fg=#ffffff,bg=#2b2b2b"
set -g message-command-style "fg=#ffffff,bg=#2b2b2b"

# Status left: session name
set -g status-left "#[fg=#ffffff,bold] #S #[default] "

# Status right: current path and time
set -g status-right "#{=/-32/...:#{b:pane_current_path}} #[fg=#5a5a5a]│#[default] %H:%M "

# Window status
set -g window-status-style "fg=#808080,bg=#2b2b2b"
set -g window-status-current-style "fg=#ffffff,bg=#2b2b2b,bold"
set -g window-status-activity-style "fg=#ffffff,bg=#2b2b2b,underscore"

# Pane borders
set -g pane-border-style "fg=#3a3a3a"
set -g pane-active-border-style "fg=#5a5a5a"

# Copy-mode position indicator
set -g copy-mode-position-style "fg=#a0a0a0,bg=#2b2b2b"
