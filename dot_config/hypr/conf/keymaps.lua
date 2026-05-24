local super = "alt"
local terminal = "kitty"
local fileManager = "thunar"

hl.bind(super .. " + ENTER", hl.dsp.exec_cmd(terminal))
hl.bind(super .. " + E", hl.dsp.exec_cmd(fileManager))


-- close any window
hl.bind(super .. " +Q", hl.dsp.window.kill())
