-- Native OSC 52 clipboard provider (Neovim 0.10+)
-- Works seamlessly with tmux + kitty

if vim.env.TMUX ~= nil then
  -- When inside tmux, sync clipboard with tmux buffer
  local copy = {'tmux', 'load-buffer', '-w', '-'}
  -- Local: use xclip (clipboard first, then primary); SSH: use OSC 52
  local paste = {'bash', '-c', [[
    if [ -z "$SSH_TTY" ]; then
      content=$(xclip -o -sel clipboard 2>/dev/null)
      [ -z "$content" ] && content=$(xclip -o -sel primary 2>/dev/null)
      [ -n "$content" ] && echo -n "$content" || tmux save-buffer -
    else
      tmux refresh-client -l; sleep 0.1; tmux save-buffer -
    fi
  ]]}
  vim.g.clipboard = {
    name = 'tmux',
    copy = {
      ['+'] = copy,
      ['*'] = copy,
    },
    paste = {
      ['+'] = paste,
      ['*'] = paste,
    },
    cache_enabled = 0,
  }
else
  -- When not in tmux, use native OSC 52
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
