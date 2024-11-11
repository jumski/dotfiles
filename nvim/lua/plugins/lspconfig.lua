local WHICH_KEY_MAPPINGS = {
  { "<leader>l",  group = "Language Server" },
  { "<leader>la", vim.lsp.buf.code_action,     desc = "Code action" },
  { "<leader>ld", vim.lsp.buf.definition,      desc = "Go to definition" },
  { "<leader>lf", vim.lsp.buf.format,          desc = "Format buffer" },
  { "<leader>lg", vim.lsp.buf.declaration,     desc = "Go to declaration" },
  { "<leader>li", vim.lsp.buf.implementation,  desc = "Go to implementation" },
  { "<leader>lr", vim.lsp.buf.rename,          desc = "Rename symbol" },
  { "<leader>ls", vim.lsp.buf.signature_help,  desc = "Signature help" },
  { "<leader>lt", vim.lsp.buf.type_definition, desc = "Go to type definition" },
}

return {
  'neovim/nvim-lspconfig',
  config = function()
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local telescopeDropdown = require('telescope.themes').get_dropdown({ layout_strategy = 'horizontal', layout_config = { width = 1.0 } })
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

    lspconfig['solargraph'].setup {
      capabilities = capabilities,
      on_attach = setup_keybindings,
      settings = {
        solargraph = {
          diagnostics = true
        }
      }
    }
    lspconfig['sorbet'].setup {
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
    lspconfig['standardrb'].setup {
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
    lspconfig['lua_ls'].setup {
      capabilities = capabilities,
      on_attach = setup_keybindings,
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = {
            globals = {
              'vim', 'require',    -- nvim config globals
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
    lspconfig['pyright'].setup {
      cmd = { 'pdm', 'run', 'pyright-langserver', '--stdio' },
      -- cmd = { 'poetry', 'run', 'pyright-langserver', '--stdio' },
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['denols'].setup {
      on_attach = setup_keybindings,
      root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
    }

    lspconfig['ts_ls'].setup {
      on_attach = function(client, bufnr)
        setup_keybindings()

        local filename = vim.api.nvim_buf_get_name(bufnr)

        if lspconfig.util.root_pattern("deno.json", "deno.jsonc")(filename) then
          client.stop()
        end
      end,
      root_dir = lspconfig.util.root_pattern("package.json"),
      single_file_support = false
    }

    lspconfig['cssmodules_ls'].setup {
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['cssls'].setup {
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    -- TODO: add something for raw html

    lspconfig['sqlls'].setup {
      capabilities = capabilities,
      -- root_dir = require('core.helpers').find_project_root,
      on_attach = setup_keybindings
    }

    lspconfig['clojure_lsp'].setup {
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['svelte'].setup {
      capabilities = capabilities,
      on_attach = setup_keybindings
    }

    lspconfig['tailwindcss'].setup {
      capabilities = capabilities,
      on_attach = setup_keybindings
    }
  end
}
