
" reformat whole file
noremap <leader>G mggg=G'g

" disable Ex mode, use its mapping for repeating a macro
nmap Q @@

" open file under curson in vsplit
" nmap <C-X>gf :vs %<CR>gf

noremap  <Up> ""
noremap! <Up> <Esc>
noremap  <Down> ""
noremap! <Down> <Esc>
noremap  <Left> ""
noremap! <Left> <Esc>
noremap  <Right> ""
noremap! <Right> <Esc>

" scroll viewport faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" easy access/surce vimrc and other
nnoremap <leader>vs :source ~/.vimrc<CR>
nnoremap <leader>vv :tabnew ~/.dotfiles/vim/plugins.vim<cr>:vs ~/.dotfiles/vim/settings.vim<cr>:sp ~/.dotfiles/vim/mappings.vim<cr><C-w>h:sp ~/.dotfiles/vim/projections.vim<cr>

" some custom stuff
nnoremap <leader>op :15sp /home/jumski/Dropbox/projects/`basename \`pwd\``/todos.txt<cr>

cmap w!! w !sudo tee >/dev/null %
cmap wqq wq

" Convert to Ruby 1.9 hash syntax
noremap <leader>9 :s/:\(\S\+\)\s\+=>\s\+/\1: /g<cr>

" goto next/previous Ack result
nnoremap <leader>n :cnext<CR>
nnoremap <leader>N :cprevious<CR>

" select last changed/pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Rg search
nnoremap <LocalLeader>\ :tabnew<CR>:Rg<space>
" Rg search for word under cursor
nnoremap <leader>\ "xyiw:tabnew<CR>:Rg <C-R>x<space>
vnoremap <LocalLeader>\ "xy:tabnew<CR>:Rg "<C-R>x"<space>

" FZF search
nnoremap <LocalLeader>s :tabnew<CR>:FZF<CR>

" keep search matches in the middle of the window
nnoremap n nzzzv
nnoremap N Nzzzv

" same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz

nnoremap U :syntax sync fromstart<enter>:redraw!<enter>
