return {
  "tpope/vim-projectionist",
  ft = { "svelte" },
  pattern = { "svelte.config.js", "src/routes/+*.*" },
  config = function()
    vim.g.projectionist_heuristics = {
      ["svelte.config.js"] = {
        ["src/routes/*.svelte"] = { command = "route" },
        ["src/lib/*"] = { command = "lib" },
        ["src/lib/components/*.svelte"] = { command = "component" },
        ["src/*hook*"] = { command = "hook" },
        ["src/routes/*.ts"] = { command = "loader" },
      },
    }
  end,
  event = "User",
}
