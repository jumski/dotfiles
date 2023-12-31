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
        'solargraph',
        'sorbet',
        'lua_ls',
        'pyright',
        'pyright',
        'tsserver',
        'cssmodules_ls',
        'cssls',
        'sqlls',
        'clojure_lsp',
        'svelte'
      },
      automatic_installation = true
    })

--     mason_tool_installer.setup({
--     })
  end
}
