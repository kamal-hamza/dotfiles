return {
  "tpope/vim-fugitive",
  dependencies = {
    "folke/noice.nvim",
    "ibhagwan/fzf-lua",
    "carbon-steel/detour.nvim",
  },
  keys = {
    "<leader>g",
  },
  config = function()
    local fzf = require("fzf-lua")
    local detour = require("detour")

    local function checkoutBranch()
      if vim.fn.system("git rev-parse --is-inside-work-tree"):match("true") then
        fzf.git_branches({
          actions = {
            ["default"] = function(selected_branch)
              local branch = selected_branch[1]
              vim.cmd("Git switch " .. branch)
            end,
          },
        })
      else
        vim.notify("Not a git repository!", vim.log.levels.ERROR)
      end
    end

    local function newBranch()
      if vim.fn.system("git rev-parse --is-inside-work-tree"):match("true") then
        vim.ui.input({ prompt = "Branch Name: " }, function(input)
          if input then
            vim.cmd("Git branch " .. input .. "")
            vim.notify("Created branch: " .. input)
          else
            vim.notify("No branch name provided!", vim.log.levels.WARN)
          end
        end)
      else
        vim.notify("Not a git repository!", vim.log.levels.ERROR)
      end
    end

    local function deleteBranch()
      if vim.fn.system("git rev-parse --is-inside-work-tree"):match("true") then
        fzf.git_branches({
          actions = {
            ["default"] = function(selected_branch)
              local branch = selected_branch[1]
              if not branch then
                vim.notify("No branch was selected!", vim.log.levels.WARN)
                return
              end
              if branch:match("^origin/") then
                local remote_branch = branch:gsub("^origin/", "")
                vim.cmd("Git push origin --delete " .. remote_branch)
                vim.notify("Deleted remote branch: " .. branch)
              else
                local confirm = vim.fn.confirm("Delete local branch '" .. branch .. "'?", "&Yes\n&No")
                if confirm == 1 then
                  vim.cmd("Git branch -d " .. branch)
                  vim.notify("Deleted local branch: " .. branch)
                end
              end
            end,
          },
        })
      else
        vim.notify("Not a git repository!", vim.log.levels.ERROR)
      end
    end

    local function addFiles()
      if vim.fn.system("git rev-parse --is-inside-work-tree"):match("true") then
        fzf.git_files({
          cmd = "git ls-files --modified",
          multi = true,
          actions = {
            ["default"] = function(selected_files)
              for _, file in ipairs(selected_files) do
                local clean_file = file:match("[\128-\255]+(.+)$")
                vim.cmd("Git add " .. clean_file)
              end
              vim.notify("Added all files!")
            end,
          },
        })
      else
        vim.notify("Not a git repository!", vim.log.levels.ERROR)
      end
    end

    local function gitStatus()
      local popup_id = detour.Detour({})
      if not popup_id then
        vim.notify("Unable to open popup!", vim.log.levels.ERROR)
        return
      end
      vim.cmd.terminal("git status")
      vim.bo.bufhidden = "delete"
      vim.wo[popup_id].signcolumn = "no"
      vim.keymap.set("n", "<Esc>", "<cmd>q<CR>", { buffer = true })
      vim.api.nvim_create_autocmd({ "TermClose" }, {
        buffer = vim.api.nvim_get_current_buf(),
        callback = function()
          vim.api.nvim_feedkeys("i", "n", false)
        end,
      })
    end

    local keymap = vim.keymap
    keymap.set("n", "<leader>gP", "<cmd>Git pull<CR>", { desc = "Git Pull" })
    keymap.set("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git Push" })
    keymap.set("n", "<leader>gcc", "<cmd>Git commit<CR>", { desc = "Git Commit" })
    keymap.set("n", "<leader>ga", addFiles, { desc = "Git Add" })
    keymap.set("n", "<leader>gA", "<cmd>Git add --all<CR>", { desc = "Git Add All" })
    keymap.set("n", "<leader>gr", "<cmd>Git reset<CR>", { desc = "Git Reset" })
    keymap.set("n", "<leader>gs", gitStatus, { desc = "Git Status" })
    keymap.set("n", "<leader>gcb", checkoutBranch, { desc = "Switch Git Branch" })
    keymap.set("n", "<leader>gnb", newBranch, { desc = "Create Git Branch" })
    keymap.set("n", "<leader>gdb", deleteBranch, { desc = "Delete Git Branch" })
    keymap.set("n", "<leader>gD", "<cmd>Git diff<CR>", { desc = "Git Diff File" })
  end,
}
