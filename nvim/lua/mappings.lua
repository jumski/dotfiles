local map = vim.api.nvim_set_keymap
local default_opts = {noremap = true, silent = true}
local cmd = vim.cmd

vim.g.mapleader = ','

-- tab mappings
map('n', '<leader>c', ':tabnew %<CR>', default_opts)
map('n', '<leader><Tab>', ':tabp<CR>', default_opts)
map('n', '<leader>f', ':tabn<CR>', default_opts)
map('n', '<leader>x', ':tabclose<CR>', default_opts)
map('n', '<C-s>', ':w<CR>', default_opts)
map('i', '<C-s>', '<Esc>:w<CR>', default_opts)

-- vim-ai mappings
vim_ai_opts = {noremap = true}

-- :AIChat
map('n', '<leader>d', ':AIChat<CR>', vim_ai_opts)
map('x', '<leader>d', ':AIChat ', vim_ai_opts)

-- :AIEdit
map('n', '<leader>e', ':AIEdit ', vim_ai_opts)
map('x', '<leader>e', ':AIEdit ', vim_ai_opts)

-- :AIRedo
map('n', '<leader>r', ':AIRedo<CR>', vim_ai_opts)
map('x', '<leader>r', ':AIRedo<CR>', vim_ai_opts)

-- :AI
map('n', '<leader>a', ':AI<CR>', vim_ai_opts)
map('x', '<leader>a', ':AI<CR>', vim_ai_opts)
