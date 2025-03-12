return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "jose-elias-alvarez/null-ls.nvim",
  },
  config = function()
    local null_ls = require("null-ls")

    local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
    local event = "BufWritePost"
    -- local event = "BufWritePre" -- or "BufWritePost"
    local async = event == "BufWritePost"

    null_ls.setup({
      sources = {
        null_ls.builtins.diagnostics.sqruff.with({
          extra_args = { "--dialect", "postgres" },
        }),
        null_ls.builtins.formatting.prettier.with({
          extra_filetypes = { "astro" },
        }),
        -- null_ls.builtins.diagnostics.eslint,
        -- null_ls.builtins.completion.spell,
      },
      -- TODO: enable when removing conform.nvim
      -- on_attach = function(client, bufnr)
      --   if client.supports_method("textDocument/formatting") then
      --     -- vim.keymap.set("n", "<Leader>f", function()
      --     --   vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      --     -- end, { buffer = bufnr, desc = "[lsp] format" })
      --
      --     -- format on save
      --     vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      --     vim.api.nvim_create_autocmd(event, {
      --       buffer = bufnr,
      --       group = group,
      --       callback = function()
      --         vim.lsp.buf.format({
      --           bufnr = bufnr,
      --           async = async,
      --           filter = function(_client)
      --             -- only use null-ls for formatting instead of lsp server
      --             return _client.name == "null-ls"
      --           end
      --         })
      --       end,
      --       desc = "[lsp] format on save",
      --     })
      --   end
      --
      --   if client.supports_method("textDocument/rangeFormatting") then
      --     -- vim.keymap.set("x", "<Leader>f", function()
      --     --   vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      --     -- end, { buffer = bufnr, desc = "[lsp] format" })
      --   end
      -- end,
    })
  end,
}
