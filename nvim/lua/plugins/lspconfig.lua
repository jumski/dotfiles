return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'lspcontainers/lspcontainers.nvim',
  },
  config = function()
    local lspconfig = require('lspconfig')
    local container_command = require('lspcontainers').command

    -- returns true/false depending on the presence of bin/restore_pg_dump
    local function need_custom_solargraph_config()
      local path_to_check = vim.fn.getcwd() .. "/bin/restore_pg_dump"
      local file = io.open(path_to_check, "r")

      if file ~= nil then
        io.close(file)

        return true
      end

      return false
    end

    -- this functions configures solargraph command differently
    -- for one of the projects
    local function solargraph_command()
      local solargraph_cmd

      if need_custom_solargraph_config() then

        solargraph_cmd = container_command('solargraph', {
          image = "toolchest-rails-web"
        })
        table.insert(solargraph_cmd, "bundle")
        table.insert(solargraph_cmd, "exec")
        table.insert(solargraph_cmd, "solargraph")
        table.insert(solargraph_cmd, "stdio")
      else
        solargraph_cmd = container_command('solargraph', {
          image = "jumski/lspcontainers-solargraph:latest"
        })
      end

      return solargraph_cmd
    end

    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    lspconfig['solargraph'].setup{
      cmd = solargraph_command(),
      capabilities = capabilities,
      settings = {
        solargraph = {
          diagnostics = true
        }
      }
    }
    lspconfig['sorbet'].setup{
      cmd = { 'bundle', 'exec', 'srb', 'tc', '--lsp', '--disable-watchman' },
      capabilities = capabilities
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
    lspconfig['cssmodules_ls'].setup{ capabilities = capabilities }
    lspconfig['cssls'].setup{
      cmd = { '/home/jumski/.dotfiles/node_modules/.bin/vscode-css-language-server', '--stdio' },
      capabilities = capabilities
    }
  end
}
