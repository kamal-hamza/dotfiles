local M = {}

---@param opts dark.Config|nil
function M.setup(opts)
  require("dark.config").setup(opts)

  -- Reload the colorscheme with :DarkFetch
  vim.api.nvim_create_user_command("DarkFetch", function()
    require("dark.utils").reload()
  end, {})
end

--- Get the current palette with any user overrides applied
---@return dark.Palette
function M.get_palette(theme)
  theme = require("dark.utils").resolve(theme)
  local config = require("dark.config")
  local palette = require("dark.palette." .. theme)

  -- Apply custom color overrides if they exist
  if config.options.colors and type(config.options.colors) == "table" then
    palette = vim.tbl_deep_extend("force", palette, config.options.colors)
  end

  return palette
end

--- Blends two colors based on alpha transparency
---@param foreground string Foreground hex color
---@param background string Background hex color
---@param alpha number Blend factor (0 to 1)
---@return string # A hex color string like "#RRGGBB"
function M.blend(foreground, background, alpha)
  return require("dark.utils").blend(foreground, background, alpha)
end

--- Main function to apply the theme
function M.load(theme)
  theme = require("dark.utils").resolve(theme)
  local config = require("dark.config")
  local groups = require("dark.groups") -- points to lua/dark/groups/init.lua
  local palette = M.get_palette(theme)

  -- Reset existing highlights to prevent styles from previous themes from bleeding over.
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = theme and "dark-" .. theme or "dark"

  -- Unpack and resolve custom styles
  local hl_groups = groups.setup(palette, config.options, theme)

  -- Apply highlights
  for group, hl in pairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, hl)
  end
end

return M
