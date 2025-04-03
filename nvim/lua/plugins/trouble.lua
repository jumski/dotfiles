return {
  -- enabled = false,
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    mode = "document_diagnostics", -- or 'workspace_diagnostics', "quickfix", "lsp_references", "loclist"
    -- auto_open = true,
    auto_close = true,
    auto_preview = false, -- in case of true - <esc> to exit preview
    cycle_results = false,
    signs = {
      -- icons / text used for a diagnostic
      error = "✘",
      warning = "▲",
      hint = "",
      information = "»",
      other = "",
    },
  },
  config = function(_, opts)
    local trouble = require("trouble")

    trouble.setup(opts)

    -- Lua
    vim.keymap.set("n", "<leader>xx", function()
      trouble.toggle("diagnostics")
    end)
    -- vim.keymap.set("n", "<leader>xw", function()
    --   trouble.toggle("workspace_diagnostics")
    -- end)
    -- vim.keymap.set("n", "<leader>xd", function()
    --   trouble.toggle("document_diagnostics")
    -- end)
    vim.keymap.set("n", "<leader>xq", function()
      trouble.toggle("quickfix")
    end)
    vim.keymap.set("n", "<leader>xl", function()
      trouble.toggle("loclist")
    end)
    vim.keymap.set("n", "gR", function()
      trouble.toggle("lsp_references")
    end)
  end,
}
