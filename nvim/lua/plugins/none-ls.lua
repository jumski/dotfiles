return {
  'nvimtools/none-ls.nvim',
  enabled = false,
  config = function()
    local none_ls = require("null-ls")

    none_ls.setup({
        sources = {
            none_ls.builtins.formatting.stylua,
            none_ls.builtins.diagnostics.eslint,
            none_ls.builtins.diagnostics.prettier,
            none_ls.builtins.completion.spell,
        },
    })
  end
}
