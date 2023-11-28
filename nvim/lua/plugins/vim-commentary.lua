return {
  'tpope/vim-commentary',
  lazy = false,
  config = function()
    vim.cmd([[
      autocmd FileType sql setlocal commentstring=--\ %s
    ]])
  end
}
