return {
  'tpope/vim-commentary',
  config = function()
    vim.cmd([[
      autocmd FileType sql setlocal commentstring=--\ %s
    ]])
  end
}
