-- =============================================================================
-- treesitter — Neovim 0.12 native treesitter (no plugin required)
-- =============================================================================
-- Neovim 0.12+ ships with bundled parsers for: c, lua, vim, vimdoc, query,
-- markdown, and markdown_inline. Highlighting, folding, and indentation are
-- handled via built-in vim.treesitter APIs — no nvim-treesitter plugin needed.
--
-- To install additional parsers, place compiled .so files in:
--   stdpath("data") .. "/site/parser/"
-- or run :TSInstall <lang> if you have nvim-treesitter installed separately.

local filetypes = {
  "lua",
  "python",
  "rust",
  "zig",
  "typescript",
  "javascript",
  "c",
  "cpp",
}

-- Enable treesitter highlighting, folding, and indentation for supported filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = filetypes,
  callback = function()
    local ok, _ = pcall(vim.treesitter.start)
    if not ok then return end

    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.bo.indentexpr = "v:lua.vim.treesitter.indentexpr()"
  end,
})
