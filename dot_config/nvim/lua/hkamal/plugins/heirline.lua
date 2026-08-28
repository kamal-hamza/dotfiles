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

local function hl_bg(name, fallback)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl.bg then
        return string.format("#%06x", hl.bg)
    end
    return fallback
end

-- accent palette pulled from semantic highlight groups, so pills track
-- whatever colorscheme is active instead of one hardcoded hex per mode
local palette = {
    purple = function() return hl_fg("Keyword", "#bb9af7") end,
    green = function() return hl_fg("String", "#9ece6a") end,
    blue = function() return hl_fg("Function", "#7aa2f7") end,
    red = function() return hl_fg("DiagnosticError", "#f7768e") end,
    yellow = function() return hl_fg("DiagnosticWarn", "#e0af68") end,
    orange = function() return hl_fg("Constant", "#ff9e64") end,
    cyan = function() return hl_fg("Special", "#7dcfff") end,
}

local pill_text = function() return hl_bg("StatusLine", "#1a1b26") end

-- wraps a component in a rounded, colored pill: two cap glyphs (colored fg,
-- transparent bg so they blend into the statusline) around the content
-- (dark fg on colored bg). condition/update on `component` propagate to the
-- whole pill so caps never render orphaned when the content is hidden.
-- U+E0B6/U+E0B4 (powerline "left/right half circle thick"), written as
-- explicit codepoint escapes -- the literal glyphs are invisible in most
-- editors/terminals and are easy to accidentally drop or mistake for
-- zero-width characters when typed directly.
local PILL_CAP_LEFT = "\u{e0b6}"
local PILL_CAP_RIGHT = "\u{e0b4}"

local function Pill(component, color)
    return {
        condition = component.condition,
        update = component.update,
        {
            provider = PILL_CAP_LEFT,
            hl = function() return { fg = color(), bg = "none" } end,
        },
        {
            provider = component.provider,
            hl = function() return { fg = pill_text(), bg = color(), bold = true } end,
        },
        {
            provider = PILL_CAP_RIGHT,
            hl = function() return { fg = color(), bg = "none" } end,
        },
    }
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

local mode_colors = {
    n = palette.purple,
    no = palette.purple,
    nov = palette.purple,
    noV = palette.purple,
    i = palette.green,
    ic = palette.green,
    ix = palette.green,
    v = palette.blue,
    V = palette.blue,
    ["\22"] = palette.blue,
    R = palette.red,
    Rv = palette.red,
    r = palette.red,
    rm = palette.red,
    c = palette.yellow,
    cv = palette.yellow,
    ce = palette.yellow,
    s = palette.orange,
    S = palette.orange,
    ["\19"] = palette.orange,
    t = palette.cyan,
}

local Mode = Pill({
    provider = function()
        local m = vim.fn.mode()
        return " " .. (mode_names[m] or m:upper()) .. " "
    end,
    update = { "ModeChanged" },
}, function()
    local color = mode_colors[vim.fn.mode()] or palette.purple
    return color()
end)

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

local Diagnostics = {
    condition = conditions.has_diagnostics,
    init = function(self)
        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    {
        provider = function(self)
            return self.errors > 0 and (" 󰅚 " .. self.errors)
        end,
        hl = { fg = hl_fg("DiagnosticError", "#e06c75") },
    },
    {
        provider = function(self)
            return self.warnings > 0 and (" 󰀪 " .. self.warnings)
        end,
        hl = { fg = hl_fg("DiagnosticWarn", "#e5c07b") },
    },
    {
        provider = function(self)
            return self.info > 0 and (" 󰋽 " .. self.info)
        end,
        hl = { fg = hl_fg("DiagnosticInfo", "#61afef") },
    },
    {
        provider = function(self)
            return self.hints > 0 and (" 󰌶 " .. self.hints)
        end,
        hl = { fg = hl_fg("DiagnosticHint", "#98c379") },
    },
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
        return " \u{e0a0} " .. branch .. (state and (" (" .. state .. ")") or "")
    end,
    hl = function()
        return { fg = hl_fg("Comment", "#565f89") }
    end,
}

local Ruler = {
    provider = "%2l:%-2c  %P",
    hl = function()
        return { fg = hl_fg("Comment", "#565f89") }
    end,
}

local FileType = Pill({
    condition = function()
        return vim.bo.filetype ~= ""
    end,
    provider = function()
        return " " .. vim.bo.filetype:upper() .. " "
    end,
}, palette.blue)

local Space = { provider = " " }
local Align = { provider = "%=" }

heirline.setup({
    statusline = {
        condition = function()
            return not conditions.buffer_matches({
                buftype = { "nofile", "terminal" },
                filetype = { "netrw", "toggleterm" },
            })
        end,
        Mode,
        Space,
        FileName,
        Space,
        GitBranch,
        Align,
        Diagnostics,
        Space,
        Ruler,
        Space,
        FileType,
    },
})
