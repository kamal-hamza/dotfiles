return {
  'echasnovski/mini.nvim',
  version = "*",
  dependencies = {
    { 'echasnovski/mini.pairs', version = '*' },
    { 'echasnovski/mini.icons', version = '*' },
  },
  config = function()
    require("mini.pairs").setup()
    require("mini.icons").setup()
  end
}
