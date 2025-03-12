return {
  -- enabled = false,
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    -- {
    --   -- Customize or remove this keymap to your liking
    --   "<leader>f",
    --   function()
    --     require("conform").format({ async = true })
    --   end,
    --   mode = "",
    --   desc = "Format buffer",
    -- },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      sql = { "sqruff" },
      javascript = { "prettierd", stop_after_first = true },
      typescript = { "prettierd", stop_after_first = true },
      svelte = { "prettierd", stop_after_first = true },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save
    format_after_save = { timeout_ms = 2000 },
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
      sqruff = {
        -- Updated args to use the correct command syntax for sqruff
        args = { "fix", "--force", "-" },
      },
      -- sqlfluff = function(bufrn)
      --   return {
      --     require_cwd = true,
      --     stdin = true,
      --     args = function()
      --       return { "format", "-" }
      --     end,
      --     cwd = require("conform.util").root_file({
      --       ".sqlfluff",
      --       "migrations", -- supabase
      --       "seed.sql", -- supabase
      --     }),
      --   }
      -- end,
    },
    log_level = vim.log.levels.DEBUG,
  },
  config = function(_, opts)
    -- Set up the cwd for sqruff here, after the plugin is loaded
    opts.formatters.sqruff.cwd = require("conform.util").root_file({ "nx.json", ".editorconfig", ".git" })

    require("conform").setup(opts)
  end,
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
