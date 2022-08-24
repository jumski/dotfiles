local map = vim.api.nvim_set_keymap
local default_opts = {noremap = true, silent = true}
local cmd = vim.cmd

vim.g.mapleader = ','

-- tab mappings
map('n', '<leader>c', ':tabnew %<CR>', default_opts)
map('n', '<leader><Tab>', ':tabp<CR>', default_opts)
map('n', '<leader>f', ':tabn<CR>', default_opts)
map('n', '<leader>x', ':tabclose<CR>', default_opts)


