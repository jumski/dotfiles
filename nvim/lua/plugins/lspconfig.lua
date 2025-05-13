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
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Custom full screen layout with matches on left and preview on right
    local function lsp_references_dropdown()
      require("telescope.builtin").lsp_references({
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.99,        -- Almost full screen width
          height = 0.99,       -- Almost full screen height
          preview_width = 0.6, -- 60% of width for preview on right
        },
        sorting_strategy = "ascending",
        results_title = "References",
        prompt_title = "Search References"
      })
    end

    require("which-key").add(WHICH_KEY_MAPPINGS)

    local function setup_keybindings(_, _)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {})
      vim.keymap.set("n", "gr", lsp_references_dropdown, {})
      -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
    end

    -------------------------------------
    -- Language Servers -----------------
    -------------------------------------

    lspconfig["solargraph"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
      settings = {
        solargraph = {
          diagnostics = true,
        },
      },
    })
    lspconfig["sorbet"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    lspconfig["standardrb"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    lspconfig["lua_ls"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = {
            globals = {
              "vim",
              "require", -- nvim config globals
              "awesome",
              "client",  -- awesomewm config globals
            },
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = { enable = false },
        },
      },
    })
    lspconfig["pyright"].setup({
      cmd = { "pdm", "run", "pyright-langserver", "--stdio" },
      -- cmd = { 'poetry', 'run', 'pyright-langserver', '--stdio' },
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    lspconfig["ts_ls"].setup({
      single_file_support = false,
      capabilities = capabilities,
      on_attach = setup_keybindings,

      -- ### MODIFIED FOR NESTED DENO PROJECTS ###
      root_dir = function()
        -- we assume that deno project can be nested inside ts project,
        -- so we need to check immediate parents not current working dir
        local current_file_dir = vim.fn.expand("%:p:h")
        local is_deno_project = lspconfig.util.root_pattern("deno.json", "import_map.json")(current_file_dir)

        if is_deno_project then
          return nil
        else
          return lspconfig.util.root_pattern("package.json")(vim.fn.getcwd())
        end
      end,
      -- ### RECOMMENDED ###
      -- root_dir = function(fname)
      --   if lspconfig.util.root_pattern("deno.json", "deno.jsonc", "import_map.json")(fname) then
      --     return nil
      --   end
      --
      --   return lspconfig.util.root_pattern("tsconfig.json", "package.json")(fname)
      -- end,
    })

    lspconfig["denols"].setup({
      root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
      capabilities = capabilities,
      -- single_file_support = true,
      -- on_attach = setup_keybindings,
      init_options = {
        lint = true,
        unstable = true,
        suggest = {
          imports = {
            hosts = {
              ["https://jsr.io"] = true,
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
          -- stop ts_ls if denols is already active
          if client.name == "ts_ls" then
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
    lspconfig["cssmodules_ls"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })

    lspconfig["cssls"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })

    lspconfig["jsonls"].setup {
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
          validate = { enable = true },
        },
      },
    }

    -- TODO: add something for raw html

    -- lspconfig["postgres_lsp"].setup({
    --   capabilities = capabilities,
    --   on_attach = setup_keybindings,
    --   root_dir = lspconfig.util.root_pattern("postgrestools.jsonc"),
    --   cmd = { "postgrestools", "lsp-proxy" },
    --   filetypes = { "sql" },
    --   single_file_support = true
    -- })
    -- lspconfig["sqlls"].setup({
    --   capabilities = capabilities,
    --   -- root_dir = require('core.helpers').find_project_root,
    --   on_attach = setup_keybindings,
    -- })

    lspconfig["clojure_lsp"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })

    lspconfig["svelte"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })

    lspconfig["tailwindcss"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })

    lspconfig["astro"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
      filetypes = { "astro" },
    })

    local function get_typescript_server_path(root_dir)
      local project_root = lspconfig.util.find_node_modules_ancestor(root_dir)
      return project_root and (lspconfig.util.path.join(project_root, "node_modules", "typescript", "lib")) or ""
    end

    lspconfig["mdx_analyzer"].setup({
      capabilities = capabilities,
      on_attach = setup_keybindings,
      cmd = { "mdx-language-server", "--stdio" },
      filetypes = { "markdown.mdx", "mdx" },
      single_file_support = true,
      settings = {},
      init_options = {
        typescript = {},
      },
      root_dir = lspconfig.util.root_pattern("package.json"),
      on_new_config = function(new_config, new_root_dir)
        if vim.tbl_get(new_config.init_options, "typescript") and not new_config.init_options.typescript.tsdk then
          new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
        end
      end,
    })
  end,
}
