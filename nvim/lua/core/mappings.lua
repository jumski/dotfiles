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

-- :GitCommitMessage
map('n', '<leader>g', ':GitCommitMessage<CR>', vim_ai_opts)

-- Change behavior of line-up/line-down in normal mode
map('n', 'j', 'gj', default_opts)
map('n', 'k', 'gk', default_opts)
map('n', '$', 'g$', default_opts)
map('n', '^', 'g^', default_opts)
map('n', '0', 'g0', default_opts)
map('v', 'j', 'gj', default_opts)
map('v', 'k', 'gk', default_opts)
map('v', '$', 'g$', default_opts)
map('v', '^', 'g^', default_opts)
map('v', '0', 'g0', default_opts)

-- replase word under cursor in whole file
map('n', '<leader>:', '"xyiw:%s/<C-R>x/', {noremap = true})

-- keeps visual mode after indenting
map('v', '>', '>gv', default_opts)
map('v', '<', '<gv', default_opts)

-- Y yanks to the end of line
map('n', 'Y', 'y$', default_opts)

-- `a jumps to line and column marked ma
-- 'a jumps only to line marked ma
-- so we swap each other because ' have easy access
map('n', "'", '`', default_opts)
map('n', '`', "'", default_opts)

-- save with C-S
map('n', '<C-s>', ':update<CR>', default_opts)
map('v', '<C-s>', '<C-C>:update<CR>', default_opts)
map('i', '<C-s>', '<Esc>:update<CR>', default_opts)

-- this allows all window commands in insert mode and i'm not accidentally deleting words anymore :-)"
map('i', '<C-w>', '<C-o><C-w>', default_opts)
