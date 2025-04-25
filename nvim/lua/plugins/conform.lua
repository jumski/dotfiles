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
      sql = { "sqruff", "trim_newlines" },
      javascript = { "prettierd", stop_after_first = true },
      typescript = { "prettierd", stop_after_first = true },
      svelte = { "prettierd", stop_after_first = true },
      -- Add trim_whitespace to all file types
      -- ["*"] = { "trim_whitespace", "trim_newlines" },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save
    -- format_after_save = { timeout_ms = 500 },
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
      sqruff = {
        -- Use a function that will be called when the formatter is used
        cwd = function(self, ctx)
          -- Load the util module when the function is called
          return require("conform.util").root_file(".sqruff")(self, ctx)
        end,
        args = function(ctx)
          -- Make sure we have a valid source directory
          local source_dir = ctx.dirname or vim.fn.expand("%:p:h")

          -- Find the config file
          local root_dir = vim.fs.root(source_dir, ".sqruff")

          -- Start with base command
          local args = {}

          -- Add config if found (directly after command name)
          if root_dir then
            local config_path = root_dir .. "/.sqruff"
            table.insert(args, "--config=" .. config_path)
          end

          -- Add the rest of the arguments
          table.insert(args, "fix")
          table.insert(args, "--parsing-errors")
          table.insert(args, "--force")
          table.insert(args, "-")

          return args
        end,
        stdin = true,
      },
    },
    log_level = vim.log.levels.DEBUG,
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
