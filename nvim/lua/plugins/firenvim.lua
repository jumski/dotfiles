return {
  'glacambre/firenvim',
  enabled = false,
  -- Lazy load firenvim
  -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
  -- lazy = not vim.g.started_by_firenvim,
  lazy = false,
  build = function()
    vim.fn["firenvim#install"](0)
  end
}
