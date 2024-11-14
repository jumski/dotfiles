local cmd = vim.cmd -- execute Vim commands
local exec = vim.api.vim_exec -- execute Vimscript
local fn = vim.fn -- call Vim functions
local g = vim.g -- global variables
local opt = vim.opt -- global/buffer/windows-scoped options

opt.shell = "/bin/sh" -- vim must use POSIX shell and fish is not POSIX

--- General
opt.mouse = "a" -- enable mouse support
opt.swapfile = false -- do not use swapfile
opt.writebackup = false -- do not use backup files
opt.history = 5000 -- remember n-lines in history
opt.modeline = false -- disable reading modelines
opt.hidden = true -- 1. The current buffer can be put to the background without writing to disk
-- 2. When a background buffer becomes current again, marks and undo-history are remembered
opt.sessionoptions = "buffers,winsize,tabpages,winpos,winsize" -- session saving options

opt.clipboard = "unnamedplus" -- use system clipboard

--- Performance
opt.ttyfast = true -- indicates a fast terminal connection
-- (more characters will be sent to the screen for redrawing)
opt.timeoutlen = 300 -- time out on mapping
opt.ttimeoutlen = 100 -- time out on key codes after a tenth of a second

-- disabled because noice.nvim complained about it
-- opt.lazyredraw = true       -- do not redraw while executing macros etc

--- Style / themes
opt.termguicolors = true -- needed to properly show colors in tmux
-- cmd [[colorscheme eink]]
-- opt.background = 'light'     -- use dark background
opt.background = "dark" -- use dark background

--- UI
opt.number = false -- do not show line numbering
opt.laststatus = 2 -- always show status line
opt.autoread = true -- automatically read file if it changes

-- ignore "Hit enter" messages
-- see: https://github.com/folke/noice.nvim/wiki/A-Guide-to-Messages#handling-hit-enter-messages
-- opt.shortmess:append('sWAIcCqFS')

opt.shortmess:append("IWs")

-- (this does not happen if file is deleted)
opt.showcmd = true -- show incomplete commands
opt.showmode = false -- do not display the mode you're in, because of status line
opt.cmdwinheight = 10 -- command history window height
opt.splitbelow = true -- vertical splits below
opt.splitright = true -- horizontal splits on right
opt.incsearch = true -- show results during typing the search
opt.scrolloff = 3 -- always show at least n-lines below and above cursor
opt.sidescrolloff = 5 -- always show at least n-chars before and after cursor
opt.wildmenu = true -- change behaviour of <TAB> completion of commands
-- to similar to bash completion
opt.wildmode = "list:longest,list:full"
opt.colorcolumn = "80" -- back to the 80s XD

--- Typing / characters / matching
opt.wildignorecase = true -- ignore case when <TAB>completing filenames
opt.showmatch = true -- show matching bracket
opt.matchtime = 2 -- show it for 2 seconds
opt.ignorecase = true -- ignore capitals when searching
opt.smartcase = true -- case sensitive search only when first letter is capital

opt.tabstop = 2
-- "================ TABS AND SPACES
-- set expandtab     " all tabs expands to spaces
-- set sw=2          " automagic indent width
-- set tabstop=2     " size of tab in spaces
-- set ts=2          " size of tab
-- set shiftround    " round indent to multiple of 'shiftwidth', applies to > and <
-- set smarttab
-- set softtabstop=2 " number of spaces that a <Tab> counts for
--                   " while performing editing operations

--- Programs
opt.grepprg = "rg --nogroup --nocolor" -- us ripgrep as grep

--- auto commands
--- make all vim windows same size everytime vim window is resized
cmd([[autocmd VimResized * wincmd =]])

-- " add char pairs that can be navigated with %
opt.matchpairs:append("<:>")

-- in ruby ? and : can be a part of keyword
opt.iskeyword:append("?")
opt.iskeyword:append("!")

local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = "",
  })
end

sign({ name = "DiagnosticSignError", text = "✘" })
sign({ name = "DiagnosticSignWarn", text = "▲" })
sign({ name = "DiagnosticSignHint", text = "⚑" })
sign({ name = "DiagnosticSignInfo", text = "»" })

--------------------------------
--- SIGN COLUMN ----------------
--------------------------------

-- Function to update the sign column color
-- local function update_sign_column_color()
--   local bufnr = vim.api.nvim_get_current_buf()
--   local signs = vim.fn.sign_getplaced(bufnr, {group = '*'})[1].signs
--   local has_signs = #signs > 0

--   -- Define your colors for empty and non-empty sign column
--   local color_empty = 'SignColumn'
--   local color_non_empty = 'WarningMsg' -- Change to your preferred highlight group

--   -- Apply the highlight based on whether there are signs
--   if has_signs then
--     vim.cmd('highlight! link SignColumn ' .. color_non_empty)
--   else
--     vim.cmd('highlight! link SignColumn ' .. color_empty)
--   end
-- end

-- Autocommand to trigger the sign column color update on certain events
-- vim.api.nvim_create_autocmd(
--   {'BufEnter', 'CursorHold', 'TextChanged', 'DiagnosticChanged', 'InsertLeave', 'BufWinEnter'},
--   {
--     pattern = '*',
--     callback = update_sign_column_color,
--   }
-- )

-- Ensure that the sign column is always visible
-- vim.wo.signcolumn = 'yes'

-- vim.cmd('highlight CustomSignColumnNonEmpty guibg=#FF0000 guifg=#FFFFFF')

vim.filetype.add({
  extension = {
    postcss = "css",
  },
})

vim.filetype.add({
  pattern = {
    ["*.gitconfig*"] = "gitconfig",
    ["gitconfig.symlink"] = "gitconfig",
    ["*.gitaliases*"] = "gitconfig",
    ["gitaliases.symlink"] = "gitconfig",
  },
})

vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
    astro = "astro",
  },
})

-- set textwidth to 100 in commit messages, also enable the line visual
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  command = "setlocal textwidth=100 colorcolumn=+1",
})
