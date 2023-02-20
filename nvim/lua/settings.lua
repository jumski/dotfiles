local cmd = vim.cmd     				-- execute Vim commands
local exec = vim.api.nvim_exec 	-- execute Vimscript
local fn = vim.fn       				-- call Vim functions
local g = vim.g         				-- global variables
local opt = vim.opt         		-- global/buffer/windows-scoped options

--- General
opt.mouse = 'a'             -- enable mouse support
opt.swapfile = false        -- do not use swapfile
opt.writebackup = false     -- do not use backup files
opt.history = 5000          -- remember n-lines in history
opt.modeline = false        -- disable reading modelines
opt.hidden = true           -- 1. The current buffer can be put to the background without writing to disk
                            -- 2. When a background buffer becomes current again, marks and undo-history are remembered
opt.sessionoptions = 'buffers,winsize,tabpages,winpos,winsize' -- session saving options

--- Performance
opt.lazyredraw = true       -- do not redraw while executing macros etc
opt.ttyfast = true          -- indicates a fast terminal connection
                            -- (more characters will be sent to the screen for redrawing)
opt.timeoutlen = 800        -- time out on mapping
opt.ttimeoutlen = 100       -- time out on key codes after a tenth of a second

--- Style / themes
opt.background = 'dark'     -- use dark background
opt.termguicolors = true    -- needed to properly show colors in tmux
cmd [[colorscheme gruvbox]]
g.gruvbox_italic = true     -- enable italics because we are in tmux

--- UI
opt.number = false          -- do not show line numbering
opt.laststatus = 2          -- always show status line
opt.autoread = true         -- automatically read file if it changes
                            -- (this does not happen if file is deleted)
opt.showcmd = true          -- show incomplete commands
opt.showmode = false        -- do not display the mode you're in, because of status line
opt.cmdwinheight = 10       -- command history window height
opt.splitbelow = true       -- vertical splits below
opt.splitright = true       -- horizontal splits on right
opt.incsearch = true        -- show results during typing the search
opt.scrolloff = 3           -- always show at least n-lines below and above cursor
opt.sidescrolloff = 5       -- always show at least n-chars before and after cursor
opt.wildmenu = true         -- change behaviour of <TAB> completion of commands
                            -- to similar to bash completion
opt.wildmode= 'list:longest,list:full'
opt.colorcolumn = '80'      -- back to the 80s XD


--- Typing / characters / matching
opt.wildignorecase = true   -- ignore case when <TAB>completing filenames
opt.showmatch = true        -- show matching bracket
opt.matchtime = 2           -- show it for 2 seconds
opt.ignorecase = true       -- ignore capitals when searching
opt.smartcase = true        -- case sensitive search only when first letter is capital

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
opt.grepprg = 'rg --nogroup --nocolor' -- us ripgrep as grep

