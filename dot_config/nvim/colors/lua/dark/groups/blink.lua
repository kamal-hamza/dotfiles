local M = {}

---@type dark.HighlightsFn
function M.get_hl(c)
  -- stylua: ignore
  return {
    -- Completion menu
    BlinkCmpMenu = { bg = c.bg, fg = c.fg },
    BlinkCmpMenuBorder = { fg = c.border, bg = c.bg },
    BlinkCmpMenuSelection = { bg = c.line, fg = c.fg, bold = true },
    BlinkCmpScrollbar = { bg = c.line },
    BlinkCmpScrollbarThumb = { bg = c.border },
    
    -- Documentation
    BlinkCmpDoc = { bg = c.bg, fg = c.fg },
    BlinkCmpDocBorder = { fg = c.border, bg = c.bg },
    
    -- Label highlighting
    BlinkCmpLabelMatch = { fg = c.const, bold = true },
    BlinkCmpLabel = { fg = c.fg },
    BlinkCmpLabelDeprecated = { fg = c.comment, strikethrough = true },
    
    -- Kind icons
    BlinkCmpKind = { fg = c.fg },
    BlinkCmpKindText = { fg = c.fg },
    BlinkCmpKindMethod = { fg = c.func },
    BlinkCmpKindFunction = { fg = c.func },
    BlinkCmpKindConstructor = { fg = c.type },
    BlinkCmpKindField = { fg = c.const },
    BlinkCmpKindVariable = { fg = c.fg },
    BlinkCmpKindClass = { fg = c.type },
    BlinkCmpKindInterface = { fg = c.type },
    BlinkCmpKindModule = { fg = c.type },
    BlinkCmpKindProperty = { fg = c.const },
    BlinkCmpKindUnit = { fg = c.const },
    BlinkCmpKindValue = { fg = c.const },
    BlinkCmpKindEnum = { fg = c.type },
    BlinkCmpKindKeyword = { fg = c.keyword },
    BlinkCmpKindSnippet = { fg = c.special },
    BlinkCmpKindColor = { fg = c.const },
    BlinkCmpKindFile = { fg = c.const },
    BlinkCmpKindReference = { fg = c.const },
    BlinkCmpKindFolder = { fg = c.const },
    BlinkCmpKindEnumMember = { fg = c.const },
    BlinkCmpKindConstant = { fg = c.const },
    BlinkCmpKindStruct = { fg = c.type },
    BlinkCmpKindEvent = { fg = c.const },
    BlinkCmpKindOperator = { fg = c.operator },
    BlinkCmpKindTypeParameter = { fg = c.type },
  }
end

return M
