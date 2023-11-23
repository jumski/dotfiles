return {
  'L3MON4D3/LuaSnip',
  enabled = false,
  config = function()

    local map = vim.api.nvim_set_keymap
    local default_opts = {noremap = true, silent = true}
    local cmd = vim.cmd

    -- press <Tab> to expand or jump in a snippet. These can also be mapped separately
    -- via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
    -- imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
    map('i', '<Tab>',
      "luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'",
      { silent = true, expr = true})

    -- -1 for jumping backwards.
    -- inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>
    map('i', '<S-Tab>', "<cmd>lua require'luasnip'.jump(-1)<Cr>",
      { silent = true, noremap = true })

    -- snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
    map('s', '<Tab>', "<cmd>lua require('luasnip').jump(1)<Cr>",
      { silent = true, noremap = true })

    -- snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
    map('s', '<Tab>', "<cmd>lua require('luasnip').jump(1)<Cr>",
      { silent = true, noremap = true })

    -- snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>
    map('s', '<S-Tab>', "<cmd>lua require('luasnip').jump(-1)<Cr>",
      { silent = true, noremap = true })

    -- For changing choices in choiceNodes (not strictly necessary for a basic setup).
    -- imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
    -- smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
  end
}
