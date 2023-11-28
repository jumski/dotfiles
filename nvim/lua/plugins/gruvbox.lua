return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  dependencies = {"rktjmp/lush.nvim"},
  config = function()
    vim.o.background = "dark" -- or "light" for light mode
    vim.cmd([[colorscheme gruvbox]])
    vim.g.gruvbox_italic = true     -- enable italics because we are in tmux
  end
}
