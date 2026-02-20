-- Base16 Soft Focus Dark
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.base00 = "#050505"
M.base01 = "#0a0a0a"
M.base02 = "#1a1a1a"
M.base03 = "#888888"
M.base04 = "#bbbbbb"
M.base05 = "#f5f5f5"
M.base06 = "#ffffff"
M.base07 = "#ffffff"
M.base08 = "#ff4c6a"
M.base09 = "#f0d08a"
M.base0A = "#d4b87b"
M.base0B = "#99cc99"
M.base0C = "#4da6ff"
M.base0D = "#67b7f5"
M.base0E = "#d4a6a6"
M.base0F = "#c42847"

function M.setup()
    -- Remove existing highlights
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    vim.o.termguicolors = true
    vim.g.colors_name = "soft-focus-dark"

    local hi = function(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    -- Editor highlights
    hi("Normal", { fg = M.base05, bg = M.base00 })
    hi("Bold", { bold = true })
    hi("Debug", { fg = M.base08 })
    hi("Directory", { fg = M.base0D })
    hi("Error", { fg = M.base00, bg = M.base08 })
    hi("ErrorMsg", { fg = M.base08, bg = M.base00 })
    hi("Exception", { fg = M.base08 })
    hi("FoldColumn", { fg = M.base0C, bg = M.base01 })
    hi("Folded", { fg = M.base03, bg = M.base01 })
    hi("IncSearch", { fg = M.base01, bg = M.base09 })
    hi("Italic", { italic = true })
    hi("Macro", { fg = M.base08 })
    hi("MatchParen", { bg = M.base03 })
    hi("ModeMsg", { fg = M.base0B })
    hi("MoreMsg", { fg = M.base0B })
    hi("Question", { fg = M.base0D })
    hi("Search", { fg = M.base01, bg = M.base0A })
    hi("Substitute", { fg = M.base01, bg = M.base0A })
    hi("SpecialKey", { fg = M.base03 })
    hi("TooLong", { fg = M.base08 })
    hi("Underlined", { fg = M.base08, underline = true })
    hi("Visual", { bg = M.base02 })
    hi("VisualNOS", { fg = M.base08 })
    hi("WarningMsg", { fg = M.base08 })
    hi("WildMenu", { fg = M.base08, bg = M.base0A })
    hi("Title", { fg = M.base0D })
    hi("Conceal", { fg = M.base0D, bg = M.base00 })
    hi("Cursor", { fg = M.base00, bg = M.base05 })
    hi("NonText", { fg = M.base03 })
    hi("LineNr", { fg = M.base03, bg = M.base00 })
    hi("SignColumn", { fg = M.base03, bg = M.base00 })
    hi("StatusLine", { fg = M.base04, bg = M.base02 })
    hi("StatusLineNC", { fg = M.base03, bg = M.base01 })
    hi("VertSplit", { fg = M.base02, bg = M.base02 })
    hi("ColorColumn", { bg = M.base01 })
    hi("CursorColumn", { bg = M.base01 })
    hi("CursorLine", { bg = M.base01 })
    hi("CursorLineNr", { fg = M.base04, bg = M.base01 })
    hi("QuickFixLine", { bg = M.base01 })
    hi("PMenu", { fg = M.base05, bg = M.base01 })
    hi("PMenuSel", { fg = M.base01, bg = M.base05 })
    hi("TabLine", { fg = M.base03, bg = M.base01 })
    hi("TabLineFill", { fg = M.base03, bg = M.base01 })
    hi("TabLineSel", { fg = M.base0B, bg = M.base01 })

    -- Standard syntax highlighting
    hi("Boolean", { fg = M.base09 })
    hi("Character", { fg = M.base08 })
    hi("Comment", { fg = M.base03 })
    hi("Conditional", { fg = M.base0E })
    hi("Constant", { fg = M.base09 })
    hi("Define", { fg = M.base0E })
    hi("Delimiter", { fg = M.base0F })
    hi("Float", { fg = M.base09 })
    hi("Function", { fg = M.base0D })
    hi("Identifier", { fg = M.base08 })
    hi("Include", { fg = M.base0D })
    hi("Keyword", { fg = M.base0E })
    hi("Label", { fg = M.base0A })
    hi("Number", { fg = M.base09 })
    hi("Operator", { fg = M.base05 })
    hi("PreProc", { fg = M.base0A })
    hi("Repeat", { fg = M.base0A })
    hi("Special", { fg = M.base0C })
    hi("SpecialChar", { fg = M.base0F })
    hi("Statement", { fg = M.base08 })
    hi("StorageClass", { fg = M.base0A })
    hi("String", { fg = M.base0B })
    hi("Structure", { fg = M.base0E })
    hi("Tag", { fg = M.base0A })
    hi("Todo", { fg = M.base0A, bg = M.base01 })
    hi("Type", { fg = M.base0A })
    hi("Typedef", { fg = M.base0A })

    -- Diff highlighting
    hi("DiffAdd", { fg = M.base0B, bg = M.base01 })
    hi("DiffChange", { fg = M.base03, bg = M.base01 })
    hi("DiffDelete", { fg = M.base08, bg = M.base01 })
    hi("DiffText", { fg = M.base0D, bg = M.base01 })
    hi("DiffAdded", { fg = M.base0B, bg = M.base00 })
    hi("DiffFile", { fg = M.base08, bg = M.base00 })
    hi("DiffNewFile", { fg = M.base0B, bg = M.base00 })
    hi("DiffLine", { fg = M.base0D, bg = M.base00 })
    hi("DiffRemoved", { fg = M.base08, bg = M.base00 })

    -- Git highlighting
    hi("gitcommitOverflow", { fg = M.base08 })
    hi("gitcommitSummary", { fg = M.base0B })
    hi("gitcommitComment", { fg = M.base03 })
    hi("gitcommitUntracked", { fg = M.base03 })
    hi("gitcommitDiscarded", { fg = M.base03 })
    hi("gitcommitSelected", { fg = M.base03 })
    hi("gitcommitHeader", { fg = M.base0E })
    hi("gitcommitSelectedType", { fg = M.base0D })
    hi("gitcommitUnmergedType", { fg = M.base0D })
    hi("gitcommitDiscardedType", { fg = M.base0D })
    hi("gitcommitBranch", { fg = M.base09, bold = true })
    hi("gitcommitUntrackedFile", { fg = M.base0A })
    hi("gitcommitUnmergedFile", { fg = M.base08, bold = true })
    hi("gitcommitDiscardedFile", { fg = M.base08, bold = true })
    hi("gitcommitSelectedFile", { fg = M.base0B, bold = true })

    -- GitGutter highlighting
    hi("GitGutterAdd", { fg = M.base0B, bg = M.base00 })
    hi("GitGutterChange", { fg = M.base0D, bg = M.base00 })
    hi("GitGutterDelete", { fg = M.base08, bg = M.base00 })
    hi("GitGutterChangeDelete", { fg = M.base0E, bg = M.base00 })

    -- Spelling highlighting
    hi("SpellBad", { undercurl = true, sp = M.base08 })
    hi("SpellLocal", { undercurl = true, sp = M.base0C })
    hi("SpellCap", { undercurl = true, sp = M.base0D })
    hi("SpellRare", { undercurl = true, sp = M.base0E })

    -- LSP highlighting
    hi("DiagnosticError", { fg = M.base08 })
    hi("DiagnosticWarn", { fg = M.base0A })
    hi("DiagnosticInfo", { fg = M.base0D })
    hi("DiagnosticHint", { fg = M.base0C })
    hi("DiagnosticUnderlineError", { undercurl = true, sp = M.base08 })
    hi("DiagnosticUnderlineWarn", { undercurl = true, sp = M.base0A })
    hi("DiagnosticUnderlineInfo", { undercurl = true, sp = M.base0D })
    hi("DiagnosticUnderlineHint", { undercurl = true, sp = M.base0C })

    -- Treesitter highlighting
    hi("@variable", { fg = M.base05 })
    hi("@variable.builtin", { fg = M.base09 })
    hi("@variable.parameter", { fg = M.base08 })
    hi("@variable.member", { fg = M.base08 })
    hi("@constant", { fg = M.base09 })
    hi("@constant.builtin", { fg = M.base09 })
    hi("@constant.macro", { fg = M.base08 })
    hi("@module", { fg = M.base08 })
    hi("@label", { fg = M.base0A })
    hi("@string", { fg = M.base0B })
    hi("@string.regex", { fg = M.base0C })
    hi("@string.escape", { fg = M.base0C })
    hi("@character", { fg = M.base08 })
    hi("@number", { fg = M.base09 })
    hi("@boolean", { fg = M.base09 })
    hi("@float", { fg = M.base09 })
    hi("@function", { fg = M.base0D })
    hi("@function.builtin", { fg = M.base0D })
    hi("@function.macro", { fg = M.base08 })
    hi("@function.method", { fg = M.base0D })
    hi("@constructor", { fg = M.base0C })
    hi("@operator", { fg = M.base05 })
    hi("@keyword", { fg = M.base0E })
    hi("@keyword.function", { fg = M.base0E })
    hi("@keyword.operator", { fg = M.base0E })
    hi("@keyword.return", { fg = M.base0E })
    hi("@conditional", { fg = M.base0E })
    hi("@repeat", { fg = M.base0A })
    hi("@exception", { fg = M.base08 })
    hi("@include", { fg = M.base0D })
    hi("@type", { fg = M.base0A })
    hi("@type.builtin", { fg = M.base0A })
    hi("@attribute", { fg = M.base0A })
    hi("@property", { fg = M.base08 })
    hi("@comment", { fg = M.base03 })
    hi("@punctuation.delimiter", { fg = M.base0F })
    hi("@punctuation.bracket", { fg = M.base05 })
    hi("@punctuation.special", { fg = M.base08 })
    hi("@tag", { fg = M.base0A })
    hi("@tag.attribute", { fg = M.base0A })
    hi("@tag.delimiter", { fg = M.base0F })
end

return M
