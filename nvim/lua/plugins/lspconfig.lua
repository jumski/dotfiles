return {
  'neovim/nvim-lspconfig',
  config = function()
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local function setup_keybindings(_, _)
      -- vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
      -- vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})

      vim.keymap.set("n", "<leader>li", ":LspInfo<cr>", { silent = true })
      vim.keymap.set("n", "<leader>ll", ":LspLog<cr>", { silent = true })
      vim.keymap.set("n", "<leader>lr", ":LspRestart<cr>", { silent = true })
      vim.keymap.set("n", "<leader>ls", ":LspStart<cr>", { silent = true })
      vim.keymap.set("n", "<leader>lq", ":LspStop<cr>", { silent = true })
    end

    -------------------------------------
    -- Language Servers -----------------
    -------------------------------------

    lspconfig['solargraph'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings,
      settings = {
        solargraph = {
          diagnostics = true
        }
      }
    }
    lspconfig['sorbet'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
    lspconfig['standardrb'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
    lspconfig['lua_ls'].setup{
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
    lspconfig['pyright'].setup{
      cmd = { 'poetry', 'run', 'pyright-langserver', '--stdio' },
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
    lspconfig['tsserver'].setup{
      capabilities = capabilities,
      single_file_support = false,
      on_attach = setup_keybindings,
      root_dir = function()
        -- we assume that deno project can be nested inside ts project,
        -- so we need to check immediate parents not current working dir
        local current_file_dir = vim.fn.expand('%:p:h')
        local is_deno_project =  lspconfig.util.root_pattern("deno.json", "import_map.json")(current_file_dir)

        if is_deno_project then
          return nil
        else
          return lspconfig.util.root_pattern("package.json")(vim.fn.getcwd())
        end
      end
    }

    lspconfig['denols'].setup{
      capabilities = capabilities,
      single_file_support = true,
      on_attach = setup_keybindings,
    }
    lspconfig['cssmodules_ls'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['cssls'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    -- lspconfig['sqlls'].setup{
    --   capabilities = capabilities,
    --   root_dir = require('core.helpers').find_project_root,
    --   on_attach = setup_keybindings
    -- }

    lspconfig['clojure_lsp'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['svelte'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['tailwindcss'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
  end
}
