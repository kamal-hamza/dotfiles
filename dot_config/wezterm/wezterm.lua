local wezterm = require 'wezterm'

-- This will be used to store the configuration table
local config = {}

-- In newer versions of WezTerm, use the config_builder which is recommended
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- Detect the operating system
local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_macos = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

-- ===================================================================
-- General Appearance
-- ===================================================================

config.enable_wayland = false

-- Cursor configuration
config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_rate = 0

-- Window padding
config.window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
}

config.hide_tab_bar_if_only_one_tab = true

-- Tab bar / Status bar appearance
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Pane border colors
config.inactive_pane_hsb = {
    hue = 240.0,
    saturation = 0.0,
    brightness = 0.5,
}

-- Mouse bindings
config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = 'Right' } },
        action = wezterm.action.SpawnCommandInNewTab {
            args = { 'top' }
        },
        mods = 'NONE',
    },
}

-- ===================================================================
-- Multiplexer Keybindings (Windows)
-- ===================================================================

if is_windows then
    config.leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 1000 }

    config.keys = {
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
        {
            key = 'R',
            mods = 'LEADER',
            action = wezterm.action.ReloadConfiguration,
        },

        -- Smart Pane Navigation
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
        {
            key = '[',
            mods = 'LEADER',
            action = wezterm.action.ActivateCopyMode,
        },
    }

    config.key_tables = {
        copy_mode = {
            {
                key = 'v',
                action = wezterm.action.CopyMode { SetSelectionMode = 'Cell' },
            },
            {
                key = 'y',
                action = wezterm.action.Multiple {
                    wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
                    wezterm.action.CopyMode 'Close',
                },
            },
            {
                key = 'Escape',
                action = wezterm.action.CopyMode 'Close',
            },
        },
    }
end

-- ===================================================================
-- Vim detection (vim-tmux-navigator helper)
-- ===================================================================

wezterm.on('update-status', function(window, pane)
    local process_name = pane:get_foreground_process_name()
    local is_vim = process_name and (
        process_name:find('[n|g]?vi[m]?x?') or process_name:find('fzf')
    )
    pane:set_user_var('is_vim', is_vim and 'true' or 'false')
end)

-- Return config
return config
