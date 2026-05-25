-- general config
hl.config({
  general = {
    border_size = 0.5,
    gaps_in = 3,
    gaps_out = 10,
    float_gaps = 3,
    gaps_workspaces = 0,
    col.active_border = rgb(ffffff) rgb(b0b0b0) 45deg,
    col.inactive_border = rgb(474747) rgb(272727) 45deg,
    col.nogroup_border_active = rgb(f2a4db) rgb(ff7676) 45deg,
    col.nogroup_border = rgb(d9ba73) rgb(272727) 45deg,
    layout = "dwindle",
    no_focus_fallback = true,
    resize_on_border = false,
    snap = {
      enabled = true,
      window_gap = 10,
      monitor_gap = 5,
      border_overlap = false,
      respect_gaps = true,
    }
  }
});

-- decoration config
hl.config({
  decoration = {
    rounding = 0,
    rounding_power = 0.0,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,
    dim_modal = true,
    dim_inactive = false,
    dim_strength = 0.7,
    dim_special = 0.7,
    dim_around = 0.7,
    border_part_of_window = true,
    blur = {
      enabled = false,
    },
    shadow = {
      enabled = false,
    },
    glow = {
      enabled = false,
    },
    animations = {
      enabled = true,
    },
  }
})

-- input config
