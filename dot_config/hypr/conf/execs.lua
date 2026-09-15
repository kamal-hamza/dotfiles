hl.on("hyprland.start", function()
  hl.exec_cmd("thunar --daemon")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("quickshell")
  hl.exec_cmd("hyprlauncher -d")
  hl.exec_cmd("mpd-mpris") -- bridges mpd onto MPRIS for Quickshell's now-playing widget
end)
