vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "soft_focus_dark"

local c = {
    bg = "#000000", fg = "#f5f5f5",
    cursorline = "#151515", linenr = "#555555", cursorlinenr = "#f5f5f5",
    visual = "#67b7f5", search_active = "#ff4c6a", border = "#151515",
    comment = { fg = "#888888", italic = true },
    keyword = { fg = "#ff4c6a", italic = true },
    func = { fg = "#67b7f5", bold = true },
    string = { fg = "#99cc99" },
    constant = { fg = "#d4b87b" },
    type = { fg = "#d4b87b" },
    variable = { fg = "#f5f5f5" },
    operator = { fg = "#bbbbbb" },
    punctuation = { fg = "#bbbbbb" },
    special = { fg = "#d4a6a6" },
    error = "#ff4c6a", warning = "#f0a36a", info = "#4da6ff", hint = "#555555",
    vcs_added = "#99cc99", vcs_modified = "#d4b87b", vcs_deleted = "#ff4c6a",
}

local groups = {
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.cursorline },
    FloatBorder = { fg = c.border, bg = c.cursorline },
    CursorLine = { bg = c.cursorline },
    CursorColumn = { bg = c.cursorline },
    ColorColumn = { bg = c.cursorline },
    LineNr = { fg = c.linenr },
    CursorLineNr = { fg = c.cursorlinenr, bold = true },
    VertSplit = { fg = c.border },
    WinSeparator = { fg = c.border },
    Visual = { bg = c.visual, fg = c.bg },
    Search = { bg = c.search_active, fg = c.bg },
    IncSearch = { bg = c.search_active, fg = c.bg },
    MatchParen = { bg = c.border, bold = true },
    Pmenu = { fg = c.fg, bg = c.cursorline },
    PmenuSel = { fg = c.bg, bg = c.visual },
    StatusLine = { fg = c.fg, bg = c.cursorline },
    StatusLineNC = { fg = c.linenr, bg = c.bg },
    Comment = c.comment, Constant = c.constant, String = c.string,
    Character = c.string, Number = c.constant, Boolean = c.constant,
    Float = c.constant, Identifier = c.variable, Function = c.func,
    Statement = c.keyword, Conditional = c.keyword, Repeat = c.keyword,
    Label = c.variable, Operator = c.operator, Keyword = c.keyword,
    Exception = c.keyword, PreProc = c.keyword, Include = c.keyword,
    Define = c.keyword, Macro = c.special, Type = c.type,
    StorageClass = c.keyword, Structure = c.type, Typedef = c.type,
    Special = c.special, Delimiter = c.punctuation,
    ["@variable"] = c.variable, ["@variable.builtin"] = c.variable,
    ["@variable.parameter"] = { fg = c.variable.fg, italic = true },
    ["@variable.member"] = c.variable, ["@function"] = c.func,
    ["@function.builtin"] = c.func, ["@function.macro"] = c.func,
    ["@keyword"] = c.keyword, ["@string"] = c.string,
    ["@string.escape"] = c.special, ["@string.regexp"] = c.special,
    ["@type"] = c.type, ["@type.builtin"] = c.type, ["@constructor"] = c.func,
    ["@property"] = c.variable, ["@tag"] = { fg = c.type.fg },
    ["@tag.attribute"] = c.variable, ["@tag.delimiter"] = c.punctuation,
    DiagnosticError = { fg = c.error }, DiagnosticWarn = { fg = c.warning },
    DiagnosticInfo = { fg = c.info }, DiagnosticHint = { fg = c.hint },
    DiagnosticUnderlineError = { undercurl = true, sp = c.error },
    DiagnosticUnderlineWarn = { undercurl = true, sp = c.warning },
    DiagnosticUnderlineInfo = { undercurl = true, sp = c.info },
    DiagnosticUnderlineHint = { undercurl = true, sp = c.hint },
    DiffAdd = { fg = c.vcs_added }, DiffChange = { fg = c.vcs_modified },
    DiffDelete = { fg = c.vcs_deleted }, DiffText = { fg = c.bg, bg = c.vcs_modified },
    GitSignsAdd = { fg = c.vcs_added }, GitSignsChange = { fg = c.vcs_modified },
    GitSignsDelete = { fg = c.vcs_deleted },
}

for group, settings in pairs(groups) do
    vim.api.nvim_set_hl(0, group, settings)
end
