return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    local parser_install_dir = "$HOME/.local/share/treesitter"
    vim.opt.runtimepath:append(parser_install_dir)

    require('nvim-treesitter.configs').setup {
      parser_install_dir = parser_install_dir,
      ensure_installed = {
        "bash",
        "c",
        "clojure",
        "css",
        "elvish",
        "fish",
        "javascript",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
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
      indent = { enable = true },
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
    vim.treesitter.language.register('markdown', 'chatgpt')
  end
}
