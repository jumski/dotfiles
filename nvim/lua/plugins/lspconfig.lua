local WHICH_KEY_MAPPINGS = {
  { "<leader>l", group = "Language Server" },
  { "<leader>la", vim.lsp.buf.code_action, desc = "Code action" },
  { "<leader>ld", vim.lsp.buf.definition, desc = "Go to definition" },
  { "<leader>lf", vim.lsp.buf.format, desc = "Format buffer" },
  { "<leader>lg", vim.lsp.buf.declaration, desc = "Go to declaration" },
  { "<leader>li", vim.lsp.buf.implementation, desc = "Go to implementation" },
  { "<leader>lr", vim.lsp.buf.rename, desc = "Rename symbol" },
  { "<leader>ls", vim.lsp.buf.signature_help, desc = "Signature help" },
  { "<leader>lt", vim.lsp.buf.type_definition, desc = "Go to type definition" },
  { "<C-a>", vim.lsp.buf.code_action, desc = "Code action" },
}

return {
  'neovim/nvim-lspconfig',
  dependencies = { "pmizio/typescript-tools.nvim" },
  config = function()
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local telescopeDropdown = require('telescope.themes').get_dropdown({layout_strategy = 'horizontal', layout_config = {width = 1.0}})
    local function lsp_references_dropdown()
      require('telescope.builtin').lsp_references(telescopeDropdown)
      -- require('telescope.builtin').lsp_references( {layout_strategy='horizontal',layout_config={width=1.0}})
    end

    require("which-key").add(WHICH_KEY_MAPPINGS)

    local function setup_keybindings(_, _)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', 'gr', lsp_references_dropdown, {})
      -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
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
      cmd = { 'pdm', 'run', 'pyright-langserver', '--stdio' },
      -- cmd = { 'poetry', 'run', 'pyright-langserver', '--stdio' },
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
    -- lspconfig['tsserver'].setup{
    --   capabilities = capabilities,
    --   -- single_file_support = false,
    --   on_attach = setup_keybindings,
    --   -- root_dir = function()
    --   --   -- we assume that deno project can be nested inside ts project,
    --   --   -- so we need to check immediate parents not current working dir
    --   --   local current_file_dir = vim.fn.expand('%:p:h')
    --   --   local is_deno_project =  lspconfig.util.root_pattern("deno.json", "import_map.json")(current_file_dir)
    --
    --   --   if is_deno_project then
    --   --     return nil
    --   --   else
    --   --     return lspconfig.util.root_pattern("package.json")(vim.fn.getcwd())
    --   --   end
    --   -- end
    -- }

    lspconfig['denols'].setup({
      root_dir = lspconfig.util.root_pattern("deno.json"),
      capabilities = capabilities,
      -- single_file_support = true,
      -- on_attach = setup_keybindings,
      init_options = {
        lint = true,
        unstable = true,
        suggest = {
          imports = {
            hosts = {
              ["https://deno.land"] = true,
              ["https://cdn.nest.land"] = true,
              ["https://crux.land"] = true,
            },
          },
        },
      },
      on_attach = function()
        local active_clients = vim.lsp.get_active_clients()
        for _, client in pairs(active_clients) do
          -- stop tsserver if denols is already active
          if client.name == "tsserver" then
            client.stop()
          end
        end
      end,
    })
    -- lspconfig['denols'].setup{
    --   capabilities = capabilities,
    --   single_file_support = true,
    --   on_attach = setup_keybindings,
    -- }
    lspconfig['cssmodules_ls'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['cssls'].setup{
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    -- TODO: add something for raw html

    lspconfig['sqlls'].setup{
      capabilities = capabilities,
      -- root_dir = require('core.helpers').find_project_root,
      on_attach = setup_keybindings
    }

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
