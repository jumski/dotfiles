return {
  'ggandor/leap.nvim',
  dependencies = { 'tpope/vim-repeat' }, -- for dot-repeat support
  config = function()
    -- Set up the recommended keybindings manually
    vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
    vim.keymap.set({'n', 'x', 'o'}, 'S', '<Plug>(leap-backward)')
    vim.keymap.set('n', 'gs', '<Plug>(leap-from-window)')

    -- Optional: Configure leap settings
    require('leap').opts.preview = function(ch0, ch1, ch2)
      -- Exclude whitespace and the middle of alphabetic words from preview
      return not (
        ch1:match('%s')
        or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
      )
    end

    -- Define equivalence classes for brackets and quotes
    require('leap').opts.equivalence_classes = {
      ' \t\r\n', '([{', ')]}', '\'"`'
    }

    -- Use the traversal keys to repeat the previous motion
    require('leap.user').set_repeat_keys('<enter>', '<backspace>')
  end,
}
