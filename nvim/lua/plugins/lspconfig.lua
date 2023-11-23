return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'lspcontainers/lspcontainers.nvim',

  },
  config = function()
    local lspconfig = require('lspconfig')
    local container_command = require('lspcontainers').command
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    lspconfig['solargraph'].setup{
      cmd = container_command('solargraph', {
        image = "jumski/lspcontainers-solargraph:latest"
      }),
      capabilities = capabilities
    }
    lspconfig['lua_ls'].setup{
      cmd = container_command('lua_ls'),
      capabilities = capabilities
    }
    lspconfig['pyright'].setup{
      cmd = container_command('pyright'),
      capabilities = capabilities
    }
    lspconfig['tsserver'].setup{
      cmd = container_command('tsserver'),
      capabilities = capabilities
    }

    -- -- Set up lspconfig.
    -- -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
    -- require('lspconfig')['solargraph'].setup {
    --   capabilities = capabilities
    -- }
  end
}
