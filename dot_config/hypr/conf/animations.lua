-- curves
hl.curve("quick", { type = "beizer", points = { {0.15, 0}, {0.1, 1} } })

-- animations
-- misc
hl.animation({ leaf = "global", enabled = true, speed = 10, beizer = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.5, beizer = "linear" })

-- window
hl.animation({ leaf = "windows", enabled = true, speed = 5, beizer = "linear" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, beizer = "linear" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, beizer = "linear" })

-- fade
hl.animation({ leaf = "fade", enabled = true, speed = 2, beizer = "quick" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, beizer = "quick" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, beizer = "quick" })

-- layers
hl.animation({ leaf = "layers", enabled = true, speed = 3, beizer = "linear" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, beizer = "linear" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, beizer = "linear" })

-- fade layers
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.5, beizer = "linear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.5, beizer = "linear" })

-- workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, beizer = "linear" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2, beizer = "linear" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2, beizer = "linear" })

-- zoom
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, beizer = "quick" })




