local M = {}

M._version = "2.10.2" -- x-release-please-version

---@type dark.Config
M.defaults = {
  transparent = false,
  theme = {
    dark = "dark",
    light = "light",
  },
  styles = {
    functions = { bold = true },
    keywords = {},
    comments = {},
    strings = {},
    constants = {},
  },
  colors = {},
  auto = true,
  cache = true,

  on_highlights = function(highlights, colors) end,
}

---@type dark.Config
M.options = vim.deepcopy(M.defaults) -- using this we can omit calling setup()

---@param opts dark.Config|nil
---@return dark.Config
function M.extend(opts)
  return vim.tbl_deep_extend("force", M.defaults, opts or {})
end

---@param opts dark.Config|nil
function M.setup(opts)
  M.options = M.extend(opts)
end

return M
