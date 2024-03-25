local WHICH_KEY_MAPPINGS = {
  t = {
    name = "Telescope",
    t = { "<cmd>Telescope find_files<CR>", "find_files" },
    f = { "<cmd>Telescope<CR>", "Telescope" },
    k = { "<cmd>Telescope keymaps<CR>", "keymaps" },
    b = { "<cmd>Telescope buffers<CR>", "buffers" },
    g = { "<cmd>Telescope live_grep<CR>", "live_grep" },
    h = { "<cmd>Telescope help_tags<CR>", "help_tags" },
    r = { "<cmd>Telescope resume<CR>", "resume" },
    w = { "<cmd>Telescope grep_string<CR>", "grep_string" },
    d = { "<cmd>Telescope diagnostics<CR>", "diagnostics" },
    -- p = { "<cmd>Telescope projects<CR>", "projects" },
  }
}

return {
  'nvim-telescope/telescope.nvim', branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup({})
    require('which-key').register(WHICH_KEY_MAPPINGS, { prefix = "<leader>" })
  end
}
