local wezterm = require 'wezterm'

-- This will be used to store the configuration table
local config = {}

-- In newer versions of WezTerm, use the config_builder which is recommended
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- ===================================================================
-- General Appearance (Merged from kitty.conf)
-- ===================================================================

-- Load the color scheme from pywal's generated JSON file.
local colors = wezterm.color.load_from_json_file(os.getenv('HOME') .. '/.cache/wal/colors.json')
if colors then
    config.colors = colors
end

-- Font configuration from Kitty
config.font = wezterm.font("Fira Code")
config.font_size = 13

-- Cursor configuration
config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_rate = 0

-- Background opacity from Kitty
config.window_background_opacity = 0.95

-- Window padding from Kitty
config.window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
}

-- Tab bar / Status bar appearance
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false -- Use a simpler tab bar style

-- Pane border colors
config.inactive_pane_hsb = {
    hue = 240.0,      -- a neutral hue
    saturation = 0.0,
    brightness = 0.5, -- dim
}

-- Enable mouse support (default in WezTerm)
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
config.leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
    -- Pane splitting
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
    {
        key = 'R',
        mods = 'LEADER',
        action = wezterm.action.ReloadConfiguration,
    },

    -- Smart Pane Navigation (vim-tmux-navigator)
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
    {
        key = '[',
        mods = 'LEADER',
        action = wezterm.action.ActivateCopyMode,
    },
}

-- ===================================================================
-- Copy Mode (Vi Mode)
-- ===================================================================

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

wezterm.on('update-status', function(window, pane)
    local process_name = pane:get_foreground_process_name()
    local is_vim = process_name and (process_name:find('[n|g]?vi[m]?x?') or process_name:find('fzf'))
    pane:set_user_var('is_vim', is_vim and 'true' or 'false')
end)

-- ===================================================================
-- Tab Bar Formatting
-- Note: This custom formatter will override pywal colors for the tab bar.
-- ===================================================================

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    -- Use pywal colors if available, otherwise default
    local background = (config.colors and config.colors.tab_bar.background) or '#080808'
    local foreground = '#cccccc'

    if tab.is_active then
        background = (config.colors and config.colors.tab_bar.active_tab.bg_color) or '#1f1f1f'
        foreground = (config.colors and config.colors.tab_bar.active_tab.fg_color) or '#ffffff'
    end

    if hover then
        background = (config.colors and config.colors.tab_bar.inactive_tab_hover.bg_color) or '#3f3f3f'
        foreground = (config.colors and config.colors.tab_bar.inactive_tab_hover.fg_color) or '#ffffff'
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
