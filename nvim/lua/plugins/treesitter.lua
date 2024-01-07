return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        "c",
        "clojure",
        "css",
        "fish",
        "javascript",
        "lua",
        "python",
        "query",
        "ruby",
        "rust",
        "scss",
        "sql",
        "svelte",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = false,
      sync_install = false,
      highlight = {
        enable = true,
        disable = { }
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-n>",
          node_incremental = "<C-n>",
          scope_incremental = "<C-s>",
          node_decremental = "<C-m>",
        }
      },
      textobjects = { enable = true },
      modules = {},
      ignore_install = {},
    }
  end
}
