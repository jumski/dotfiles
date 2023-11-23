return {
  'lspcontainers/lspcontainers.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
  },
  config = function()
    require'lspconfig'.solargraph.setup{
      cmd = require'lspcontainers'.command('solargraph')
    }
  end
}
