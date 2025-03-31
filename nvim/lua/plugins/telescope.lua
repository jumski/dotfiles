local WHICH_KEY_MAPPINGS = {
  { "<leader>t",  group = "Telescope" },
  { "<leader>tb", "<cmd>Telescope buffers<CR>",     desc = "buffers" },
  { "<leader>td", "<cmd>Telescope diagnostics<CR>", desc = "diagnostics" },
  { "<leader>tf", "<cmd>Telescope<CR>",             desc = "Telescope" },
  { "<leader>tg", "<cmd>Telescope live_grep<CR>",   desc = "live_grep" },
  { "<leader>th", "<cmd>Telescope help_tags<CR>",   desc = "help_tags" },
  { "<leader>tk", "<cmd>Telescope keymaps<CR>",     desc = "keymaps" },
  { "<leader>tr", "<cmd>Telescope resume<CR>",      desc = "resume" },
  { "<leader>tt", "<cmd>Telescope find_files<CR>",  desc = "find_files" },
  { "<leader>tw", "<cmd>Telescope grep_string<CR>", desc = "grep_string" },
}

return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
  },
  config = function()
    require('telescope').setup({})
    require('which-key').add(WHICH_KEY_MAPPINGS)
  end
}
