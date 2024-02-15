return {
  'MunifTanjim/prettier.nvim',
  -- enabled = false,
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvimtools/none-ls.nvim'
  },
  opts = {
    bin = 'prettier',
    filetypes = {
      "css",
      "graphql",
      "html",
      "javascript",
      "javascriptreact",
      "json",
      "less",
      "lua",
      "markdown",
      "scss",
      "typescript",
      "typescriptreact",
      "yaml",
    }
  }
}
