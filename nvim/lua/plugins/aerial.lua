local WHICH_KEY_MAPPINGS = {
  { "<leader>a", group = "Aerial" },
  { "<leader>aA", "<cmd>AerialToggle!<CR>", desc = "Sidebar Toggle" },
  { "<leader>aa", "<cmd>AerialNavToggle<CR>", desc = "Nav Toggle" },
}

return {
  'folke/aerial.nvim',
  enabled = false,
  config = function()
    require('aerial').setup({
      layout = {
        default_direction = 'left',
        resize_to_content = true,
      },
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
      -- on_attach = function(bufnr)
      --   -- Jump forwards/backwards with '{' and '}'
      --   vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {buffer = bufnr})
      --   vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {buffer = bufnr})
      -- end
    })
    -- You probably also want to set a keymap to toggle aerial
    -- vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')

    require('which-key').add(WHICH_KEY_MAPPINGS)
  end
}
