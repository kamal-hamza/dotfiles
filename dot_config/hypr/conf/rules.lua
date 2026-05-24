hl.window_rule({
  name = "float",
  match = {
    class = ".*",
  },
  float = true,
  size = {
    "monitor_w * 0.75",
    "monitor_h * 0.75"
  },
})
