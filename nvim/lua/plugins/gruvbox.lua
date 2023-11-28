return {
  "ellisonleao/gruvbox.nvim",
  dependencies = {"rktjmp/lush.nvim"},
  setup = function()
    vim.cmd [[colorscheme gruvbox]]
    vim.g.gruvbox_italic = true     -- enable italics because we are in tmux
  end
}
