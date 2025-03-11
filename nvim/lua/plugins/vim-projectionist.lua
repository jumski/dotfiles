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
      ["functions/deno.json"] = {
        ["functions/*/index.ts"] = { command = "function" },
        ["functions/_shared/*.ts"] = { command = "shared" },
        ["tests/*.sql"] = { command = "test" },
        ["migrations/*.sql"] = { command = "migration" },
        ["seed.sql"] = { command = "seed" },
        ["queries/*.sql"] = { command = "query" },
        ["config.toml"] = { command = "config" },
        ["functions/import_map.json"] = { command = "importmap" },
      },
      ["supabase/config.toml"] = {
        ["supabase/migrations/*.sql"] = { command = "migration" },
        ["supabase/seeds/*.sql"] = { command = "seed" },
        ["supabase/seed.sql"] = { command = "seed" },
        ["supabase/tests/*.sql"] = { command = "test" },
        ["supabase/config.toml"] = { command = "config" },
      },
    }
  end,
  event = "User",
}
