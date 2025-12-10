return {
    "notjedi/nvim-rooter.lua",
    event = "VeryLazy",
    config = function()
        require("nvim-rooter").setup({
            -- Root has priority over the others
            rooter_patterns = {
                ".git",
                ".hg",
                ".svn",
                -- Node.js
                "package.json",
                -- Python
                "pyproject.toml",
                "setup.py",
                "requirements.txt",
                "Pipfile",
                -- Rust
                "Cargo.toml",
                -- Go
                "go.mod",
                -- Ruby
                "Gemfile",
                -- PHP
                "composer.json",
                -- Java
                "pom.xml",
                "build.gradle",
                -- .NET
                ".sln",
                -- Make/CMake
                "Makefile",
                "CMakeLists.txt",
                -- Docker
                "docker-compose.yml",
                "Dockerfile",
            },
            -- Trigger rooter on these events
            trigger_patterns = { "*" },
            -- Manual mode (won't change directory automatically)
            manual = false,
            -- File types to exclude from rooter
            exclude_filetypes = {
                "gitcommit",
                "fugitive",
                "help",
                "TelescopePrompt",
                "oil",
                "toggleterm",
            },
        })
    end,
}
