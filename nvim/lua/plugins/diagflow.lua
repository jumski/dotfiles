return {
  enabled = false,
  "dgagn/diagflow.nvim",
  -- event = 'LspAttach', This is what I use personnally and it works great
  config = function()
    require("diagflow").setup({
      -- enable = function()
      --   return vim.bo.filetype ~= "lazy"
      -- end,
      show_borders = true,
      format = function(diagnostic)
        return "[Diagnostics] " .. diagnostic.message
      end,
      scope = "line",
      show_sign = true,
      padding_right = 1,
      gap = 3,
      toggle_event = { "InsertEnter" },
    })
  end,
}
