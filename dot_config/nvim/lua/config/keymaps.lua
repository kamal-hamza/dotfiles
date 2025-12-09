-- ============================================================================
-- Unified Keybindings Configuration
-- Matches Zed editor keybindings from keymap.json
-- Source of truth: ~/.config/zed/keymap.json
-- ============================================================================

-- Helper function to set keymap
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ========================================================================
-- Global Bindings: Window/Pane Navigation
-- Matches Zed: ctrl-h/j/k/l for workspace::ActivatePane*
-- ========================================================================

map("n", "<C-h>", "<C-w>h", { desc = "Navigate to left pane" })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate to right pane" })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate to down pane" })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate to up pane" })

-- Terminal mode navigation
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Navigate to left pane from terminal" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Navigate to right pane from terminal" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Navigate to down pane from terminal" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Navigate to up pane from terminal" })

-- ========================================================================
-- File Finder & Project Management
-- ========================================================================

-- Zed: space f f - file_finder::Toggle
map("n", "<leader>ff", function() require('mini.pick').builtin.files() end, { desc = "Find Files" })

-- Zed: space f p - projects::OpenRecent
map("n", "<leader>fp", "<cmd>Telescope oldfiles<cr>", { desc = "Recent Files" })

-- Zed: space f g - workspace::NewSearch
map("n", "<leader>fg", function() require('mini.pick').builtin.grep_live() end, { desc = "Grep Search" })

-- Zed: space f b - tab_switcher::Toggle
map("n", "<leader>fb", function() require('mini.pick').builtin.buffers() end, { desc = "Find Buffers" })

-- ========================================================================
-- Panel & Dock Toggles
-- ========================================================================

-- Zed: space e e - project_panel::ToggleFocus
map("n", "<leader>ee", "<cmd>Oil<CR>", { desc = "Toggle File Explorer" })

-- Zed: space g g - git_panel::ToggleFocus
map("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Toggle Git Panel" })

-- Zed: space k k - terminal_panel::Toggle
map("n", "<leader>kk", function() Snacks.terminal.toggle() end, { desc = "Toggle Terminal" })

-- Zed: space d d - debug_panel::ToggleFocus
map("n", "<leader>dd", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Toggle Diagnostics" })

-- ========================================================================
-- Git Commands
-- ========================================================================

-- Zed: space g c - git::Commit
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git Commit" })

-- Zed: space g P - git::Pull
map("n", "<leader>gP", "<cmd>Git pull<CR>", { desc = "Git Pull" })

-- Zed: space g p - git::Push
map("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git Push" })

-- Zed: space g b - git::Branch
map("n", "<leader>gb", "<cmd>Git branch<CR>", { desc = "Git Branch" })

-- Zed: space g i - git::Init
map("n", "<leader>gi", "<cmd>Git init<CR>", { desc = "Git Init" })

-- Zed: space g a - git::Add
map("n", "<leader>ga", "<cmd>Git add %<CR>", { desc = "Git Add Current File" })

-- Zed: space g A - git::StageAll
map("n", "<leader>gA", "<cmd>Git add .<CR>", { desc = "Git Stage All" })

-- Zed: space g u - git::UnstageAll
map("n", "<leader>gu", "<cmd>Git reset<CR>", { desc = "Git Unstage All" })

-- Zed: space g d - git::Diff
-- Zed: space g h d - git::Diff
map("n", "<leader>ghd", "<cmd>Git diff<CR>", { desc = "Git Diff" })

-- ========================================================================
-- LSP & Diagnostics (CoC.nvim)
-- Matches Zed editor LSP keybindings
-- ========================================================================

-- Zed: shift-k - editor::Hover
map("n", "K", "<cmd>call CocActionAsync('doHover')<CR>", { desc = "Show Hover Documentation" })

-- Zed: g d - editor::GoToDefinition
map("n", "gd", "<Plug>(coc-definition)", { desc = "Go to Definition" })

-- Zed: g D - editor::GoToDefinitionSplit
map("n", "gD", "<cmd>call CocAction('jumpDefinition', 'split')<CR>", { desc = "Go to Definition (Split)" })

-- Zed: g t - editor::GoToTypeDefinition
map("n", "gt", "<Plug>(coc-type-definition)", { desc = "Go to Type Definition" })

