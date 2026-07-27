vim.pack.add({ "https://github.com/rebelot/heirline.nvim" })

local heirline = require("heirline")
local conditions = require("heirline.conditions")

-- pull a color out of the active colorscheme instead of hardcoding hex values
local function hl_fg(name, fallback)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl.fg then
        return string.format("#%06x", hl.fg)
    end
    return fallback
end

local mode_names = {
    n = "NORMAL",
    no = "NORMAL",
    nov = "NORMAL",
    noV = "NORMAL",
    i = "INSERT",
    ic = "INSERT",
    ix = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    R = "REPLACE",
    Rv = "V-REPLACE",
    c = "COMMAND",
    cv = "EX",
    ce = "EX",
    r = "REPLACE",
    rm = "MORE",
    s = "SELECT",
    S = "S-LINE",
    ["\19"] = "S-BLOCK",
    t = "TERMINAL",
}

-- no custom colors here -- inherits whatever StatusLine the colorscheme defines
local Mode = {
    provider = function()
        local m = vim.fn.mode()
        return " " .. (mode_names[m] or m:upper()) .. " "
    end,
    update = { "ModeChanged" },
}

local FileName = {
    init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
    end,
    {
        init = function(self)
            local extension = vim.fn.fnamemodify(self.filename, ":e")
            self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(
                vim.fn.fnamemodify(self.filename, ":t"),
                extension,
                { default = true }
            )
        end,
        provider = function(self)
            return self.icon and (self.icon .. " ")
        end,
        hl = function(self)
            return { fg = self.icon_color }
        end,
    },
    {
        provider = function(self)
            local filename = vim.fn.fnamemodify(self.filename, ":.")
            if filename == "" then
                filename = "[No Name]"
            end
            return filename
        end,
    },
}

local GitDiff = {
    condition = function()
        return vim.b.gitsigns_status_dict ~= nil
    end,
    init = function(self)
        self.status = vim.b.gitsigns_status_dict
    end,
    {
        provider = function(self)
            local n = self.status.added
            return n and n > 0 and (" [+]" .. n)
        end,
        hl = { fg = hl_fg("GitSignsAdd", hl_fg("DiffAdd", "#98c379")) },
    },
    {
        provider = function(self)
            local n = self.status.changed
            return n and n > 0 and (" [•]" .. n)
        end,
        hl = { fg = hl_fg("GitSignsChange", hl_fg("DiffChange", "#61afef")) },
    },
    {
        provider = function(self)
            local n = self.status.removed
            return n and n > 0 and (" [-]" .. n)
        end,
        hl = { fg = hl_fg("GitSignsDelete", hl_fg("DiffDelete", "#e06c75")) },
    },
}

local Diagnostics = {
    condition = conditions.has_diagnostics,
    init = function(self)
        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    {
        provider = function(self)
            return self.errors > 0 and (" [x]" .. self.errors)
        end,
        hl = { fg = hl_fg("DiagnosticError", "#e06c75") },
    },
    {
        provider = function(self)
            return self.warnings > 0 and (" [!]" .. self.warnings)
        end,
        hl = { fg = hl_fg("DiagnosticWarn", "#e5c07b") },
    },
}

local Ruler = {
    provider = " %l:%c ",
}

local ScrollPercent = {
    provider = "%P ",
}

local LineCount = {
    provider = function()
        return tostring(vim.api.nvim_buf_line_count(0))
    end,
}

local LspActive = {
    condition = conditions.lsp_attached,
    provider = function()
        return " " .. vim.bo.filetype
    end,
}

local Indent = {
    provider = function()
        local expandtab = vim.bo.expandtab
        local size = expandtab and vim.bo.shiftwidth or vim.bo.tabstop
        if size == 0 then
            size = vim.bo.tabstop
        end
        return "≡ " .. (expandtab and "SPACES" or "TABS") .. " " .. size
    end,
}

local Encoding = {
    provider = function()
        local enc = vim.bo.fileencoding
        if enc == "" then
            enc = vim.o.encoding
        end
        return enc:upper()
    end,
}

local function git_dir_state(bufname)
    local git_path = vim.fs.find(".git", { upward = true, path = vim.fn.fnamemodify(bufname, ":h") })[1]
    if not git_path then
        return nil
    end

    local dir = git_path
    local stat = vim.uv.fs_stat(git_path)
    if stat and stat.type == "file" then
        local content = table.concat(vim.fn.readfile(git_path), "")
        dir = content:match("gitdir:%s*(.+)")
    end
    if not dir then
        return nil
    end

    if vim.uv.fs_stat(dir .. "/rebase-merge") or vim.uv.fs_stat(dir .. "/rebase-apply") then
        return "rebasing"
    elseif vim.uv.fs_stat(dir .. "/MERGE_HEAD") then
        return "merging"
    elseif vim.uv.fs_stat(dir .. "/CHERRY_PICK_HEAD") then
        return "cherry-picking"
    elseif vim.uv.fs_stat(dir .. "/BISECT_LOG") then
        return "bisecting"
    end
    return nil
end

local GitBranch = {
    condition = function()
        return vim.b.gitsigns_head ~= nil and vim.b.gitsigns_head ~= ""
    end,
    provider = function()
        local branch = vim.b.gitsigns_head
        local state = git_dir_state(vim.api.nvim_buf_get_name(0))
        return " " .. branch .. (state and (" (" .. state .. ")") or "")
    end,
}

local Space = { provider = " " }
local Align = { provider = "%=" }

heirline.setup({
    statusline = {
        condition = function()
            return not conditions.buffer_matches({
                buftype = { "nofile", "terminal" },
                filetype = { "NvimTree", "toggleterm" },
            })
        end,
        Mode,
        Space,
        FileName,
        GitDiff,
        Align,
        Diagnostics,
        Space,
        Ruler,
        ScrollPercent,
        Space,
        LineCount,
        Space,
        LspActive,
        Space,
        Indent,
        Space,
        Encoding,
        Space,
        GitBranch,
    },
})
