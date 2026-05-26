-- stylua: ignore
---@class dark.Palette
-- Colors synced with Obsidian dark theme CSS
local palette = {
  -- Primary backgrounds (from Obsidian)
  bg         = "#050505",  -- --background-primary
  bg_alt     = "#060606",  -- --background-primary-alt / --code-background
  bg_secondary = "#080808",  -- --background-secondary
  bg_secondary_alt = "#0c0c0c",  -- --background-secondary-alt
  bg_interactive = "#0a0a0a",  -- --interactive-normal / --tab-background-active
  bg_tag     = "#090909",  -- --tag-background
  bg_hover   = "#101010",  -- --interactive-hover
  
  -- Text colors (from Obsidian)
  fg         = "#d4d4d4",  -- --text-normal
  fg_code    = "#d8d8d8",  -- --code-normal
  fg_accent  = "#d6d6d6",  -- --text-accent
  fg_accent_hover = "#ffffff",  -- --text-accent-hover / --link-color-hover
  fg_inline_title = "#f3f3f3",  -- --inline-title-color
  fg_link    = "#d9d9d9",  -- --link-color
  fg_nav     = "#9f9f9f",  -- --nav-item-color
  fg_nav_hover = "#dcdcdc",  -- --nav-item-color-hover
  fg_nav_active = "#ffffff",  -- --nav-item-color-active
  fg_tab     = "#848484",  -- --tab-text-color
  fg_tab_focused = "#d7d7d7",  -- --tab-text-color-focused
  fg_tab_active = "#ffffff",  -- --tab-text-color-active
  
  fg_dim     = "#8d8d8d",  -- --text-muted
  fg_faint   = "#666666",  -- --text-faint
  
  -- Interactive colors
  interactive_accent = "#cfcfcf",  -- --interactive-accent
  interactive_accent_hover = "#f1f1f1",  -- --interactive-accent-hover
  
  -- For backward compatibility / UI elements
  dim        = "#474747",  -- selection-like
  line       = "#272727",  -- hover border-like
  
  keyword    = "#8d8d8d",  -- --text-muted
  type       = "#8d8d8d",  -- --text-muted
  operator   = "#b5b5b5",  -- muted operator
  comment    = "#8d8d8d",  -- --text-muted
  
  border     = "#d4d4d4",  -- --text-normal
  emphasis   = "#f1f1f1",  -- --interactive-accent-hover
  func       = "#d6d6d6",  -- --text-accent
  string     = "#d4d4d4",  -- --text-normal
  char       = "#d4d4d4",  -- --text-normal
  special    = "#d4d4d4",  -- --text-normal
  
  -- Semantic colors (keeping distinct accent colors)
  const      = "#d9ba73",  -- accent yellow
  highlight  = "#458ee6",  -- accent blue
  info       = "#8ebeec",  -- info blue
  success    = "#86cd82",  -- accent green
  warning    = "#d9ba73",  -- accent yellow
  danger     = "#ff7676",  -- accent red
  
  green      = "#14ba19",
  orange     = "#ff5733",
  red        = "#701516",
  pink       = "#f2a4db",
  cyan       = "#5abfb5",
}

return palette
