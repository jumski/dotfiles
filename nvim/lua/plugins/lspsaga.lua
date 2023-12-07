return {
  'nvimdev/lspsaga.nvim',
  enabled = false,
  config = function()
    require('lspsaga').setup({})
  end,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons'
  }
}
