return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'lspcontainers/lspcontainers.nvim',
  },
  config = function()
    local lspconfig = require('lspconfig')
    local container_command = require('lspcontainers').command
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local solargraph_cmd = container_command('solargraph', {
      image = "toolchest-rails-web"
      -- image = "jumski/lspcontainers-solargraph:latest"
    })
    table.insert(solargraph_cmd, "bundle")
    table.insert(solargraph_cmd, "exec")
    table.insert(solargraph_cmd, "solargraph")
    table.insert(solargraph_cmd, "stdio")

    lspconfig['solargraph'].setup{
      cmd = solargraph_cmd,
      capabilities = capabilities,
      settings = {
        solargraph = {
          diagnostics = true
        }
      }
    }
    lspconfig['lua_ls'].setup{
      cmd = container_command('lua_ls'),
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = {
            globals = { 'vim', 'require' }
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true)
          },
          telemetry = { enable = false }
        }
      }
    }
    lspconfig['pyright'].setup{
      cmd = container_command('pyright'),
      capabilities = capabilities
    }
    lspconfig['tsserver'].setup{
      cmd = container_command('tsserver'),
      capabilities = capabilities
    }
  end
}
