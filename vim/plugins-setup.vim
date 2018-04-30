
" vim incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" vim-sexp
let g:sexp_enable_insert_mode_mappings = 0

" vim indent guides
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=black
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=NONE

" GOYO
function! s:goyo_enter()
  silent !tmux set status off
  set noshowmode
  set noshowcmd
  set scrolloff=999
endfunction

function! s:goyo_leave()
  silent !tmux set status on
  set showmode
  set showcmd
  set scrolloff=5
  " Limelight!
  " ...
endfunction
let g:limelight_conceal_ctermfg = 0
" let g:limelight_conceal_ctermfg = 240

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" vim-ruby-doc
let g:ruby_doc_ruby_mapping='<leader>dR'
let g:rspec_doc_ruby_mapping='<leader>ds'
let g:rails_doc_ruby_mapping='<leader>dr'

" vimux
" let VimuxHeight = "50"
" let VimuxOrientation = "h"

" syntastic
let g:syntastic_mode_map = { 'passive_filetypes': ['haml', 'sass', 'slim'] }
let g:syntastic_javascript_checkers = ['jshint', 'jslint']
" let g:syntastic_mode_map = { 'mode': 'passive',
"                            \ 'active_filetypes': ['ruby', 'erb', 'javascript', 'coffee'],
"                            \ 'passive_filetypes': [] }
"
"
" let g:syntastic_disabled_filetypes = ["haml", "sass"]

" YouCompleteMe
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_seed_identifiers_with_syntax = 0
let g:ycm_allow_changing_updatetime = 0
let g:ycm_complete_in_comments_and_strings = 1

" ctrlp
" let g:ctrlp_map = '<leader>z'
" let g:ctrlp_map = '<leader>v'
" let g:ctrlp_cmd = 'CtrlPMRU'
" let g:ctrlp_custom_ignore = {
"   \ 'dir':  '\.git$5\|\.hg$\|\.svn$',
"   \ 'file': '\.exe$\|\.so$\|\.dll$',
"   \ }
" let g:ctrlp_custom_ignore = '\.git$\|\.hg$\|\.svn$'
" \ 'link': 'some_bad_symbolic_links',

" EasyMotion
" let g:EasyMotion_Leader_key = ',,'

" require matchit manually
" runtime macros/matchit.vim

" vim-powerline
let g:Powerline_symbols = 'fancy'


" coffee script
let coffee_compile_vert = 1

" use vim-pasta in coffeescript
" let g:pasta_disabled_filetypes = ["python", "markdown", "coffee", "haml", "sass"]


" """ ULTISNIPS
let g:UltiSnipsEditSplit = "vertical"
let g:UltiSnipsSnippetsDir = "~/dotfiles/ultisnips"
let g:UltiSnipsSnippetDirectories = ["UltiSnips", "../../../dotfiles/ultisnips"]
let g:UltiSnipsExpandTrigger = "<C-z>"

" " g:UltiSnipsListSnippets                <c-tab>
"
" let g:gist_clip_command = 'xclip -selection clipboard'
"
" " check if all is installed
" if neobundle#exists_not_installed_bundles()
"   echomsg 'Not installed bundles : ' .
"         \ string(neobundle#get_not_installed_bundle_names())
"   echomsg 'Please execute ":NeoBundleInstall" command.'
"   "finish
" endif

" rainbow_parentheses.vim
augroup rainbow_lisp
  autocmd!
  autocmd FileType lisp,clojure,scheme RainbowParentheses
augroup END
let g:rainbow#pairs = [['(', ')'], ['[', ']']]
let g:rainbow#max_level = 16
let g:rainbow#blacklist = [12, 14]
" au VimEnter * RainbowParenthesesToggle
" au Syntax * RainbowParenthesesLoadRound
" au Syntax * RainbowParenthesesLoadSquare
" au Syntax * RainbowParenthesesLoadBraces

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
 au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" plugin specific mappings
nnoremap <leader>gu :GundoToggle<CR>

" fugitive shortcuts
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gc :Gcommit<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gs :Gstatus<CR>

" clojure mappings
nnoremap <leader>R :Require<CR>

" Sayonara
nnoremap <leader>q :Sayonara<cr>
nnoremap <leader>Q :Sayonara!<cr>

" Figwheel
command! Figwheel :Piggieback! (do (require 'figwheel-sidecar.repl-api) (figwheel-sidecar.repl-api/cljs-repl))

" vim-dispatch
noremap <leader>d :Dispatch<cr>

" command-t
" noremap <leader>` :CommandT<cr>

nnoremap <leader>vu :UltiSnipsEdit<cr>
nnoremap <leader>vb :NeoBundleInstall<cr>

" Use deoplete.
let g:deoplete#enable_at_startup = 1

" highlight JSX in *.js files
let g:jsx_ext_required = 0
