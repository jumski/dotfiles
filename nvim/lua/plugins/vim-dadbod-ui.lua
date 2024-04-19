local WHICH_KEY_MAPPINGS = {
  d = {
    name = "DB / DBUI",
    d = { "<cmd>%DB<CR>", "Execute SQL", mode = { "n", "v" } },
    f = { "<cmd>DBUIFindBuffer<CR>", "Find buffer", mode = { "n", "v" } },
    t = { "<cmd>DBUI<CR>", "Toggle DBUI", mode = { "n", "v" } },
    a = { "<cmd>DBUIAddConnection<CR>", "Add connection", mode = { "n", "v" } },
    l = { "<cmd>DBUILastQueryInfo<CR>", "Last query info", mode = { "n", "v" } },
  }
}

return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1

    -- be explicit about execution with which-key mappings
    vim.g.db_ui_execute_on_save = 0

    require("which-key").register(WHICH_KEY_MAPPINGS, { prefix = "<leader>", })

    -- Lua autocmd for FileType dbout to setlocal nofoldenable
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbout",
        callback = function()
            vim.opt_local.foldenable = false
        end,
    })

    vim.g.db_ui_auto_execute_table_helpers = 1
    vim.g.db_ui_table_helpers = {
      postgresql = {
        List = 'select * from {table} limit 100 \\x',
      }
    }

    -- change indentation of the sidebar items
    vim.o.shiftwidth = 2

    local HOME_PATH = vim.fn.expand("$HOME")
    vim.g.db_ui_save_location = HOME_PATH .. '/SynologyDrive/Areas/Dev/neovim_db_ui_queries'
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
