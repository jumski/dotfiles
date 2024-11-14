return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local parser_install_dir = "$HOME/.local/share/treesitter"
    vim.opt.runtimepath:append(parser_install_dir)

    require("nvim-treesitter.configs").setup({
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
    vim.treesitter.language.register("typescript", "markdown.mdx")
    vim.treesitter.language.register("javascript", "markdown.mdx")
    vim.treesitter.query.set(
      "markdown",
      "injections",
      [[
      ((inline) @injection.content
        (#lua-match? @injection.content "^%s*import")
        (#set! injection.language "typescript"))
      ((inline) @injection.content
        (#lua-match? @injection.content "^%s*export")
        (#set! injection.language "typescript"))
    ]]
    )
    vim.treesitter.query.set(
      "markdown",
      "injections",
      [[
      (fenced_code_block (info_string) @language (#match? @language "^typescript$|^tsx$"))
    ]]
    )
    vim.treesitter.query.set(
      "markdown",
      "highlights",
      [[
      ((inline) @_inline (#lua-match? @_inline "^%s*import")) @nospell
      ((inline) @_inline (#lua-match? @_inline "^%s*export")) @nospell
    ]]
    )
  end,
}
