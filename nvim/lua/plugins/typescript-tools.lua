return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  opts = {
    init_options = {
      plugins = {
        { name = '@nx/typescript-plugin', location = 'node_modules/@nx/js' }
      }
    },
    root_dir = function(fname)
      local util = require("lspconfig.util")

      -- if util.root_pattern("deno.json", "deno.jsonc", "import_map.json")(fname) then
      --   return nil
      -- end

      return util.root_pattern("nx.json", "tsconfig.base.json", "tsconfig.json", "project.json", "package.json")(fname)
    end,
  },
}
