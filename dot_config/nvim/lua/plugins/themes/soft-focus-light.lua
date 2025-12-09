-- Soft Focus Light Neovim Theme
-- Auto-generated from central color palette
-- Based on the Zed "Soft Focus Light" theme by Hamza Kamal

local M = {}

-- Define color palette (accessible outside setup function)
M.colors = {
    -- Base colors
    bg = "#ffffff",      -- background
    fg = "#000000",      -- text
    bg_alt = "#f5f5f5", -- element.background
    bg_elevated = "#eeeeee", -- elevated_surface.background
    fg_alt = "#666666",  -- text.muted
    fg_dim = "#888888",  -- text.placeholder

    -- Accent colors
    blue = "#448cbb",   -- primary accent
    blue_light = "#4da6ff", -- text.accent, function
    green = "#558855",  -- string, success
    mint = "#2d5f4f",   -- tertiary accent

    -- Syntax colors
    red = "#C42847",       -- base red
    red_bright = "#ff4c6a", -- keyword, error (bright)
    orange = "#b8943d",    -- type, warning
    orange_bright = "#D4B87B", -- bright yellow
    cyan = "#4da6ff",      -- function
    cyan_bright = "#67b7f5", -- bright cyan
    purple = "#9a6e6d",    -- magenta
    purple_bright = "#B88E8D", -- bright magenta

    -- UI colors
    border = "#d0d0d0",
    comment = "#888888",
    line_nr = "#888888",
    cursor_line = "#f0f0f0",
    visual = "#e0e0e0",
    search = "#d5d5d5",

    -- Git colors
    git_add = "#558855",
    git_change = "#b8943d",
    git_delete = "#C42847",

    -- Diagnostic colors
    error = "#ff4c6a",
    warn = "#b8943d",
    info = "#558855",
    hint = "#4da6ff",

    -- Terminal colors
    term_black = "#000000",
    term_red = "#C42847",
    term_green = "#558855",
    term_yellow = "#b8943d",
    term_blue = "#448cbb",
    term_magenta = "#9a6e6d",
    term_cyan = "#448cbb",
    term_white = "#f5f5f5",
    term_bright_black = "#666666",
    term_bright_red = "#ff4c6a",
    term_bright_green = "#77aa77",
    term_bright_yellow = "#D4B87B",
    term_bright_blue = "#4da6ff",
    term_bright_magenta = "#B88E8D",
    term_bright_cyan = "#67b7f5",
    term_bright_white = "#ffffff",
}

