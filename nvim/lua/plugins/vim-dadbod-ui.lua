local WHICH_KEY_MAPPINGS = {
  { "<leader>d", group = "DB / DBUI", mode = {"n"} },
  {
    mode = { "n", "v" },
    { "<leader>df", "<cmd>DBUIFindBuffer<CR>", desc = "Find buffer" },
    { "<leader>da", "<cmd>DBUIAddConnection<CR>", desc = "Add connection" },
    { "<leader>dt", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
    { "<leader>dl", "<cmd>DBUILastQueryInfo<CR>", desc = "Last query info" },
  },
  { "<leader>dd", "<cmd>%DB<CR>", desc = "Execute SQL", mode = {"n"} },
  { "<leader>dd", ":'<,'>DB<CR>", desc = "Execute SQL", mode = {"v"} },

  -- control-d does same than <leader>dd
  { "<C-d>", "<cmd>%DB<CR>", desc = "Execute SQL", mode = {"n"} },
  { "<C-d>", ":'<,'>DB<CR>", desc = "Execute SQL", mode = {"v"} },
}

return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  ft = { 'sql', 'mysql', 'plsql' },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    -- vim.g.db_ui_disable_mappings = 1

    vim.g.db_ui_use_nerd_fonts = 1

    -- be explicit about execution with which-key mappings
    vim.g.db_ui_execute_on_save = 0

    require("which-key").add(WHICH_KEY_MAPPINGS)

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
        Describe_Table = '\\dt+ {schema}.{table}',
        List = 'select * from {schema}.{table} limit 100; \\x on',
      }
    }

    -- change indentation of the sidebar items
    vim.o.shiftwidth = 2

    local HOME_PATH = vim.fn.expand("$HOME")
    vim.g.db_ui_save_location = HOME_PATH .. '/SynologyDrive/Areas/Dev/neovim_db_ui_queries'
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
