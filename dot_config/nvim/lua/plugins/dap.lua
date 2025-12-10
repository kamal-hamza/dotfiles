return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "williamboman/mason.nvim",
        "jay-babu/mason-nvim-dap.nvim",
        "theHamsta/nvim-dap-virtual-text",
        "nvim-telescope/telescope-dap.nvim",
    },
    keys = {
        { "<leader>dc", function() require("dap").continue() end,                                             desc = "Debug: Continue" },
        { "<leader>dn", function() require("dap").step_over() end,                                            desc = "Debug: Step Over (Next)" },
        { "<leader>di", function() require("dap").step_into() end,                                            desc = "Debug: Step Into" },
        { "<leader>do", function() require("dap").step_out() end,                                             desc = "Debug: Step Out" },
        { "<leader>dt", function() require("dap").toggle_breakpoint() end,                                    desc = "Debug: Toggle Breakpoint" },
        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debug: Conditional Breakpoint" },
        { "<leader>dr", function() require("dap").repl.open() end,                                            desc = "Debug: Open REPL" },
        { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Debug: Run Last" },
        { "<leader>dq", function() require("dap").terminate() end,                                            desc = "Debug: Quit/Terminate" },
        { "<leader>du", function() require("dapui").toggle() end,                                             desc = "Debug: Toggle UI" },
        { "<leader>de", function() require("dapui").eval() end,                                               desc = "Debug: Eval",                  mode = { "n", "v" } },
        { "<leader>dh", function() require("dap.ui.widgets").hover() end,                                     desc = "Debug: Hover Variables" },
        { "<F5>",       function() require("dap").continue() end,                                             desc = "Debug: Continue" },
        { "<F10>",      function() require("dap").step_over() end,                                            desc = "Debug: Step Over" },
        { "<F11>",      function() require("dap").step_into() end,                                            desc = "Debug: Step Into" },
        { "<F12>",      function() require("dap").step_out() end,                                             desc = "Debug: Step Out" },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        local mason_nvim_dap = require("mason-nvim-dap")

        -- Setup virtual text for variable values
        require("nvim-dap-virtual-text").setup({
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
            only_first_definition = true,
            all_references = false,
            clear_on_continue = false,
            display_callback = function(variable, buf, stackframe, node, options)
                if options.virt_text_pos == "inline" then
                    return " = " .. variable.value
                else
                    return variable.name .. " = " .. variable.value
                end
            end,
            virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
            all_frames = false,
            virt_lines = false,
            virt_text_win_col = nil,
        })

        -- Setup DAP UI with better configuration
        dapui.setup({
            icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
            mappings = {
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t",
            },
            expand_lines = vim.fn.has("nvim-0.7") == 1,
            layouts = {
                {
                    elements = {
                        { id = "scopes",      size = 0.25 },
                        { id = "breakpoints", size = 0.25 },
                        { id = "stacks",      size = 0.25 },
                        { id = "watches",     size = 0.25 },
                    },
                    size = 40,
                    position = "left",
                },
                {
                    elements = {
                        { id = "repl",    size = 0.5 },
                        { id = "console", size = 0.5 },
                    },
                    size = 10,
                    position = "bottom",
                },
            },
            controls = {
                enabled = true,
                element = "repl",
                icons = {
                    pause = "",
                    play = "",
                    step_into = "",
                    step_over = "",
                    step_out = "",
                    step_back = "",
                    run_last = "↻",
                    terminate = "□",
                },
            },
            floating = {
                max_height = nil,
                max_width = nil,
                border = "rounded",
                mappings = {
                    close = { "q", "<Esc>" },
                },
            },
            windows = { indent = 1 },
            render = {
                max_type_length = nil,
                max_value_lines = 100,
            },
        })

        -- Auto open/close UI
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        -- Setup mason-nvim-dap for automatic DAP adapter installation
        mason_nvim_dap.setup({
            automatic_installation = true,
            ensure_installed = {
                "python",
                "codelldb", -- C/C++/Rust
                "js",       -- JavaScript/TypeScript
                "bash",
                "delve",    -- Go
                "php",
                "coreclr",  -- .NET
            },
            handlers = {
                function(config)
                    -- Default handler
                    mason_nvim_dap.default_setup(config)
                end,

                -- Python
                python = function(config)
                    config.adapters = {
                        type = "executable",
                        command = vim.fn.exepath("python3") or vim.fn.exepath("python"),
                        args = { "-m", "debugpy.adapter" },
                    }
                    config.configurations = {
                        {
                            type = "python",
                            request = "launch",
                            name = "Launch file",
                            program = "${file}",
                            pythonPath = function()
                                local venv = os.getenv("VIRTUAL_ENV")
                                if venv then
                                    return venv .. "/bin/python"
                                end
                                return vim.fn.exepath("python3") or vim.fn.exepath("python")
                            end,
                        },
                        {
                            type = "python",
                            request = "launch",
                            name = "Launch file with arguments",
                            program = "${file}",
                            args = function()
                                local args_string = vim.fn.input("Arguments: ")
                                return vim.split(args_string, " +")
                            end,
                            pythonPath = function()
                                local venv = os.getenv("VIRTUAL_ENV")
                                if venv then
                                    return venv .. "/bin/python"
                                end
                                return vim.fn.exepath("python3") or vim.fn.exepath("python")
                            end,
                        },
                        {
                            type = "python",
                            request = "attach",
                            name = "Attach remote",
                            connect = function()
                                local host = vim.fn.input("Host [127.0.0.1]: ")
                                host = host ~= "" and host or "127.0.0.1"
                                local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
                                return { host = host, port = port }
                            end,
                        },
                    }
                    mason_nvim_dap.default_setup(config)
                end,

                -- C/C++/Rust (codelldb)
                codelldb = function(config)
                    config.adapters = {
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                            args = { "--port", "${port}" },
                        },
                    }
                    config.configurations = {
                        {
                            name = "Launch",
                            type = "codelldb",
                            request = "launch",
                            program = function()
                                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                            end,
                            cwd = "${workspaceFolder}",
                            stopOnEntry = false,
                            args = {},
                        },
                        {
                            name = "Attach to process",
                            type = "codelldb",
                            request = "attach",
                            pid = require("dap.utils").pick_process,
                            args = {},
                        },
                    }
                    mason_nvim_dap.default_setup(config)
                end,

                -- Go (delve)
                delve = function(config)
                    config.adapters = {
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = "dlv",
                            args = { "dap", "-l", "127.0.0.1:${port}" },
                        },
                    }
                    config.configurations = {
                        {
                            type = "delve",
                            name = "Debug",
                            request = "launch",
                            program = "${file}",
                        },
                        {
                            type = "delve",
                            name = "Debug test",
                            request = "launch",
                            mode = "test",
                            program = "${file}",
                        },
                        {
                            type = "delve",
                            name = "Debug test (go.mod)",
                            request = "launch",
                            mode = "test",
                            program = "./${relativeFileDirname}",
                        },
                    }
                    mason_nvim_dap.default_setup(config)
                end,

                -- Bash
                bash = function(config)
                    config.adapters = {
                        type = "executable",
                        command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
                        args = {},
                    }
                    config.configurations = {
                        {
                            type = "bash",
                            request = "launch",
                            name = "Launch file",
                            showDebugOutput = true,
                            pathBashdb = vim.fn.stdpath("data") ..
                            "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
                            pathBashdbLib = vim.fn.stdpath("data") ..
                            "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
                            trace = true,
                            file = "${file}",
                            program = "${file}",
                            cwd = "${workspaceFolder}",
                            pathCat = "cat",
                            pathBash = "/bin/bash",
                            pathMkfifo = "mkfifo",
                            pathPkill = "pkill",
                            args = {},
                            env = {},
                            terminalKind = "integrated",
                        },
                    }
                    mason_nvim_dap.default_setup(config)
                end,

                -- PHP
                php = function(config)
                    config.adapters = {
                        type = "executable",
                        command = "node",
                        args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
                    }
                    config.configurations = {
                        {
                            type = "php",
                            request = "launch",
                            name = "Listen for Xdebug",
                            port = 9003,
                        },
                    }
                    mason_nvim_dap.default_setup(config)
                end,

                -- .NET (coreclr)
                coreclr = function(config)
                    config.adapters = {
                        type = "executable",
                        command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
                        args = { "--interpreter=vscode" },
                    }
                    config.configurations = {
                        {
                            type = "coreclr",
                            name = "launch - netcoredbg",
                            request = "launch",
                            program = function()
                                return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
                            end,
                        },
                    }
                    mason_nvim_dap.default_setup(config)
                end,
            },
        })

        -- Custom signs for breakpoints
        vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
        vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
        vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
        vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticHint", linehl = "DapStoppedLine", numhl = "" })

        -- Highlight for current line when stopped
        vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

        -- Auto-detect and load launch.json if available
        local function load_launchjs()
            if vim.fn.filereadable(".vscode/launch.json") == 1 then
                require("dap.ext.vscode").load_launchjs(nil, {
                    ["pwa-node"] = { "javascript", "typescript" },
                    ["node"] = { "javascript", "typescript" },
                    ["chrome"] = { "javascript", "typescript" },
                    ["pwa-chrome"] = { "javascript", "typescript" },
                })
            end
        end

        -- Load launch.json on debug start
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            callback = function()
                load_launchjs()
            end,
        })

        -- Telescope integration
        pcall(require("telescope").load_extension, "dap")
    end,
}
