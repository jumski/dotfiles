-- Clipboard Configuration
-- See CLIPBOARD.md for full documentation
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
--   Copy:  tmux buffer with OSC 52 sync
--   Paste: xclip first (for Firefox/Kitty), fallback to tmux buffer

-- Clipboard provider for "+ and "* registers
if vim.env.TMUX ~= nil then
  local copy = {'tmux', 'load-buffer', '-w', '-'}
  -- Paste: try xclip first (for Firefox/Kitty copies), fall back to tmux buffer
  local paste = {'bash', '-c', [[
    content=$(xclip -o -sel clipboard 2>/dev/null)
    [ -z "$content" ] && content=$(tmux save-buffer - 2>/dev/null)
    echo -n "$content"
  ]]}
  vim.g.clipboard = {
    name = 'tmux+xclip',
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
-- Uses :put + which explicitly pastes the + register on a new line
vim.keymap.set('n', '<leader>p', ':put +<CR>', {
  noremap = true,
  silent = true,
  desc = 'Paste from system clipboard on new line'
})
