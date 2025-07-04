Statusline = {}
local modes = {
  ["n"] = "NORMAL",
  ["no"] = "NORMAL",
  ["v"] = "VISUAL",
  ["V"] = "VISUAL LINE",
  [""] = "VISUAL BLOCK",
  ["s"] = "SELECT",
  ["S"] = "SELECT LINE",
  [""] = "SELECT BLOCK",
  ["i"] = "INSERT",
  ["ic"] = "INSERT",
  ["R"] = "REPLACE",
  ["Rv"] = "VISUAL REPLACE",
  ["c"] = "COMMAND",
  ["cv"] = "VIM EX",
  ["ce"] = "EX",
  ["r"] = "PROMPT",
  ["rm"] = "MOAR",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  ["t"] = "TERMINAL",
}
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "StatuslineAccent", { link = "Constant" })
    vim.api.nvim_set_hl(0, "StatuslineInsertAccent", { link = "String" })
    vim.api.nvim_set_hl(0, "StatuslineVisualAccent", { link = "Function" })
    vim.api.nvim_set_hl(0, "StatuslineReplaceAccent", { link = "Keyword" })
    vim.api.nvim_set_hl(0, "StatuslineCmdLineAccent", { link = "Type" })
    vim.api.nvim_set_hl(0, "StatuslineTerminalAccent", { link = "Identifier" })
    vim.api.nvim_set_hl(0, "Statusline", { link = "StatusLine" })
    vim.api.nvim_set_hl(0, "StatusLineExtra", { link = "StatusLineNC" })
  end,
})
local function update_mode_colors()
  local current_mode = vim.api.nvim_get_mode().mode
  local mode_color = "%#StatusLineAccent#"
  if current_mode == "n" then
    mode_color = "%#StatuslineAccent#"
  elseif current_mode == "i" or current_mode == "ic" then
    mode_color = "%#StatuslineInsertAccent#"
  elseif current_mode == "v" or current_mode == "V" or current_mode == "" then
    mode_color = "%#StatuslineVisualAccent#"
  elseif current_mode == "R" then
    mode_color = "%#StatuslineReplaceAccent#"
  elseif current_mode == "c" then
    mode_color = "%#StatuslineCmdLineAccent#"
  elseif current_mode == "t" then
    mode_color = "%#StatuslineTerminalAccent#"
  end
  return mode_color
end
local function mode()
  local current_mode = vim.api.nvim_get_mode().mode
  return string.format(" %s ", modes[current_mode]):upper()
end
local function filepath()
  local path = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")
  if path == "" or path == "." then
    return " "
  end
  return string.format(" %%<%s/", path)
end
local function filename()
  local fname = vim.fn.expand "%:t"
  if fname == "" then
    return ""
  end
  return fname .. " "
end
Statusline.active = function()
  return table.concat {
    "%#Statusline#",
    update_mode_colors(),
    mode(),
    "%#Normal#",
    "%=", -- Left/right separator to center the next items
    "%#Normal#",
    filepath(),
    "%#Normal#",
    filename(),
    "%=", -- Another separator for the right section
    "%#Normal#",
    "%#Statusline#",
    update_mode_colors(),
    mode(),
    "%#Normal#",
  }
end
-- Add the inactive function that was referenced but not defined in the original code
Statusline.inactive = function()
  return "%#StatusLineNC# %F %m %r %="
end
-- Add the short function that was referenced but not defined in the original code
Statusline.short = function()
  return "%#StatusLine# NvimTree "
end
vim.api.nvim_exec([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline.short()
  augroup END
]], false)
