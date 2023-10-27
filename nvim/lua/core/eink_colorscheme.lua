-- eink color scheme
vim.opt.termguicolors = true
vim.cmd([[
    hi Normal guifg=#000000 guibg=#FFFFFF
    hi Comment guifg=#444444 gui=italic
    hi Constant guifg=#444444
    hi String guifg=#888888
    hi Identifier guifg=#000000 gui=bold
    hi LineNr guifg=#888888
    hi ErrorMsg guifg=#000000 gui=underline
]])
