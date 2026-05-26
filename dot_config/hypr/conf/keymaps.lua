local super = "ALT"
local terminal = "LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe ghostty"
local fileManager = "thunar"
local lock = "hyprlock"
local browser = "firefox"

-- app binds
hl.bind(super .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(super .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(super .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(super .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(super .. " + R", hl.dsp.exec_cmd("rofi -show run"))
hl.bind(super .. " + T", hl.dsp.exec_cmd("rofi -show window"))


-- go back to tty
hl.bind(super .. " + M", hl.dsp.exec_cmd("loginctl terminate-user \"\""))

-- lock
hl.bind(super .. " + L", hl.dsp.exec_cmd(lock))

-- close any window
hl.bind(super .. " +Q", hl.dsp.window.close({ window = "active" }))

-- drag windows
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- resize windows
hl.bind(super .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
