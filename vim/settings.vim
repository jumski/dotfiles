
" enable mouse, yeah, it is the time...
set mouse=a

" default file encoding
set fileencodings=utf-8,latin2
set encoding=utf-8

" intuitive backspacing in insert mode
set backspace=indent,eol,start

" maintain long history
set history=5000

" set swap files dirs
set noswapfile
set nowritebackup

" set tags file location
set tags=TAGS;~/

" use horizontal line at cursor position
" WARNING !!!
" this makese moving cursor VERY slow!!!
" !!!!!!!!!!!
" set cursorline

" disable line numbering
set nonu

" always show status line
set laststatus=2

" make the command mode less annyoing
cnoremap <c-a> <Home>
cnoremap <c-e> <End>
cnoremap <c-p> <Up>
cnoremap <c-n> <Down>
cnoremap <c-b> <Left>
cnoremap <c-o><c-f> <Right>
cnoremap <c-d> <Del>
cnoremap <c-k> <C-\>estrpart(getcmdline(), 0, getcmdpos()-1)<cr>>

" " status line --------------------------------------------------------------
" set statusline=
" " file name
" set statusline+=%f\ %2*%m\ %1*%h
" " generic warning message
" set statusline+=%#warningmsg#
" " Syntastic status
" set statusline+=%{SyntasticStatuslineFlag()}
"
" " FuGITive status
" set statusline+=%{fugitive#statusline()}
" " span
" "
" set statusline+=%*
" " [ encoding CR-type filetype]
" set statusline+=%r%=[%{&encoding}\ %{&fileformat}\ %{strlen(&ft)?&ft:'none'}]
"
" " current column line and total number of lines
" set statusline+=\ %12.(%c:%l/%L%)

" automatically read file if it changes
" this does not happen if file is deleted
set autoread

" display incomplete commands
set showcmd

" display the mode you're in
set showmode

" do not reindent when inserting :
set cinkeys-=:

" file type highlighting and configuration
syntax enable
filetype on
filetype plugin on
filetype indent on
filetype plugin indent on

" Use the old vim regex engine (version 1, as opposed to version 2, which was
" introduced in Vim 7.3.969). The Ruby syntax highlighting is significantly
" slower with the new regex engine.
set re=1


" set number of colors
set t_Co=256

" use dark background
set background=dark

" show 80 columns marker
set colorcolumn=80

" use solarized scheme
let g:solarized_termtrans = 1
colorscheme solarized

" do not redraw while executing macros etc
set lazyredraw

" force syntax highlighting on certain filetypes
au BufNewFile,BufRead Rakefile,Capfile,Guardfile,Gemfile,Vagrantfile,pryrc,*.god,*.cap,*.rake setfiletype ruby
au BufNewFile,BufRead *.erb.deface setfiletype eruby
au BufNewFile,BufRead *.haml.deface setfiletype eruby
au BufNewFile,BufRead *.json set ft=javascript
au BufNewFile,BufRead *.hamlc setfiletype haml
au BufNewFile,BufRead Dockerfile setfiletype conf
au BufNewFile,BufRead .psqlrc setfiletype sql
au BufNewFile,BufRead *.js.erb set filetype=eruby.javascript

augroup ft_rb
    au!
    " fix the SLOOOW syntax highlighting
    au FileType ruby setlocal re=1 foldmethod=manual
augroup END

" force tabwidth per filetype
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2

" " disable some features for certain filetypes
" au BufRead *.yml,*.json se nomodeline

" use ack as grep
set grepprg=ag\ --nogroup\ --nocolor

" change behaviour of <TAB> completion of commands
" to similar to bash completion
set wildmenu
set wildmode=list:longest,list:full

