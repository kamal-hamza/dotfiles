local wezterm = require 'wezterm'

-- This will be used to store the configuration table
local config = {}

-- In newer versions of WezTerm, use the config_builder which is recommended
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- ===================================================================
-- General Appearance (from kitty.conf)
-- ===================================================================

-- Font configuration
-- Corresponds to: font_family, bold_font, italic_font, bold_italic_font, font_size
config.font = wezterm.font("MesloLGL Nerd Font Mono")
config.font_size = 20.0

-- Cursor configuration
-- Corresponds to: cursor_blink_interval, cursor_shape
config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_rate = 0

-- Background opacity and blur (for macOS)
-- Corresponds to: background_opacity, background_blur
config.window_background_opacity = 0.4
config.macos_window_background_blur = 64

-- macOS specific options
-- Corresponds to: macos_option_as_alt
-- config.send_composed_key_when_left_alt_is_pressed = true

-- Tab bar / Status bar appearance
-- Corresponds to: tmux's status-position, status-style, etc.
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false -- Use a simpler tab bar style

-- Pane border colors
-- Corresponds to: tmux's pane-border-lines, pane-border-style
config.inactive_pane_hsb = {
    hue = 240.0,      -- a neutral hue
    saturation = 0.0,
    brightness = 0.5, -- dim
}

-- Enable mouse support (default in WezTerm)
-- Corresponds to: set -g mouse on
config.mouse_bindings = {
    -- Allows right-click to spawn top command in new tab
    {
        event = { Down = { streak = 1, button = 'Right' } },
        action = wezterm.action.SpawnCommandInNewTab {
            args = { 'top' }
        },
        mods = 'NONE',
    },
}

-- ===================================================================
-- Multiplexer Keybindings (from tmux.conf)
-- ===================================================================

-- Set the leader key (prefix)
-- Corresponds to: set -g prefix C-s
config.leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
    -- Pane splitting
    -- Corresponds to: bind v split-window -h, bind b split-window -v
    {
        key = 'v',
        mods = 'LEADER',
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = 'b',
        mods = 'LEADER',
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },

    -- Closing panes and tabs (windows)
    -- Corresponds to: bind x kill-pane, bind & kill-window
    {
        key = 'x',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentPane { confirm = false },
    },
    {
        key = '&',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentTab { confirm = false },
    },

    -- Tab (window) navigation
    -- Corresponds to: bind l next-window, bind k previous-window
    {
        key = 'l',
        mods = 'LEADER',
        action = wezterm.action.ActivateTabRelative(1),
    },
    {
        key = 'k',
        mods = 'LEADER',
        action = wezterm.action.ActivateTabRelative(-1),
    },

    -- Renaming tabs (windows)
    -- Corresponds to: bind r command-prompt "rename-window '%%'"
    {
        key = 'r',
        mods = 'LEADER',
        action = wezterm.action.PromptInputLine {
            description = 'Enter new name for tab',
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        },
    },

    -- Reload configuration
    -- Corresponds to: bind R source-file ~/.tmux.conf
    {
        key = 'R',
        mods = 'LEADER',
        action = wezterm.action.ReloadConfiguration,
    },

    -- Smart Pane Navigation (vim-tmux-navigator)
    -- This section replicates the C-h/j/k/l navigation between vim and wezterm panes.
    -- WezTerm has built-in support for this kind of logic.
    {
        key = 'h',
        mods = 'CTRL',
        action = wezterm.action_callback(function(win, pane)
            local is_vim = pane:get_user_vars().is_vim
            if is_vim then
                win:perform_action(wezterm.action.SendKey { key = 'h', mods = 'CTRL' }, pane)
            else
                win:perform_action(wezterm.action.ActivatePaneDirection 'Left', pane)
            end
        end),
    },
    {
        key = 'j',
        mods = 'CTRL',
        action = wezterm.action_callback(function(win, pane)
            local is_vim = pane:get_user_vars().is_vim
            if is_vim then
                win:perform_action(wezterm.action.SendKey { key = 'j', mods = 'CTRL' }, pane)
            else
                win:perform_action(wezterm.action.ActivatePaneDirection 'Down', pane)
            end
        end),
    },
    {
        key = 'k',
        mods = 'CTRL',
        action = wezterm.action_callback(function(win, pane)
            local is_vim = pane:get_user_vars().is_vim
            if is_vim then
                win:perform_action(wezterm.action.SendKey { key = 'k', mods = 'CTRL' }, pane)
            else
                win:perform_action(wezterm.action.ActivatePaneDirection 'Up', pane)
            end
        end),
    },
    {
        key = 'l',
        mods = 'CTRL',
        action = wezterm.action_callback(function(win, pane)
            local is_vim = pane:get_user_vars().is_vim
            if is_vim then
                win:perform_action(wezterm.action.SendKey { key = 'l', mods = 'CTRL' }, pane)
            else
                win:perform_action(wezterm.action.ActivatePaneDirection 'Right', pane)
            end
        end),
    },

    -- Enter copy mode
    -- Corresponds to: bind [ copy-mode
    {
        key = '[',
        mods = 'LEADER',
        action = wezterm.action.ActivateCopyMode,
    },
}

-- ===================================================================
-- Copy Mode (Vi Mode)
-- ===================================================================

-- Corresponds to: setw -g mode-keys vi
config.key_tables = {
    copy_mode = {
        {
            key = 'v',
            mods = 'NONE',
            action = wezterm.action.CopyMode { SetSelectionMode = 'Cell' },
        },
        {
            key = 'y',
            mods = 'NONE',
            action = wezterm.action.Multiple {
                wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
                wezterm.action.CopyMode 'Close',
            },
        },
        {
            key = 'Escape',
            mods = 'NONE',
            action = wezterm.action.CopyMode 'Close',
        },
    },
}

-- ===================================================================
-- Helper for vim-tmux-navigator functionality
-- ===================================================================

-- This event triggers whenever the foreground process in a pane changes.
-- We check if it's a vim-like process and set a variable on the pane.
wezterm.on('update-status', function(window, pane)
    local process_name = pane:get_foreground_process_name()
    -- This regex is equivalent to the one in your tmux.conf
    local is_vim = process_name and (process_name:find('[n|g]?vi[m]?x?') or process_name:find('fzf'))
    pane:set_user_var('is_vim', is_vim and 'true' or 'false')
end)

-- ===================================================================
-- Tab Bar Formatting
-- ===================================================================

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local background = '#080808'
    local foreground = '#cccccc'
    local is_active = tab.is_active

    if is_active then
        background = '#1f1f1f'
        foreground = '#ffffff'
    end

    if hover then
        background = '#3f3f3f'
    end

    local title = string.format(" %s ", tab.tab_index .. ": " .. tab.active_pane.title)

    return {
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = title },
    }
end)

-- Finally, return the configuration table
return config