-- Zed: g T - editor::GoToTypeDefinitionSplit
map("n", "gT", "<cmd>call CocAction('jumpTypeDefinition', 'split')<CR>", { desc = "Go to Type Definition (Split)" })

-- Zed: space c c - editor::ToggleCodeActions
map("n", "<leader>cc", "<Plug>(coc-codeaction-cursor)", { desc = "Code Actions" })
map("v", "<leader>cc", "<Plug>(coc-codeaction-selected)", { desc = "Code Actions" })

-- Zed: space r r - editor::Rename
map("n", "<leader>rr", "<Plug>(coc-rename)", { desc = "Rename Symbol" })

-- Zed: space r R - editor::SelectAllMatches (search & replace)
map("n", "<leader>rR", ":%s//g<Left><Left>", { desc = "Search and Replace All" })

-- Zed: space t d - diagnostics::Deploy
map("n", "<leader>td", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer Diagnostics" })

-- Zed: space l l - lsp_tool::ToggleMenu
map("n", "<leader>ll", "<cmd>CocInfo<CR>", { desc = "CoC Info" })

-- Zed: space s - outline::Toggle
map("n", "<leader>s", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document Symbols (Outline)" })

-- Zed: space S - project_symbols::Toggle
map("n", "<leader>S", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Project Symbols" })

-- ========================================================================
-- Buffer/Tab Management
-- ========================================================================

-- Zed: space d b - pane::CloseActiveItem
map("n", "<leader>db", "<cmd>bd<CR>", { desc = "Close Buffer" })

-- ========================================================================
-- Debugger Controls
-- ========================================================================

-- Zed: space d t - editor::ToggleBreakpoint
map("n", "<leader>dt", function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })

-- Zed: space d s - debugger::Start
map("n", "<leader>ds", function() require("dap").continue() end, { desc = "Start/Continue Debugger" })

-- Zed: space d c - debugger::Continue
map("n", "<leader>dc", function() require("dap").continue() end, { desc = "Continue Debugger" })

-- Zed: space d S - debugger::Stop
map("n", "<leader>dS", function() require("dap").terminate() end, { desc = "Stop Debugger" })

-- ========================================================================
-- Search
-- ========================================================================

-- Zed: / - vim::Search
map("n", "/", "/", { desc = "Search" })

-- ========================================================================
-- Command Palette
-- ========================================================================

-- Zed: : - command_palette::Toggle
map("n", ":", ":", { desc = "Command Mode" })

-- Zed: ? - command_palette::Toggle
map("n", "?", "<cmd>Telescope commands<cr>", { desc = "Command Palette" })

-- ========================================================================
-- Vim Enhancements
-- ========================================================================

-- Zed: shift-y -> y $
map("n", "Y", "y$", { desc = "Yank to end of line" })

-- Escape closes docks/panels and clears search highlights
map("n", "<Esc>", "<cmd>noh<CR><Esc>", { desc = "Clear search highlights" })

-- ========================================================================
-- Visual Mode: Text Manipulation
-- ========================================================================

-- Zed: shift-j - editor::MoveLineDown
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })

-- Zed: shift-k - editor::MoveLineUp
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better indenting (maintain visual selection)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Paste without yanking
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- ========================================================================
-- Terminal Mode
-- ========================================================================

-- Zed: ctrl-d toggles bottom dock (we use it to exit terminal mode)
map("t", "<C-d>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ========================================================================
-- File Type Specific: Markdown
-- ========================================================================

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        -- Zed: space m p - markdown::OpenPreviewToTheSide
        map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { desc = "Markdown Preview", buffer = true })

        -- Zed: space m P - markdown::OpenPreview
        map("n", "<leader>mP", "<cmd>MarkdownPreviewStop<CR>", { desc = "Stop Markdown Preview", buffer = true })
    end,
})

-- ========================================================================
-- Additional Useful Keybindings (not in Zed, but helpful)
-- ========================================================================

-- Better window management
map("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>wh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>we", "<C-w>=", { desc = "Equal window sizes" })
map("n", "<leader>wq", "<cmd>close<CR>", { desc = "Close window" })

-- Tab management
map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "]t", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "[t", "<cmd>tabprevious<CR>", { desc = "Previous tab" })

-- Quick save
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })

-- Better scrolling (center on move)
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Formatting
map("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })



-- Quickfix navigation
map("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix" })
map("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix" })
