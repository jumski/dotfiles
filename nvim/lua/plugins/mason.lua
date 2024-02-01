return {
  'williamboman/mason.nvim',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
		-- "WhoIsSethDaniel/mason-tool-installer.nvim"
  },
  config = function()
    local mason = require('mason')
    local mason_lspconfig = require('mason-lspconfig')
    -- local mason_tool_installer = require("mason-tool-installer")

    mason.setup({})
    mason_lspconfig.setup({
      ensure_installed = {
        'clojure_lsp',
        'cssls',
        'cssmodules_ls',
        'denols',
        'lua_ls',
        'pyright',
        'solargraph',
        'sorbet',
        'sqlls',
        'svelte',
        'tailwindcss',
        'tsserver',
      },
      automatic_installation = true
    })

--     mason_tool_installer.setup({
--     })
  end
}
