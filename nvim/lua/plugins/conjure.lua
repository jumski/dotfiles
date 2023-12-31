return {
  "Olical/conjure",
  ft = { "clojure", "fennel", "python" }, -- etc
  -- [Optional] cmp-conjure for cmp
  dependencies = {
    {
      "PaterJason/cmp-conjure",
      config = function()
        local cmp = require("cmp")
        local config = cmp.get_config()
        table.insert(config.sources, {
          name = "buffer",
          option = {
            sources = {
              { name = "conjure" },
            },
          },
        })
        cmp.setup(config)
      end,
    },
  },
  config = function(_, opts)
    require("conjure.main").main()
    require("conjure.mapping")["on-filetype"]()
  end,
  init = function()
    local helpers = require("core.helpers")

    -- Set configuration options here
    -- vim.g["conjure#debug"] = true

    -- Disable the documentation mapping
    -- vim.g["conjure#mapping#doc_word"] = false

    -- Rebind it from K to <prefix>gk
    vim.g["conjure#mapping#doc_word"] = "gk"

    vim.g["conjure#client#python#command"] = helpers.project_python_runtime()

    -- Reset it to the default unprefixed K (note the special table wrapped syntax)
    -- vim.g["conjure#mapping#doc_word"] = {"K"}

    -- disable lsp diagnostics in conjure-log buffers
    vim.api.nvim_create_autocmd("BufNewFile", {
      group = vim.api.nvim_create_augroup("conjure_log_disable_lsp", { clear = true }),
      pattern = { "conjure-log-*" },
      callback = function() vim.diagnostic.disable(0) end,
      desc = "Conjure Log disable LSP diagnostics",
    })
  end,
}
