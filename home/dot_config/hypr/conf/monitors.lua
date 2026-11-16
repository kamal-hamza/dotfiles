-- fallback for any other display that gets plugged in (projector, TV, ...)
hl.monitor({
  output = "",
  mode = "preferred",
  scale = "auto",
  position = "auto"
})

-- main: LG ultrawide
hl.monitor({
  output = "DP-2",
  mode = "3440x1440@100",
  scale = 1,
  position = "0x0"
})

-- HP 1080p is only used when booted into Windows, so Hyprland leaves it off.
-- Flip disabled to false (or delete this block) to bring it back; with
-- position = "-1920x0" it sits to the left of the ultrawide.
hl.monitor({
  output = "HDMI-A-1",
  disabled = true
})
