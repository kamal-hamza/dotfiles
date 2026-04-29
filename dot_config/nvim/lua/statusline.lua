-- heirline nvim
vim.opt.laststatus = 3
local conditions = require("heirline.conditions")
local Mode = {
  provider = function()
    local mode_map = {
      n = "NORMAL",
      i = "INSERT",
      v = "VISUAL",
      V = "V-LINE",
      [""] = "V-BLOCK",
      c = "COMMAND",
      t = "TERMINAL",
      R = "REPLACE",
    }

    local mode = vim.fn.mode(1)
    return " " .. (mode_map[mode] or mode):upper() .. " "
  end,
  hl = { bold = true },
}

local LSP = {
  condition = function()
    return next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil
  end,
  provider = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
      return ""
    end

    local names = {}
    for _, client in ipairs(clients) do
      table.insert(names, client.name)
    end

    return " " .. table.concat(names, ", ") .. " "
  end,
}

local FileName = {
  provider = function()
    local name = vim.fn.expand("%:t")
    if name == "" then
      return "[No Name]"
    end
    return name
  end,
}

local FileFlags = {
  provider = function()
    local flags = ""
    if vim.bo.modified then flags = flags .. " [+]" end
    if not vim.bo.modifiable or vim.bo.readonly then flags = flags .. " [-]" end
    return flags
  end,
}

local Diagnostics = {
  condition = conditions.has_diagnostics,

  init = function(self)
    local counts = vim.diagnostic.count(0)

    self.errors = counts[vim.diagnostic.severity.ERROR] or 0
    self.warnings = counts[vim.diagnostic.severity.WARN] or 0
    self.info = counts[vim.diagnostic.severity.INFO] or 0
  end,

  provider = function(self)
    local parts = {}

    if self.errors > 0 then
      table.insert(parts, "E:" .. self.errors)
    end
    if self.warnings > 0 then
      table.insert(parts, "W:" .. self.warnings)
    end
    if self.info > 0 then
      table.insert(parts, "I:" .. self.info)
    end

    if #parts == 0 then
      return ""
    end

    return " " .. table.concat(parts, " ") .. " "
  end,
}

local GitBranch = {
  condition = function()
    return conditions.is_git_repo() and vim.b.gitsigns_head ~= nil
  end,
  provider = function()
    return " " .. vim.b.gitsigns_head .. " "
  end,
}

local Align = { provider = "%=" }
local Space = { provider = " " }

local StatusLine = {
  Mode,
  Space,

  LSP,

  Align,

  FileName,
  FileFlags,

  Align,

  Diagnostics,
  GitBranch,
}

require("heirline").setup({
  statusline = StatusLine,
})