M.setup = function()
    -- Reset highlighting
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    -- Set theme name
    vim.g.colors_name = "soft-focus-light"

    -- Use the colors table
    local colors = M.colors

    -- Helper function to set highlight groups
    local function hl(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    -- Editor highlights
    hl("Normal", { fg = colors.fg, bg = colors.bg })
    hl("NormalFloat", { fg = colors.fg, bg = colors.bg_elevated })
    hl("NormalNC", { fg = colors.fg, bg = colors.bg })
    hl("LineNr", { fg = colors.line_nr })
    hl("CursorLine", { bg = colors.cursor_line })
    hl("CursorLineNr", { fg = colors.fg, bold = true })
    hl("Visual", { bg = colors.visual })
    hl("VisualNOS", { bg = colors.visual })
    hl("Search", { bg = colors.search })
    hl("IncSearch", { bg = colors.search, fg = colors.fg })
    hl("CurSearch", { bg = colors.blue, fg = colors.bg })
    hl("Substitute", { bg = colors.red_bright, fg = colors.bg })

    -- UI Elements
    hl("StatusLine", { fg = colors.fg, bg = colors.bg })
    hl("StatusLineNC", { fg = colors.fg_alt, bg = colors.bg_elevated })
    hl("TabLine", { fg = colors.fg_alt, bg = colors.bg })
    hl("TabLineFill", { bg = colors.bg })
    hl("TabLineSel", { fg = colors.fg, bg = colors.bg_elevated })
    hl("WinSeparator", { fg = colors.border })
    hl("VertSplit", { fg = colors.border })
    hl("Pmenu", { fg = colors.fg, bg = colors.bg_elevated })
    hl("PmenuSel", { fg = colors.fg, bg = colors.cursor_line, bold = true })
    hl("PmenuSbar", { bg = colors.bg_alt })
    hl("PmenuThumb", { bg = colors.border })
    hl("WildMenu", { fg = colors.fg, bg = colors.cursor_line })

    -- Folding
    hl("Folded", { fg = colors.comment, bg = colors.bg_elevated })
    hl("FoldColumn", { fg = colors.comment })

    -- Diff
    hl("DiffAdd", { bg = "#d0f5d0" })
    hl("DiffChange", { bg = "#f5f5d0" })
    hl("DiffDelete", { bg = "#f5d0d0" })
    hl("DiffText", { bg = "#b8943d" })

    -- Git signs
    hl("GitSignsAdd", { fg = colors.git_add })
    hl("GitSignsChange", { fg = colors.git_change })
    hl("GitSignsDelete", { fg = colors.git_delete })

    -- Syntax highlighting
    hl("Comment", { fg = colors.comment, italic = true })
    hl("Constant", { fg = colors.orange })
    hl("String", { fg = colors.green })
    hl("Character", { fg = colors.green })
    hl("Number", { fg = colors.orange })
    hl("Boolean", { fg = colors.red_bright })
    hl("Float", { fg = colors.orange })
    hl("Identifier", { fg = colors.fg })
    hl("Function", { fg = colors.cyan })
    hl("Statement", { fg = colors.red_bright })
    hl("Conditional", { fg = colors.red_bright })
    hl("Repeat", { fg = colors.red_bright })
    hl("Label", { fg = colors.red_bright })
    hl("Operator", { fg = colors.fg })
    hl("Keyword", { fg = colors.red_bright })
    hl("Exception", { fg = colors.red_bright })
    hl("PreProc", { fg = colors.red_bright })
    hl("Include", { fg = colors.red_bright })
    hl("Define", { fg = colors.red_bright })
    hl("Macro", { fg = colors.red_bright })
    hl("PreCondit", { fg = colors.red_bright })
    hl("Type", { fg = colors.orange })
    hl("StorageClass", { fg = colors.red_bright })
    hl("Structure", { fg = colors.orange })
    hl("Typedef", { fg = colors.orange })
    hl("Special", { fg = colors.cyan })
    hl("SpecialChar", { fg = colors.cyan })
    hl("Tag", { fg = colors.cyan })
    hl("Delimiter", { fg = colors.fg })
    hl("SpecialComment", { fg = colors.comment })
    hl("Debug", { fg = colors.red_bright })

    -- Treesitter highlights
    hl("@variable", { fg = colors.fg })
    hl("@variable.builtin", { fg = colors.red_bright })
    hl("@variable.parameter", { fg = colors.fg })
    hl("@variable.member", { fg = colors.fg })
    hl("@constant", { fg = colors.orange })
    hl("@constant.builtin", { fg = colors.red_bright })
    hl("@constant.macro", { fg = colors.orange })
    hl("@string", { fg = colors.green })
    hl("@string.escape", { fg = colors.cyan })
    hl("@string.special", { fg = colors.cyan })
    hl("@character", { fg = colors.green })
    hl("@character.special", { fg = colors.cyan })
    hl("@number", { fg = colors.orange })
    hl("@boolean", { fg = colors.red_bright })
    hl("@float", { fg = colors.orange })
    hl("@function", { fg = colors.cyan })
    hl("@function.builtin", { fg = colors.cyan })
    hl("@function.call", { fg = colors.cyan })
    hl("@function.macro", { fg = colors.red_bright })
    hl("@method", { fg = colors.cyan })
    hl("@method.call", { fg = colors.cyan })
    hl("@constructor", { fg = colors.orange })
    hl("@parameter", { fg = colors.fg })
    hl("@keyword", { fg = colors.red_bright })
    hl("@keyword.function", { fg = colors.red_bright })
    hl("@keyword.operator", { fg = colors.red_bright })
    hl("@keyword.return", { fg = colors.red_bright })
    hl("@conditional", { fg = colors.red_bright })
    hl("@repeat", { fg = colors.red_bright })
    hl("@debug", { fg = colors.red_bright })
    hl("@label", { fg = colors.red_bright })
    hl("@include", { fg = colors.red_bright })
    hl("@exception", { fg = colors.red_bright })
    hl("@type", { fg = colors.orange })
    hl("@type.builtin", { fg = colors.orange })
    hl("@type.qualifier", { fg = colors.red_bright })
    hl("@type.definition", { fg = colors.orange })
    hl("@storageclass", { fg = colors.red_bright })
    hl("@attribute", { fg = colors.cyan })
    hl("@field", { fg = colors.fg })
    hl("@property", { fg = colors.fg })
    hl("@operator", { fg = colors.fg })
    hl("@punctuation.delimiter", { fg = colors.fg })
    hl("@punctuation.bracket", { fg = colors.fg })
    hl("@punctuation.special", { fg = colors.cyan })
    hl("@comment", { fg = colors.comment, italic = true })
    hl("@comment.documentation", { fg = colors.comment, italic = true })
    hl("@tag", { fg = colors.red_bright })
    hl("@tag.attribute", { fg = colors.orange })
    hl("@tag.delimiter", { fg = colors.fg })

    -- LSP highlights
    hl("LspReferenceText", { bg = "#e8e8e8" })
    hl("LspReferenceRead", { bg = "#e8e8e8" })
    hl("LspReferenceWrite", { bg = "#e8e8e8" })
    hl("LspCodeLens", { fg = colors.comment })
    hl("LspCodeLensSeparator", { fg = colors.comment })

    -- Diagnostics
    hl("DiagnosticError", { fg = colors.error })
    hl("DiagnosticWarn", { fg = colors.warn })
    hl("DiagnosticInfo", { fg = colors.info })
    hl("DiagnosticHint", { fg = colors.hint })
    hl("DiagnosticVirtualTextError", { fg = colors.error, bg = colors.bg })
    hl("DiagnosticVirtualTextWarn", { fg = colors.warn, bg = colors.bg })
    hl("DiagnosticVirtualTextInfo", { fg = colors.info, bg = colors.bg })
    hl("DiagnosticVirtualTextHint", { fg = colors.hint, bg = colors.bg })
    hl("DiagnosticUnderlineError", { sp = colors.error, undercurl = true })
    hl("DiagnosticUnderlineWarn", { sp = colors.warn, undercurl = true })
    hl("DiagnosticUnderlineInfo", { sp = colors.info, undercurl = true })
    hl("DiagnosticUnderlineHint", { sp = colors.hint, undercurl = true })

    -- Telescope
    hl("TelescopeNormal", { fg = colors.fg, bg = colors.bg_elevated })
    hl("TelescopeBorder", { fg = colors.border, bg = colors.bg_elevated })
    hl("TelescopePromptBorder", { fg = colors.border, bg = colors.bg_elevated })
    hl("TelescopeResultsBorder", { fg = colors.border, bg = colors.bg_elevated })
    hl("TelescopePreviewBorder", { fg = colors.border, bg = colors.bg_elevated })
    hl("TelescopeSelection", { bg = colors.cursor_line, bold = true })
    hl("TelescopeSelectionCaret", { fg = colors.cyan })
    hl("TelescopeMultiSelection", { fg = colors.cyan })
    hl("TelescopeMatching", { fg = colors.cyan, bold = true })

    -- NvimTree
    hl("NvimTreeNormal", { fg = colors.fg, bg = colors.bg })
    hl("NvimTreeRootFolder", { fg = colors.cyan, bold = true })
    hl("NvimTreeGitDirty", { fg = colors.git_change })
    hl("NvimTreeGitNew", { fg = colors.git_add })
    hl("NvimTreeGitDeleted", { fg = colors.git_delete })
    hl("NvimTreeSpecialFile", { fg = colors.cyan })
    hl("NvimTreeIndentMarker", { fg = colors.comment })
    hl("NvimTreeImageFile", { fg = colors.purple })
    hl("NvimTreeSymlink", { fg = colors.cyan })

    -- WhichKey
    hl("WhichKey", { fg = colors.cyan })
    hl("WhichKeyGroup", { fg = colors.cyan })
    hl("WhichKeyDesc", { fg = colors.fg })
    hl("WhichKeySeperator", { fg = colors.comment })
    hl("WhichKeySeparator", { fg = colors.comment })
    hl("WhichKeyFloat", { bg = colors.bg_elevated })
    hl("WhichKeyValue", { fg = colors.comment })

    -- Indent Blankline
    hl("IndentBlanklineChar", { fg = "#d0d0d0" })
    hl("IndentBlanklineContextChar", { fg = "#888888" })
    hl("IndentBlanklineContextStart", { sp = colors.blue, underline = true })

    -- Alpha (dashboard)
    hl("AlphaShortcut", { fg = colors.cyan })
    hl("AlphaHeader", { fg = colors.cyan })
    hl("AlphaHeaderLabel", { fg = colors.orange })
    hl("AlphaFooter", { fg = colors.comment })
    hl("AlphaButtons", { fg = colors.fg })

    -- Notify
    hl("NotifyERRORBorder", { fg = colors.error })
    hl("NotifyWARNBorder", { fg = colors.warn })
    hl("NotifyINFOBorder", { fg = colors.info })
    hl("NotifyDEBUGBorder", { fg = colors.comment })
    hl("NotifyTRACEBorder", { fg = colors.hint })
    hl("NotifyERRORIcon", { fg = colors.error })
    hl("NotifyWARNIcon", { fg = colors.warn })
    hl("NotifyINFOIcon", { fg = colors.info })
    hl("NotifyDEBUGIcon", { fg = colors.comment })
    hl("NotifyTRACEIcon", { fg = colors.hint })
    hl("NotifyERRORTitle", { fg = colors.error })
    hl("NotifyWARNTitle", { fg = colors.warn })
    hl("NotifyINFOTitle", { fg = colors.info })
    hl("NotifyDEBUGTitle", { fg = colors.comment })
    hl("NotifyTRACETitle", { fg = colors.hint })

    -- Bufferline
    hl("BufferLineIndicatorSelected", { fg = colors.blue })
    hl("BufferLineFill", { bg = colors.bg })

    -- Neo-tree
    hl("NeoTreeNormal", { fg = colors.fg, bg = colors.bg })
    hl("NeoTreeNormalNC", { fg = colors.fg, bg = colors.bg })
    hl("NeoTreeDirectoryName", { fg = colors.cyan })
    hl("NeoTreeDirectoryIcon", { fg = colors.cyan })
    hl("NeoTreeRootName", { fg = colors.cyan, bold = true })
    hl("NeoTreeGitAdded", { fg = colors.git_add })
    hl("NeoTreeGitDeleted", { fg = colors.git_delete })
    hl("NeoTreeGitModified", { fg = colors.git_change })
    hl("NeoTreeGitConflict", { fg = colors.error })
    hl("NeoTreeGitUntracked", { fg = colors.comment })
    hl("NeoTreeIndentMarker", { fg = colors.comment })
    hl("NeoTreeExpander", { fg = colors.comment })

    -- Floating windows (generic)
    hl("FloatBorder", { fg = colors.border, bg = colors.bg })
    hl("FloatTitle", { fg = colors.blue_light, bg = colors.bg, bold = true })

    -- nvim-cmp (completion)
    hl("CmpItemAbbrMatch", { fg = colors.cyan, bold = true })
    hl("CmpItemAbbrMatchFuzzy", { fg = colors.cyan, bold = true })
    hl("CmpItemKind", { fg = colors.orange })
    hl("CmpItemMenu", { fg = colors.comment })
    hl("CmpItemAbbrDeprecated", { fg = colors.comment, strikethrough = true })

    -- nvim-cmp kind-specific highlights (semantic coloring like Zed)
    hl("CmpItemKindText", { fg = colors.fg })
    hl("CmpItemKindMethod", { fg = colors.cyan })
    hl("CmpItemKindFunction", { fg = colors.cyan })
    hl("CmpItemKindConstructor", { fg = colors.orange })
    hl("CmpItemKindField", { fg = colors.fg })
    hl("CmpItemKindVariable", { fg = colors.fg })
    hl("CmpItemKindClass", { fg = colors.orange })
    hl("CmpItemKindInterface", { fg = colors.orange })
    hl("CmpItemKindModule", { fg = colors.orange })
    hl("CmpItemKindProperty", { fg = colors.fg })
    hl("CmpItemKindUnit", { fg = colors.orange })
    hl("CmpItemKindValue", { fg = colors.orange })
    hl("CmpItemKindEnum", { fg = colors.orange })
    hl("CmpItemKindKeyword", { fg = colors.red_bright })
    hl("CmpItemKindSnippet", { fg = colors.cyan })
    hl("CmpItemKindColor", { fg = colors.green })
    hl("CmpItemKindFile", { fg = colors.fg })
    hl("CmpItemKindReference", { fg = colors.fg })
    hl("CmpItemKindFolder", { fg = colors.cyan })
    hl("CmpItemKindEnumMember", { fg = colors.orange })
    hl("CmpItemKindConstant", { fg = colors.orange })
    hl("CmpItemKindStruct", { fg = colors.orange })
    hl("CmpItemKindEvent", { fg = colors.orange })
    hl("CmpItemKindOperator", { fg = colors.fg })
    hl("CmpItemKindTypeParameter", { fg = colors.orange })
    hl("CmpItemKindCopilot", { fg = colors.cyan })
    hl("CmpItemKindCodeium", { fg = colors.cyan })
    hl("CmpItemKindTabNine", { fg = colors.cyan })

    -- Terminal colors
    vim.g.terminal_color_0 = colors.term_black
    vim.g.terminal_color_1 = colors.term_red
    vim.g.terminal_color_2 = colors.term_green
    vim.g.terminal_color_3 = colors.term_yellow
    vim.g.terminal_color_4 = colors.term_blue
    vim.g.terminal_color_5 = colors.term_magenta
    vim.g.terminal_color_6 = colors.term_cyan
    vim.g.terminal_color_7 = colors.term_white
    vim.g.terminal_color_8 = colors.term_bright_black
    vim.g.terminal_color_9 = colors.term_bright_red
    vim.g.terminal_color_10 = colors.term_bright_green
    vim.g.terminal_color_11 = colors.term_bright_yellow
    vim.g.terminal_color_12 = colors.term_bright_blue
    vim.g.terminal_color_13 = colors.term_bright_magenta
    vim.g.terminal_color_14 = colors.term_bright_cyan
    vim.g.terminal_color_15 = colors.term_bright_white
end

return M
