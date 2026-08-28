require("hkamal.options")
require("hkamal.keymaps")
require("hkamal.autocmds")
require("hkamal.filetype")
require("hkamal.netrw")
require("hkamal.plugins")

local function set_hl_style(group, opts)
    local curr = vim.api.nvim_get_hl(0, { name = group })
    vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", curr, opts))
end

-- custom hl overrides for the cursor-dark theme family, matching the text
-- weights/styles of the upstream VSCode "Cursor Dark" theme: function and
-- method *declarations* are bold, calls/builtins stay regular weight, and
-- comments/parameters are italic
local function apply_cursor_dark_overrides()
    -- declarations: bold
    set_hl_style("@function", { bold = true })
    set_hl_style("@function.method", { bold = true })
    set_hl_style("@lsp.typemod.function.declaration", { bold = true })
    set_hl_style("@lsp.typemod.method.declaration", { bold = true })

    -- calls, references, builtins: regular weight
    set_hl_style("@function.call", { bold = false })
    set_hl_style("@function.method.call", { bold = false })
    set_hl_style("@function.builtin", { bold = false })
    set_hl_style("@lsp.type.function", { bold = false })
    set_hl_style("@lsp.type.method", { bold = false })

    -- italics
    set_hl_style("@comment", { italic = true })
    set_hl_style("@lsp.type.comment", { italic = true })
    set_hl_style("@variable.parameter", { italic = true })
end

if vim.g.colors_name == "cursor-dark" or vim.g.colors_name == "cursor-dark-midnight" then
    apply_cursor_dark_overrides()
end

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = { "cursor-dark", "cursor-dark-midnight" },
    callback = apply_cursor_dark_overrides,
})
