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
    vim.g.db_ui_execute_on_save = 1
    vim.g.db_ui_disable_mappings = 1

    vim.keymap.set('n', '<CR>', '<Plug>(DBUI_SelectLine)', { noremap = true, silent = true })

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
        List = 'select * from {table} limit 100',
      }
    }

    -- change indentation of the sidebar items
    vim.o.shiftwidth = 2
  end,
}
