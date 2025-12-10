return {
    "mbbill/undotree",
    keys = {
        { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    },
    config = function()
        -- Undotree window settings
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_SplitWidth = 30
        vim.g.undotree_SetFocusWhenToggle = 1
        vim.g.undotree_ShortIndicators = 1

        -- Diff window settings
        vim.g.undotree_DiffAutoOpen = 1
        vim.g.undotree_DiffpanelHeight = 10

        -- Highlighting
        vim.g.undotree_HighlightChangedText = 1
        vim.g.undotree_HighlightSyntaxAdd = "DiffAdd"
        vim.g.undotree_HighlightSyntaxChange = "DiffChange"
        vim.g.undotree_HighlightSyntaxDel = "DiffDelete"

        -- Tree style
        vim.g.undotree_TreeNodeShape = '◉'
        vim.g.undotree_TreeVertShape = '│'
        vim.g.undotree_TreeSplitShape = '╱'
        vim.g.undotree_TreeReturnShape = '╲'
    end,
}
