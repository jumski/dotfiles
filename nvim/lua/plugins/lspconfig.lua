return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'lspcontainers/lspcontainers.nvim',
  },
  config = function()
    local helpers = require('core.helpers')
    local lspconfig = require('lspconfig')
    local container_command = require('lspcontainers').command
    local home_path = os.getenv('HOME')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local function node_bin(name)
      return home_path .. '/.dotfiles/node_modules/.bin/' .. name
    end

    -- returns true/false depending on the presence of bin/restore_pg_dump
    local function need_custom_solargraph_config()
      local path_to_check = vim.fn.getcwd() .. "/bin/restore_pg_dump"
      local file = io.open(path_to_check, "r")

      return true
      -- if file ~= nil then
      --   io.close(file)

      --   return true
      -- end

      -- return false
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

    local function setup_keybindings(_, _)
      -- vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
      -- vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
    end

    local function git_root_dir()
      return lspconfig.util.root_pattern('.git');
    end

    -------------------------------------
    -- Language Servers -----------------
    -------------------------------------

    lspconfig['solargraph'].setup{
      cmd = solargraph_command(),
      capabilities = capabilities,
      on_attach = setup_keybindings,
      settings = {
        solargraph = {
          diagnostics = true
        }
      }
    }
    lspconfig['sorbet'].setup{
      cmd = { 'bundle', 'exec', 'srb', 'tc', '--lsp', '--disable-watchman' },
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
    lspconfig['lua_ls'].setup{
      cmd = container_command('lua_ls'),
      capabilities = capabilities,
      on_attach = setup_keybindings,
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = {
            globals = {
              'vim', 'require', -- nvim config globals
              'awesome', 'client', -- awesomewm config globals
            }
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true)
          },
          telemetry = { enable = false }
        }
      }
    }

    local function get_pyright_cmd()
      if helpers.has_poetry() then
        return { 'poetry', 'run', 'pyright-langserver', '--stdio' }
      else
        return { 'pyright-langserver', '--stdio' }
      end
    end

    lspconfig['pyright'].setup{
      cmd = get_pyright_cmd(),
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
    lspconfig['tsserver'].setup{
      cmd = container_command('tsserver'),
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
    lspconfig['cssmodules_ls'].setup{
      cmd = { node_bin('cssmodules-language-server'), '--stdio' },
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['cssls'].setup{
      cmd = { node_bin('vscode-css-language-server'), '--stdio' },
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['sqlls'].setup{
      cmd = { node_bin('sql-language-server'), 'up', '--method', '--stdio' },
      capabilities = capabilities,
      root_dir = git_root_dir(),
      on_attach = setup_keybindings
    }

    lspconfig['clojure_lsp'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['svelte'].setup{
      cmd = { node_bin('svelte-language-server'), '--stdio' },
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
  end
}
