return {
  'nvim-treesitter/nvim-treesitter',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        "c",
        "clojure",
        "css",
        "javascript",
        "lua",
        "python",
        "query",
        "ruby",
        "rust",
        "scss",
        "sql",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        disable = { }
      },
      incremental_selection = { enable = true },
      textobjects = { enable = true },
    }
  end
}
