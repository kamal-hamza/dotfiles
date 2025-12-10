return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    ft = { "markdown" },
    keys = {
        { "<leader>mp", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown", ft = "markdown" },
    },
    opts = {
        -- Headings
        heading = {
            -- Turn on / off heading icon & background rendering
            enabled = true,
            -- Turn on / off any sign column related rendering
            sign = true,
            -- Replaces '#+' of headings
            icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
            -- Added to the sign column if enabled
            signs = { '󰫎 ' },
            -- Width of the heading background
            width = 'full',
            -- Determines how icons fill the available space:
            --  inline:  underlying '#'s are concealed
            --  overlay: background is overlayed on the '#'s
            backgrounds = {
                'RenderMarkdownH1Bg',
                'RenderMarkdownH2Bg',
                'RenderMarkdownH3Bg',
                'RenderMarkdownH4Bg',
                'RenderMarkdownH5Bg',
                'RenderMarkdownH6Bg',
            },
            foregrounds = {
                'RenderMarkdownH1',
                'RenderMarkdownH2',
                'RenderMarkdownH3',
                'RenderMarkdownH4',
                'RenderMarkdownH5',
                'RenderMarkdownH6',
            },
        },
        -- Code blocks
        code = {
            -- Turn on / off code block & inline code rendering
            enabled = true,
            -- Turn on / off any sign column related rendering
            sign = true,
            -- Determines how code blocks & inline code are rendered
            style = 'full',
            -- Width of the code block background
            width = 'full',
            -- Amount of padding to add to the left of code blocks
            left_pad = 0,
            -- Amount of padding to add to the right of code blocks
            right_pad = 0,
            -- Determines how the top / bottom of code block are rendered
            border = 'thin',
            -- Used above code blocks for thin border
            above = '▄',
            -- Used below code blocks for thin border
            below = '▀',
            -- Highlight for code blocks
            highlight = 'RenderMarkdownCode',
        },
        -- Bullet points
        bullet = {
            -- Turn on / off list bullet rendering
            enabled = true,
            -- Replaces '-'|'+'|'*' of 'unordered' list items
            icons = { '●', '○', '◆', '◇' },
            -- Highlight for the bullet icon
            highlight = 'RenderMarkdownBullet',
        },
        -- Checkboxes
        checkbox = {
            -- Turn on / off checkbox state rendering
            enabled = true,
            unchecked = {
                -- Replaces '[ ]' of unchecked checkboxes
                icon = '󰄱 ',
                -- Highlight for the unchecked icon
                highlight = 'RenderMarkdownUnchecked',
            },
            checked = {
                -- Replaces '[x]' of checked checkboxes
                icon = '󰱒 ',
                -- Highlight for the checked icon
                highlight = 'RenderMarkdownChecked',
            },
            -- Define custom checkbox states
            custom = {
                todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
            },
        },
        -- Block quotes
        quote = {
            -- Turn on / off block quote & callout rendering
            enabled = true,
            -- Replaces '>' of block quotes
            icon = '▋',
            -- Highlight for the quote icon
            highlight = 'RenderMarkdownQuote',
        },
        -- Pipes
        pipe_table = {
            -- Turn on / off pipe table rendering
            enabled = true,
            -- Determines how the table as a whole is rendered
            style = 'full',
            -- Determines how individual cells of a table are rendered
            cell = 'padded',
            -- Characters used to replace table border
            border = {
                '┌', '┬', '┐',
                '├', '┼', '┤',
                '└', '┴', '┘',
                '│', '─',
            },
            -- Highlight for table heading, delimiter, and the line above
            head = 'RenderMarkdownTableHead',
            -- Highlight for everything else, main table rows and the lines below
            row = 'RenderMarkdownTableRow',
            -- Highlight for inline padding used to add back concealed space
            filler = 'RenderMarkdownTableFill',
        },
        -- Callouts
        callout = {
            note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
            tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
            important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint' },
            warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
            caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
            -- Obsidian: https://help.a.md/Editing+and+formatting/Callouts
            abstract = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo' },
            todo = { raw = '[!TODO]', rendered = '󰝖 Todo', highlight = 'RenderMarkdownInfo' },
            success = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess' },
            question = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn' },
            failure = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError' },
            danger = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError' },
            bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError' },
            example = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint' },
            quote = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote' },
        },
        -- Links
        link = {
            -- Turn on / off inline link icon rendering
            enabled = true,
            -- Inlined with 'image' elements
            image = '󰥶 ',
            -- Inlined with 'inline_link' elements
            hyperlink = '󰌹 ',
            -- Applies to the inlined icon
            highlight = 'RenderMarkdownLink',
        },
        -- Window options
        win_options = {
            -- See :h 'conceallevel'
            conceallevel = {
                -- Used when not being rendered, get user setting
                default = vim.api.nvim_get_option_value('conceallevel', {}),
                -- Used when being rendered, concealed text is completely hidden
                rendered = 3,
            },
            -- See :h 'concealcursor'
            concealcursor = {
                default = vim.api.nvim_get_option_value('concealcursor', {}),
                rendered = 'nc',
            },
        },
    },
}
