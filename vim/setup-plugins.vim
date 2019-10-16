
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

" TODO: RSpec.vim mappings with vim-dispatch integration
" map <Leader>t :call RunCurrentSpecFile()<CR>
" map <Leader>s :call RunNearestSpec()<CR>
" map <Leader>l :call RunLastSpec()<CR>
" map <Leader>a :call RunAllSpecs()<CR>
" let g:rspec_command = "compiler rspec | set makeprg=bin/rspec | Make rspec {spec}"

" require matchit manually
" runtime macros/matchit.vim

" vim-powerline
let g:Powerline_symbols = 'fancy'

" """ ULTISNIPS
let g:UltiSnipsEditSplit = "vertical"
let g:UltiSnipsSnippetsDir = "~/.dotfiles/ultisnips"
let g:UltiSnipsSnippetDirectories = ["UltiSnips", "../../../.dotfiles/ultisnips"]
let g:UltiSnipsExpandTrigger = "<C-z>"

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

" Figwheel
" command! Figwheel :Piggieback! (do (require 'figwheel-sidecar.repl-api) (figwheel-sidecar.repl-api/cljs-repl))

" vim-dispatch
noremap <leader>d :Dispatch<cr>

nnoremap <leader>vu :UltiSnipsEdit<cr>
nnoremap <leader>vb :NeoBundleInstall<cr>

" Use deoplete.
let g:deoplete#enable_at_startup = 1

" highlight JSX in *.js files
let g:jsx_ext_required = 0

let g:gist_clip_command = 'xclip -selection clipboard'

" ALE
" do not link when inserting stuff in insert mode
let g:ale_lint_on_text_changed = 'normal'

" solargraph and language client
let g:LanguageClient_serverCommands = {
    \ 'ruby': ['tcp://localhost:7658']
    \ }
let g:LanguageClient_autoStop = 0
autocmd FileType ruby setlocal omnifunc=LanguageClient#complete

let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ]
      \ },
      \ 'component': {
      \   'charvaluehex': '0x%B'
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }
