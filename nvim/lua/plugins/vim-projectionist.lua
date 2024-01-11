return {
  "tpope/vim-projectionist",
  ft = { "svelte" },
  pattern = { "svelte.config.js", "src/routes/+*.*" },
  config = function()
    vim.g.projectionist_heuristics = {
      ["svelte.config.js"] = {
        ["src/routes/*.svelte"] = { command = "route" },
        ["src/routes/*.ts"] = { command = "sroute" },
        ["src/lib/*"] = { command = "lib" },
        ["src/lib/components/*.svelte"] = { command = "component" },
      },
    }
  end,
  event = "User",
}
