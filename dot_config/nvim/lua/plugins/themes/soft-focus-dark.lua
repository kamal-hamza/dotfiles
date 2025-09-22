-- Soft Focus Dark Neovim Theme
-- Based on the Zed "Soft Focus Dark" theme by Hamza Kamal

local M = {}

M.setup = function()
    -- Reset highlighting
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    -- Set theme name
    vim.g.colors_name = "soft-focus-dark"

    -- Define color palette
    local colors = {
        -- Base colors
        bg = "#050505",      -- background
        fg = "#f5f5f5",      -- text
        bg_alt = "#2a2b2e99", -- element.background
        bg_elevated = "#1a1b1d", -- elevated_surface.background
        fg_alt = "#bbbbbb",  -- text.muted
        fg_dim = "#888888",  -- text.placeholder

        -- Accent colors
        blue = "#067BC2",   -- primary accent
        blue_light = "#67b7f5", -- text.accent, function
        green = "#77aa77",  -- string, success
        mint = "#D5F2E3",   -- tertiary accent

        -- Syntax colors
        red = "#C42847",       -- base red
        red_bright = "#ff4c6a", -- keyword, error (bright)
        orange = "#D4B87B",    -- type, warning
        orange_bright = "#f0d08a", -- bright yellow
        cyan = "#67b7f5",      -- function
        cyan_bright = "#77d5ff", -- bright cyan
        purple = "#B88E8D",    -- magenta
        purple_bright = "#d4a6a6", -- bright magenta

        -- UI colors
        border = "#ffffff1A",
        comment = "#888888",
        line_nr = "#888888",
        cursor_line = "#22334480",
        visual = "#067BC230",
        search = "#067BC24D",

        -- Git colors
        git_add = "#77aa77",
        git_change = "#D4B87B",
        git_delete = "#C42847",

        -- Diagnostic colors
        error = "#ff4c6a",
        warn = "#D4B87B",
        info = "#77AA77",
        hint = "#67b7f5",

        -- Terminal colors
        term_black = "#111111",
        term_red = "#C42847",
        term_green = "#77aa77",
        term_yellow = "#D4B87B",
        term_blue = "#067BC2",
        term_magenta = "#B88E8D",
        term_cyan = "#67b7f5",
        term_white = "#f5f5f5",

        -- Bright terminal colors
        term_bright_black = "#333333",
        term_bright_red = "#ff4c6a",
        term_bright_green = "#99cc99",
        term_bright_yellow = "#f0d08a",
        term_bright_blue = "#4da6ff",
        term_bright_magenta = "#d4a6a6",
        term_bright_cyan = "#77d5ff",
        term_bright_white = "#ffffff",
    }

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
    hl("TabLineSel", { fg = colors.fg, bg = "#1f2a3399" })
    hl("WinSeparator", { fg = colors.border })
    hl("VertSplit", { fg = colors.border })
    hl("Pmenu", { fg = colors.fg, bg = colors.bg_elevated })
    hl("PmenuSel", { fg = colors.fg, bg = colors.visual })
    hl("PmenuSbar", { bg = colors.bg_alt })
    hl("PmenuThumb", { bg = colors.blue })
    hl("WildMenu", { fg = colors.fg, bg = colors.visual })

    -- Folding
    hl("Folded", { fg = colors.comment, bg = colors.bg_elevated })
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
    hl("String", { fg = colors.green })
    hl("Character", { fg = colors.green })
    hl("Number", { fg = colors.orange })
    hl("Boolean", { fg = colors.red_bright })
    hl("Float", { fg = colors.orange })
    hl("Identifier", { fg = colors.fg })
    hl("Function", { fg = colors.blue_light })
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
    hl("Special", { fg = colors.blue_light })
    hl("SpecialChar", { fg = colors.blue_light })
    hl("Tag", { fg = colors.blue_light })
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
    hl("@string.escape", { fg = colors.blue_light })
    hl("@string.special", { fg = colors.blue_light })
    hl("@character", { fg = colors.green })
    hl("@character.special", { fg = colors.blue_light })
    hl("@number", { fg = colors.orange })
    hl("@boolean", { fg = colors.red_bright })
    hl("@float", { fg = colors.orange })
    hl("@function", { fg = colors.blue_light })
    hl("@function.builtin", { fg = colors.blue_light })
    hl("@function.call", { fg = colors.blue_light })
    hl("@function.macro", { fg = colors.red_bright })
    hl("@method", { fg = colors.blue_light })
    hl("@method.call", { fg = colors.blue_light })
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
    hl("@attribute", { fg = colors.blue_light })
    hl("@field", { fg = colors.fg })
    hl("@property", { fg = colors.fg })
    hl("@operator", { fg = colors.fg })
    hl("@punctuation.delimiter", { fg = colors.fg })
    hl("@punctuation.bracket", { fg = colors.fg })
    hl("@punctuation.special", { fg = colors.blue_light })
    hl("@comment", { fg = colors.comment, italic = true })
    hl("@comment.documentation", { fg = colors.comment, italic = true })
    hl("@tag", { fg = colors.red_bright })
    hl("@tag.attribute", { fg = colors.orange })
    hl("@tag.delimiter", { fg = colors.fg })

    -- LSP highlights
    hl("LspReferenceText", { bg = "#33413929" })
    hl("LspReferenceRead", { bg = "#33413929" })
    hl("LspReferenceWrite", { bg = "#33413929" })
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
    hl("TelescopeBorder", { fg = colors.blue, bg = colors.bg_elevated })
    hl("TelescopePromptBorder", { fg = colors.blue, bg = colors.bg_elevated })
    hl("TelescopeResultsBorder", { fg = colors.blue, bg = colors.bg_elevated })
    hl("TelescopePreviewBorder", { fg = colors.blue, bg = colors.bg_elevated })
    hl("TelescopeSelection", { bg = colors.visual })
    hl("TelescopeSelectionCaret", { fg = colors.blue_light })
    hl("TelescopeMultiSelection", { fg = colors.blue_light })
    hl("TelescopeMatching", { fg = colors.blue_light, bold = true })

    -- NvimTree
    hl("NvimTreeNormal", { fg = colors.fg, bg = colors.bg })
    hl("NvimTreeRootFolder", { fg = colors.blue_light, bold = true })
    hl("NvimTreeGitDirty", { fg = colors.git_change })
    hl("NvimTreeGitNew", { fg = colors.git_add })
    hl("NvimTreeGitDeleted", { fg = colors.git_delete })
    hl("NvimTreeSpecialFile", { fg = colors.blue_light })
    hl("NvimTreeIndentMarker", { fg = colors.comment })
    hl("NvimTreeImageFile", { fg = colors.purple })
    hl("NvimTreeSymlink", { fg = colors.cyan })

    -- WhichKey
    hl("WhichKey", { fg = colors.blue_light })
    hl("WhichKeyGroup", { fg = colors.cyan })
    hl("WhichKeyDesc", { fg = colors.fg })
    hl("WhichKeySeperator", { fg = colors.comment })
    hl("WhichKeySeparator", { fg = colors.comment })
    hl("WhichKeyFloat", { bg = colors.bg_elevated })
    hl("WhichKeyValue", { fg = colors.comment })

    -- Indent Blankline
    hl("IndentBlanklineChar", { fg = "#44444499" })
    hl("IndentBlanklineContextChar", { fg = "#666666" })
    hl("IndentBlanklineContextStart", { sp = colors.blue, underline = true })

    -- Alpha (dashboard)
    hl("AlphaShortcut", { fg = colors.blue_light })
    hl("AlphaHeader", { fg = colors.blue_light })
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
    hl("NeoTreeDirectoryName", { fg = colors.blue_light })
    hl("NeoTreeDirectoryIcon", { fg = colors.blue_light })
    hl("NeoTreeRootName", { fg = colors.blue_light, bold = true })
    hl("NeoTreeGitAdded", { fg = colors.git_add })
    hl("NeoTreeGitDeleted", { fg = colors.git_delete })
    hl("NeoTreeGitModified", { fg = colors.git_change })
    hl("NeoTreeGitConflict", { fg = colors.error })
    hl("NeoTreeGitUntracked", { fg = colors.comment })
    hl("NeoTreeIndentMarker", { fg = colors.comment })
    hl("NeoTreeExpander", { fg = colors.comment })

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
