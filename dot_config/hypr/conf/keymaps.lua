local super = "ALT"
local win = "SUPER"
local terminal = "ghostty"
local fileManager = "thunar"
local lock = "hyprlock"
local browser = "firefox"

-- app binds
hl.bind(super .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(super .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(super .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(super .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(win .. " + SPACE", hl.dsp.exec_cmd("rofi -show run"))

-- workspace binds
for i = 1, 5 do
    hl.bind(super .. " + " .. tostring(i), hl.dsp.focus({ workspace = i }))
    hl.bind(super .. " + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = i }))
end

-- music player binds
hl.bind(super .. " + SHIFT + B", hl.dsp.window.move({ workspace = "special:music", follow = false }))
hl.bind(super .. " + B", hl.dsp.workspace.toggle_special("music"))

-- window binds
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(super .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(super .. " + Q", hl.dsp.window.close({ window = "active" }))
hl.bind(super .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(super .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(super .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(super .. " + J", hl.dsp.focus({ direction = "d" }))

-- go back to tty
hl.bind(super .. " + M", hl.dsp.exec_cmd("loginctl terminate-user \"\""))

-- lock
hl.bind(super .. " + SHIFT + L", hl.dsp.exec_cmd(lock))

-- screenshots with satty annotation
-- Area select screenshot with annotation
hl.bind(super .. " + SHIFT + S", hl.dsp.exec_cmd("screenshot-area"))

-- Full screen screenshot with annotation
hl.bind(super .. " + SHIFT + A", hl.dsp.exec_cmd("screenshot-fullscreen"))

-- background player binds
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })

-- additional music controls (using mpc, with super key)
hl.bind(super .. " + PERIOD", hl.dsp.exec_cmd("smart-next"), { locked = true })
hl.bind(super .. " + COMMA", hl.dsp.exec_cmd("mpc prev"), { locked = true })
hl.bind(super .. " + P", hl.dsp.exec_cmd("mpc toggle"), { locked = true })
hl.bind(super .. " + R", hl.dsp.exec_cmd("cycle-repeat-mode"), { locked = true })
hl.bind(super .. " + SLASH", hl.dsp.exec_cmd("mpc seek 0%"), { locked = true })
hl.bind(super .. " + EQUAL", hl.dsp.exec_cmd("mpc volume +5"), { locked = true })
hl.bind(super .. " + MINUS", hl.dsp.exec_cmd("mpc volume -5"), { locked = true })
hl.bind(super .. " + SHIFT + C", hl.dsp.exec_cmd("mpc clear"), { locked = true })

-- queue songs with rofi
hl.bind(super .. " + GRAVE", hl.dsp.exec_cmd("~/.config/rofi/scripts/mpd-queue"), { locked = true })

-- view current queue
hl.bind(super .. " + SHIFT + V", hl.dsp.exec_cmd("show-queue"), { locked = true })
