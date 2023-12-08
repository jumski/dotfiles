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

    -- Lua autocmd for FileType dbout to setlocal nofoldenable
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbout",
        callback = function()
            vim.opt_local.foldenable = false
        end,
    })
  end,
}
