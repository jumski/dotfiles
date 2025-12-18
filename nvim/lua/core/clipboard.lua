-- Clipboard Configuration
--
-- DESIGN: Vim registers are kept SEPARATE from system clipboard.
-- This prevents external copies (browser, etc.) from overwriting vim yanks.
--
-- Workflow:
--   yy / p      → vim internal registers (linewise behavior preserved)
--   <leader>p   → paste from system clipboard (browser Ctrl+C, etc.)
--   "+y         → explicitly yank to system clipboard
--
-- Why not clipboard=unnamedplus?
--   It syncs unnamed register with system clipboard, which means:
--   - Firefox Ctrl+C overwrites what you just yanked in vim
--   - Loses linewise/charwise metadata on paste
--
-- Provider (for explicit "+ register access):
--   Local:  tmux buffer with OSC 52 sync
--   SSH:    OSC 52 passthrough via tmux

-- Clipboard provider for "+ and "* registers
if vim.env.TMUX ~= nil then
  local copy = {'tmux', 'load-buffer', '-w', '-'}
  local paste = {'bash', '-c', 'tmux refresh-client -l && sleep 0.05 && tmux save-buffer -'}
  vim.g.clipboard = {
    name = 'tmux',
    copy = {['+'] = copy, ['*'] = copy},
    paste = {['+'] = paste, ['*'] = paste},
    cache_enabled = 0,
  }
else
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
end

-- <leader>p: Paste from system clipboard on new line
-- Uses xclip locally, OSC 52 over SSH
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
