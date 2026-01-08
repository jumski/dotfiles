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
}

return {
  "neovim/nvim-lspconfig",
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local util = require("lspconfig.util")

    -- Custom full screen layout with matches on left and preview on right
    local function lsp_references_dropdown()
      require("telescope.builtin").lsp_references({
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.99, -- Almost full screen width
          height = 0.99, -- Almost full screen height
          preview_width = 0.6, -- 60% of width for preview on right
        },
        sorting_strategy = "ascending",
        results_title = "References",
        prompt_title = "Search References",
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

    vim.lsp.config("solargraph", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
      settings = {
        solargraph = {
          diagnostics = true,
        },
      },
    })
    vim.lsp.enable("solargraph")

    vim.lsp.config("sorbet", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    vim.lsp.enable("sorbet")

    vim.lsp.config("standardrb", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    vim.lsp.enable("standardrb")

    vim.lsp.config("lua_ls", {
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
              "client", -- awesomewm config globals
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
    vim.lsp.enable("lua_ls")

    vim.lsp.config("pyright", {
      cmd = { "pdm", "run", "pyright-langserver", "--stdio" },
      -- cmd = { 'poetry', 'run', 'pyright-langserver', '--stdio' },
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    vim.lsp.enable("pyright")

    -- TypeScript LS: refuse to attach where a Deno root exists
    vim.lsp.config("ts_ls", {
      cmd = { "typescript-language-server", "--stdio" },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      single_file_support = false,
      capabilities = capabilities,
      on_attach = setup_keybindings,
      root_dir = function(bufnr, on_dir)
        -- Don't attach if deno.json exists
        if vim.fs.root(bufnr, { "deno.json", "deno.jsonc" }) then return end
        local root = vim.fs.root(bufnr, { "package.json", "tsconfig.json" })
        if root then on_dir(root) end
      end,
    })

    local deno_bin_path = vim.fn.system("asdf where deno"):gsub("\n", "") .. "/bin/deno"

    -- Deno LSP: attach only inside Deno projects
    vim.lsp.config("denols", {
      cmd = { deno_bin_path, "lsp" },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      capabilities = capabilities,
      single_file_support = false,
      on_attach = setup_keybindings,
      root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
        if root then on_dir(root) end
      end,
      settings = {
        deno = {
          enable = true,
          lint = true,
          cacheOnSave = true,
          unstable = { "sloppy-imports" },
          suggest = {
            imports = {
              autoDiscover = true,
              hosts = {
                ["https://deno.land"] = true,
                ["https://cdn.nest.land"] = true,
                ["https://crux.land"] = true,
                ["https://jsr.io"] = true,
              },
            },
          },
        },
      },
    })

    -- Enable both servers; root_dir functions gate per-buffer attachment
    vim.lsp.enable({ "denols", "ts_ls" })

    -- Safety net: if both ever attach to the same buffer, keep denols and stop ts_ls
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local has_deno, ts_id
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
          if c.name == "denols" then
            has_deno = true
          end
          if c.name == "ts_ls" then
            ts_id = c.id
          end
        end
        if has_deno and ts_id then
          vim.lsp.stop_client(ts_id)
        end
      end,
    })

    -- vim.lsp.config('denols', {
    --   capabilities = capabilities,
    --   single_file_support = true,
    --   on_attach = setup_keybindings,
    -- })
    vim.lsp.config("cssmodules_ls", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    vim.lsp.enable("cssmodules_ls")

    vim.lsp.config("cssls", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    vim.lsp.enable("cssls")

    vim.lsp.config("jsonls", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })
    vim.lsp.enable("jsonls")

    -- TODO: add something for raw html

    -- vim.lsp.config("postgres_lsp", {
    --   capabilities = capabilities,
    --   on_attach = setup_keybindings,
    --   root_dir = util.root_pattern("postgrestools.jsonc"),
    --   cmd = { "postgrestools", "lsp-proxy" },
    --   filetypes = { "sql" },
    --   single_file_support = true
    -- })
    -- vim.lsp.config("sqlls", {
    --   capabilities = capabilities,
    --   -- root_dir = require('core.helpers').find_project_root,
    --   on_attach = setup_keybindings,
    -- })

    vim.lsp.config("clojure_lsp", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    vim.lsp.enable("clojure_lsp")

    vim.lsp.config("svelte", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    vim.lsp.enable("svelte")

    vim.lsp.config("tailwindcss", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
    })
    vim.lsp.enable("tailwindcss")

    vim.lsp.config("astro", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
      filetypes = { "astro" },
    })
    vim.lsp.enable("astro")

    local function get_typescript_server_path(root_dir)
      local project_root = util.find_node_modules_ancestor(root_dir)
      return project_root and (util.path.join(project_root, "node_modules", "typescript", "lib")) or ""
    end

    vim.lsp.config("mdx_analyzer", {
      capabilities = capabilities,
      on_attach = setup_keybindings,
      cmd = { "mdx-language-server", "--stdio" },
      filetypes = { "markdown.mdx", "mdx" },
      single_file_support = true,
      settings = {},
      init_options = {
        typescript = {},
      },
      root_dir = util.root_pattern("package.json"),
      on_new_config = function(new_config, new_root_dir)
        if vim.tbl_get(new_config.init_options, "typescript") and not new_config.init_options.typescript.tsdk then
          new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
        end
      end,
    })
    vim.lsp.enable("mdx_analyzer")
  end,
}
