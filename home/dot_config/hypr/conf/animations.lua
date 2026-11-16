-- curves
hl.curve("quick", { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })
hl.curve("overshoot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("smoothOut", { type = "bezier", points = { {0.36, 0}, {0.66, -0.56} } })
hl.curve("smoothIn", { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })
hl.curve("linear", { type = "bezier", points = { {0.0, 0.0}, {1.0, 1.0} } })

-- animations
-- misc
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "smoothIn" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 45, bezier = "linear", style = "loop" }) -- Sped up rotation

-- windows (Lowered from 5 to 3/2.5)
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "overshoot" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "overshoot", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "smoothOut", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "smoothIn" })

-- fade (Lowered from 3 to 1.5)
hl.animation({ leaf = "fade", enabled = true, speed = 1.5, bezier = "smoothIn" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.5, bezier = "smoothIn" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.5, bezier = "smoothOut" })

-- layers (Lowered from 4 to 2.5)
hl.animation({ leaf = "layers", enabled = true, speed = 2.5, bezier = "smoothIn" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2.5, bezier = "smoothIn", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.5, bezier = "smoothOut", style = "fade" })

-- workspaces (Lowered from 5 to 2.5)
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "smoothIn", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2.5, bezier = "smoothIn", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2.5, bezier = "smoothIn", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "smoothIn", style = "slidevert" })

-- zoom (Lowered from 7 to 4)
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 4, bezier = "quick" })
