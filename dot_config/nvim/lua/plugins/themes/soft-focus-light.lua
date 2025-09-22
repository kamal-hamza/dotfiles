-- Soft Focus Neovim Theme
-- Based on the Zed "Soft Focus Light" theme by Hamza Kamal

local M = {}

M.setup = function()
    -- Reset highlighting
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    -- Set theme name
    vim.g.colors_name = "soft-focus-light"

    -- Define color palette
    local colors = {
        -- Base colors
        bg = "#fbfcf8",       -- background
        fg = "#000000",       -- text
        bg_alt = "#f0f0f099", -- element.background
        fg_alt = "#555555",   -- text.muted

        -- Accent colors
        blue = "#067BC2",  -- primary accent
        green = "#334139", -- secondary accent
        mint = "#D5F2E3",  -- tertiary accent

        -- Syntax colors
        red = "#C42847",    -- keyword, error
        orange = "#D4B87B", -- type, warning
        yellow = "#D4B87B", -- type
        cyan = "#448cbb",   -- function
        purple = "#B88E8D", -- magenta

        -- UI colors
        border = "#0000001A",
        comment = "#999999",
        line_nr = "#bbbbbb",
        cursor_line = "#f0f8ff80",
        visual = "#067BC230",
        search = "#067BC24D",

        -- Git colors
        git_add = "#77aa77",
        git_change = "#D4B87B",
        git_delete = "#C42847",

        -- Diagnostic colors
        error = "#C42847",
        warn = "#D4B87B",
        info = "#77AA77",
        hint = "#067BC2",

        -- Terminal colors
        term_black = "#555555",
        term_red = "#C42847",
        term_green = "#334139",
        term_yellow = "#D4B87B",
        term_blue = "#067BC2",
        term_magenta = "#B88E8D",
        term_cyan = "#067BC2",
        term_white = "#000000",
    }

    -- Helper function to set highlight groups
    local function hl(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    -- Editor highlights
    hl("Normal", { fg = colors.fg, bg = colors.bg })
    hl("NormalFloat", { fg = colors.fg, bg = colors.bg })
    hl("NormalNC", { fg = colors.fg, bg = colors.bg })
    hl("LineNr", { fg = colors.line_nr })
    hl("CursorLine", { bg = colors.cursor_line })
    hl("CursorLineNr", { fg = colors.fg, bold = true })
    hl("Visual", { bg = colors.visual })
    hl("VisualNOS", { bg = colors.visual })
    hl("Search", { bg = colors.search })
    hl("IncSearch", { bg = colors.search, fg = colors.fg })
    hl("CurSearch", { bg = colors.blue, fg = colors.bg })
    hl("Substitute", { bg = colors.red, fg = colors.bg })

    -- UI Elements
    hl("StatusLine", { fg = colors.fg, bg = colors.bg })
    hl("StatusLineNC", { fg = colors.fg_alt, bg = colors.bg_alt })
    hl("TabLine", { fg = colors.fg_alt, bg = colors.bg })
    hl("TabLineFill", { bg = colors.bg })
    hl("TabLineSel", { fg = colors.fg, bg = colors.cursor_line })
    hl("WinSeparator", { fg = colors.border })
    hl("VertSplit", { fg = colors.border })
    hl("Pmenu", { fg = colors.fg, bg = colors.bg_alt })
    hl("PmenuSel", { fg = colors.fg, bg = colors.visual })
    hl("PmenuSbar", { bg = colors.bg_alt })
    hl("PmenuThumb", { bg = colors.blue })
    hl("WildMenu", { fg = colors.fg, bg = colors.visual })

    -- Folding
    hl("Folded", { fg = colors.comment, bg = colors.bg_alt })
    hl("FoldColumn", { fg = colors.comment })

    -- Diff
    hl("DiffAdd", { bg = "#77aa7726" })
    hl("DiffChange", { bg = "#D4B87B26" })
    hl("DiffDelete", { bg = "#C4284726" })
    hl("DiffText", { bg = "#D4B87B" })

    -- Git signs
    hl("GitSignsAdd", { fg = colors.git_add })
    hl("GitSignsChange", { fg = colors.git_change })
    hl("GitSignsDelete", { fg = colors.git_delete })

    -- Syntax highlighting
    hl("Comment", { fg = colors.comment, italic = true })
    hl("Constant", { fg = colors.orange })
    hl("String", { fg = colors.git_add })
    hl("Character", { fg = colors.git_add })
    hl("Number", { fg = colors.orange })
    hl("Boolean", { fg = colors.red })
    hl("Float", { fg = colors.orange })
    hl("Identifier", { fg = colors.fg })
    hl("Function", { fg = colors.cyan })
    hl("Statement", { fg = colors.red })
    hl("Conditional", { fg = colors.red })
    hl("Repeat", { fg = colors.red })
    hl("Label", { fg = colors.red })
    hl("Operator", { fg = colors.fg })
    hl("Keyword", { fg = colors.red })
    hl("Exception", { fg = colors.red })
    hl("PreProc", { fg = colors.red })
    hl("Include", { fg = colors.red })
    hl("Define", { fg = colors.red })
    hl("Macro", { fg = colors.red })
    hl("PreCondit", { fg = colors.red })
    hl("Type", { fg = colors.orange })
    hl("StorageClass", { fg = colors.red })
    hl("Structure", { fg = colors.orange })
    hl("Typedef", { fg = colors.orange })
    hl("Special", { fg = colors.blue })
    hl("SpecialChar", { fg = colors.blue })
    hl("Tag", { fg = colors.blue })
    hl("Delimiter", { fg = colors.fg })
    hl("SpecialComment", { fg = colors.comment })
    hl("Debug", { fg = colors.red })

    -- Treesitter highlights
    hl("@variable", { fg = colors.fg })
    hl("@variable.builtin", { fg = colors.red })
    hl("@variable.parameter", { fg = colors.fg })
    hl("@variable.member", { fg = colors.fg })
    hl("@constant", { fg = colors.orange })
    hl("@constant.builtin", { fg = colors.red })
    hl("@constant.macro", { fg = colors.orange })
    hl("@string", { fg = colors.git_add })
    hl("@string.escape", { fg = colors.blue })
    hl("@string.special", { fg = colors.blue })
    hl("@character", { fg = colors.git_add })
    hl("@character.special", { fg = colors.blue })
    hl("@number", { fg = colors.orange })
    hl("@boolean", { fg = colors.red })
    hl("@float", { fg = colors.orange })
    hl("@function", { fg = colors.cyan })
    hl("@function.builtin", { fg = colors.cyan })
    hl("@function.call", { fg = colors.cyan })
    hl("@function.macro", { fg = colors.red })
    hl("@method", { fg = colors.cyan })
    hl("@method.call", { fg = colors.cyan })
    hl("@constructor", { fg = colors.orange })
    hl("@parameter", { fg = colors.fg })
    hl("@keyword", { fg = colors.red })
    hl("@keyword.function", { fg = colors.red })
    hl("@keyword.operator", { fg = colors.red })
    hl("@keyword.return", { fg = colors.red })
    hl("@conditional", { fg = colors.red })
    hl("@repeat", { fg = colors.red })
    hl("@debug", { fg = colors.red })
    hl("@label", { fg = colors.red })
    hl("@include", { fg = colors.red })
    hl("@exception", { fg = colors.red })
    hl("@type", { fg = colors.orange })
    hl("@type.builtin", { fg = colors.orange })
    hl("@type.qualifier", { fg = colors.red })
    hl("@type.definition", { fg = colors.orange })
    hl("@storageclass", { fg = colors.red })
    hl("@attribute", { fg = colors.blue })
    hl("@field", { fg = colors.fg })
    hl("@property", { fg = colors.fg })
    hl("@operator", { fg = colors.fg })
    hl("@punctuation.delimiter", { fg = colors.fg })
    hl("@punctuation.bracket", { fg = colors.fg })
    hl("@punctuation.special", { fg = colors.blue })
    hl("@comment", { fg = colors.comment, italic = true })
    hl("@comment.documentation", { fg = colors.comment, italic = true })
    hl("@tag", { fg = colors.red })
    hl("@tag.attribute", { fg = colors.orange })
    hl("@tag.delimiter", { fg = colors.fg })

    -- LSP highlights
    hl("LspReferenceText", { bg = "#d5f2e029" })
    hl("LspReferenceRead", { bg = "#d5f2e029" })
    hl("LspReferenceWrite", { bg = "#d5f2e029" })
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
    hl("TelescopeNormal", { fg = colors.fg, bg = colors.bg })
    hl("TelescopeBorder", { fg = colors.blue, bg = colors.bg })
    hl("TelescopePromptBorder", { fg = colors.blue, bg = colors.bg })
    hl("TelescopeResultsBorder", { fg = colors.blue, bg = colors.bg })
    hl("TelescopePreviewBorder", { fg = colors.blue, bg = colors.bg })
    hl("TelescopeSelection", { bg = colors.visual })
    hl("TelescopeSelectionCaret", { fg = colors.blue })
    hl("TelescopeMultiSelection", { fg = colors.blue })
    hl("TelescopeMatching", { fg = colors.blue, bold = true })

    -- NvimTree
    hl("NvimTreeNormal", { fg = colors.fg, bg = colors.bg })
    hl("NvimTreeRootFolder", { fg = colors.blue, bold = true })
    hl("NvimTreeGitDirty", { fg = colors.git_change })
    hl("NvimTreeGitNew", { fg = colors.git_add })
    hl("NvimTreeGitDeleted", { fg = colors.git_delete })
    hl("NvimTreeSpecialFile", { fg = colors.blue })
    hl("NvimTreeIndentMarker", { fg = colors.comment })
    hl("NvimTreeImageFile", { fg = colors.purple })
    hl("NvimTreeSymlink", { fg = colors.cyan })

    -- WhichKey
    hl("WhichKey", { fg = colors.blue })
    hl("WhichKeyGroup", { fg = colors.cyan })
    hl("WhichKeyDesc", { fg = colors.fg })
    hl("WhichKeySeperator", { fg = colors.comment })
    hl("WhichKeySeparator", { fg = colors.comment })
    hl("WhichKeyFloat", { bg = colors.bg })
    hl("WhichKeyValue", { fg = colors.comment })

    -- Terminal colors
    vim.g.terminal_color_0 = colors.term_black
    vim.g.terminal_color_1 = colors.term_red
    vim.g.terminal_color_2 = colors.term_green
    vim.g.terminal_color_3 = colors.term_yellow
    vim.g.terminal_color_4 = colors.term_blue
    vim.g.terminal_color_5 = colors.term_magenta
    vim.g.terminal_color_6 = colors.term_cyan
    vim.g.terminal_color_7 = colors.term_white
    vim.g.terminal_color_8 = colors.term_black
    vim.g.terminal_color_9 = colors.term_red
    vim.g.terminal_color_10 = colors.term_green
    vim.g.terminal_color_11 = colors.term_yellow
    vim.g.terminal_color_12 = colors.term_blue
    vim.g.terminal_color_13 = colors.term_magenta
    vim.g.terminal_color_14 = colors.term_cyan
    vim.g.terminal_color_15 = colors.term_white
end

return M