" ignore files
set wildignore+=*/tmp/*,*.so,*.swp,*.zip

" ignore case when <TAB>completing filenames
set wildignorecase

" command history window height
set cmdwinheight=10

" indicates a fast terminal connection
" more characters will be sent to the screen for redrawing
set ttyfast

" time out on mapping after three seconds
" time out on key codes after a tenth of a second
set timeoutlen=800
set ttimeoutlen=100

" add char pairs that can be navigated with %
set matchpairs+=<:>
set matchpairs+=/:/

" show matching bracket for 2 seconds when inserter
set showmatch
set matchtime=2

" in ruby ? and : can be a part of keyword
set iskeyword+=?
set iskeyword+=!

"================ TABS AND SPACES
set expandtab     " all tabs expands to spaces
set sw=2          " automagic indent width
set tabstop=2     " size of tab in spaces
set ts=2          " size of tab
set shiftround    " round indent to multiple of 'shiftwidth', applies to > and <
set smarttab
set softtabstop=2 " number of spaces that a <Tab> counts for
                  " while performing editing operations

" new splits always bo to the right
" " or below current window
set splitbelow
set splitright

" 1. The current buffer can be put to the background without writing to disk
" 2. When a background buffer becomes current again, marks and
"    undo-history are remembered
set hidden

" show results during typing the search
set incsearch

" search will be case sensitive only when
" capital letter is present
set ignorecase
set smartcase

" maintain context around the cursor
" when scrolling near the edge of screen
set scrolloff=3
set sidescrolloff=5

" disable reading modelines
set nomodeline

" session saving options
set sessionoptions=buffers,winsize,tabpages,winpos,winsize

" ES5 for typescript
au BufEnter,BufNew *.ts set makeprg=tsc\ -t\ ES5\ %

" automatically strip whitespaces
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  let _s=@/
  call cursor(l, c)
  let @/=_s
endfun
autocmd BufWritePre *.* :call <SID>StripTrailingWhitespaces()

" change cursor type in insert mode
if has("autocmd")
  au InsertEnter * silent execute "!echo -ne '\e[6 q'"
  au InsertLeave * silent execute "!echo -ne '\e[1 q'"
  au VimLeave * silent execute "!echo -ne '\e[1 q'"
  "au InsertEnter * silent execute "!gconftool-2 --type string --set /apps/gnome-terminal/profiles/Default/cursor_shape ibeam"
  "au InsertLeave * silent execute "!gconftool-2 --type string --set /apps/gnome-terminal/profiles/Default/cursor_shape block"
  "au VimLeave * silent execute "!gconftool-2 --type string --set /apps/gnome-terminal/profiles/Default/cursor_shape block"
endif

autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow

autocmd BufReadPost Quickfix nmap q :cclose<cr>

noremap <leader>d :Dispatch<cr>

" {{{
" {{{ SESSION AUTOSAVE
" {{{ TODO: rewrite for my usage
fu! SaveSess()
  execute 'mksession! ' . getcwd() . '/.session.vim'
endfunction
fu! RestoreSess()
if filereadable(getcwd() . '/.session.vim')
  execute 'source ' . getcwd() . '/.session.vim'
  "if bufexists(1)
  "  for l in range(1, bufnr('$'))
  "    if bufnr(l) == -1
  "      exec 'sbuffer ' . l
  "    endif
  "  endfor
  "endif
endif
syntax enable
endfunction


function! CursorPing()
    set cursorline cursorcolumn
    redraw
    sleep 50m
    set nocursorline nocursorcolumn
endfunction
" nnoremap <C-Space> :call CursorPing()<CR>


" autocmd VimLeave * call SaveSess()
"autocmd VimEnter * call RestoreSess()
" }}}
" }}} SESSION AUTOSAVE
" }}}





" shorten 'Press ENTER or type command to continue' messages
" TODO: ENABLE THIS AFTER SOME LEARNING
" set shortmess=atI

" remember some stuff after quiting vim:
" marks, registers, searches, buffer list
" TODO: some error happens here
" set viminfo='100,<50,s10,h,%>


" use sane regexes
nnoremap / /\v
vnoremap / /\v
