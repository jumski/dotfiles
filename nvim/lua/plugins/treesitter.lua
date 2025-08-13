return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local parser_install_dir = "$HOME/.local/share/treesitter"
    vim.opt.runtimepath:append(parser_install_dir)

    require("nvim-treesitter.configs").setup({
      ensure_installed = {},
      parser_install_dir = parser_install_dir,
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-n>",
          node_incremental = "<C-n>",
          scope_incremental = "<C-s>",
          node_decremental = "<C-m>",
        },
      },
      textobjects = { enable = true },
      modules = {},
      ignore_install = {},
    })
    vim.treesitter.language.register("markdown", "chatgpt")
    vim.treesitter.language.register("markdown", "mdx")

    ----------------------------------------------------------------------------
    --- D2 integration ---------------------------------------------------------
    ----------------------------------------------------------------------------
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.d2 = {
      install_info = {
        url = "https://github.com/ravsii/tree-sitter-d2",
        files = { "src/parser.c" },
        branch = "main"
      },
      filetype = "d2",
    }

    -- we also need to tell neovim to use "d2" filetype on "*.d2" files, as well as
    -- token comment.
    -- ftplugin/autocmd is also an option.
    vim.filetype.add({
      extension = {
        d2 = function()
          return "d2", function(bufnr)
            vim.bo[bufnr].commentstring = "# %s"
          end
        end,
      },
    })
  end,
}
