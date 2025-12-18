local map = vim.api.nvim_set_keymap
local default_opts = {noremap = true, silent = true}
local cmd = vim.cmd

vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- tab mappings
-- map('n', '<leader>c', ':tabnew %<CR>', default_opts)
map('n', '<leader><Tab>', ':tabp<CR>', default_opts)
map('n', '<leader>f', ':tabn<CR>', default_opts)
map('n', '<leader>q', ':tabclose<CR>', default_opts)
map('n', '<C-s>', ':w<CR>', default_opts)
map('i', '<C-s>', '<Esc>:w<CR>', default_opts)

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

-- easier pasting from OS
-- Paste from system clipboard on new line (xclip locally, OSC 52 over SSH)
vim.keymap.set('n', '<leader>p', function()
  local content
  if vim.env.SSH_TTY then
    vim.fn.system('tmux refresh-client -l')
    vim.cmd('sleep 100m')
    content = vim.fn.system('tmux save-buffer -')
  else
    content = vim.fn.system('xclip -o -sel clipboard 2>/dev/null')
    if content == '' then
      content = vim.fn.system('xclip -o -sel primary 2>/dev/null')
    end
  end
  if content ~= '' then
    vim.cmd('normal! o')
    vim.api.nvim_put(vim.split(content, '\n'), 'c', false, true)
  end
end, { noremap = true, silent = true, desc = 'Paste from system clipboard on new line' })
-- map('n', '<leader>c', '"+c', default_opts) -- conflicts with new-tab
