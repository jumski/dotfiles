return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({})
    mason_lspconfig.setup({})

    mason_tool_installer.setup({
      ensure_installed = {
        "astro",
        "clojure_lsp",
        "cssls",
        "cssmodules_ls",
        "denols",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "json-lsp",
        "lua_ls",
        "mdx-analyzer",
        "pyright",
        "ruff-lsp",
        "solargraph",
        "sorbet",
        "sqlls",
        "svelte",
        "tailwindcss",
        "ts_ls",
      },
      automatic_installation = true,
    })
  end,
}
