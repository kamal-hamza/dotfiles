local super = "ALT"
local terminal = "LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe ghostty"
local fileManager = "thunar"
local lock = "hyprlock"

hl.bind(super .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(super .. " + E", hl.dsp.exec_cmd(fileManager))

-- go back to tty
hl.bind(super .. " + M", hl.dsp.exec_cmd("loginctl terminate-user \"\""))

-- lock
hl.bind(super .. " + L", hl.dsp.exec_cmd(lock))

-- close any window
hl.bind(super .. " +Q", hl.dsp.window.close({ window = "active" }))
