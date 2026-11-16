vim.pack.add({ "https://github.com/3rd/image.nvim" })

-- kitty graphics protocol (ghostty supports it natively; tmux needs
-- allow-passthrough, see dot_tmux.conf). used by leetcode.nvim to render images
-- in problem descriptions, so the document integrations are all off
require("image").setup({
    backend = "kitty",
    processor = "magick_cli",
    integrations = {
        markdown = { enabled = false },
        neorg = { enabled = false },
        typst = { enabled = false },
        html = { enabled = false },
        css = { enabled = false },
    },
})
