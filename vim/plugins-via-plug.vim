if &compatible
  set nocompatible
endif

call plug#begin('~/.vim/plugged')

Plug  'SirVer/ultisnips'
Plug  'Lokaltog/vim-powerline'

Plug  'Shougo/deoplete.nvim'

if !has('nvim')
  Plug  'roxma/nvim-yarp'
  Plug  'roxma/vim-hug-neovim-rpc'
endif

Plug  'jumski/vim-colors-solarized'
" Plug  'delimitMate.vim'
" Plug  'logstash.vim'
Plug  'godlygeek/tabular'
Plug  'kana/vim-fakeclip'
Plug  'kchmck/vim-coffee-script'

Plug  'Glench/Vim-Jinja2-Syntax'
Plug  'chase/vim-ansible-yaml'



Plug  'vim-scripts/matchit.zip'
Plug  'michaeljsmith/vim-indent-object'
Plug  'vim-scripts/repeat.vim'
Plug  'scrooloose/syntastic'
" Plug  'tomtom/tcomment_vim'
Plug  'tpope/vim-abolish'
Plug  'tpope/vim-endwise'
Plug  'tpope/vim-eunuch'
Plug  'tpope/vim-fugitive'
Plug  'tpope/vim-commentary'
Plug  'tpope/vim-rhubarb'

Plug  'christoomey/vim-tmux-navigator'
Plug  'tpope/vim-git'
Plug  'tpope/vim-haml'
Plug  'tpope/vim-markdown'
Plug  'tpope/vim-rails'
Plug  'tpope/vim-surround'
Plug  'tpope/vim-unimpaired'
Plug  'tpope/vim-bundler'
Plug  'tpope/vim-rake'
Plug  'tpope/vim-sleuth'
Plug  'tpope/vim-dispatch'
Plug  'tpope/vim-capslock'
Plug  'guns/vim-clojure-static'
Plug  'guns/vim-clojure-highlight'
Plug  'tpope/vim-classpath'



Plug  'tpope/vim-fireplace'
" Plug  'tpope/vim-leiningen'
Plug  'tpope/vim-dotenv'

Plug  'tpope/vim-projectionist'
Plug  'vim-ruby/vim-ruby'
Plug  'mattn/gist-vim'
" " Plug  'vim-scripts/ack.vim'
Plug  'rking/ag.vim'
Plug  'vim-scripts/file-line'
Plug  'ecomba/vim-ruby-refactoring'
Plug  'sjl/gundo.vim'
Plug  'tpope/vim-vinegar'
Plug  'tpope/vim-obsession'
Plug  'sickill/vim-pasta'
Plug  'nono/vim-handlebars'
Plug  'jgdavey/vim-blockle'





Plug  'Shougo/vimproc'
Plug  'DataWraith/auto_mkdir'
Plug  'bronson/vim-visual-star-search'
" Plug  'othree/yajs.vim'
" Plug  'jelera/vim-javascript-syntax'
Plug  'sheerun/vim-polyglot'
Plug  'slim-template/vim-slim'
Plug  'mattn/webapi-vim'
Plug  'christoomey/vim-tmux-navigator'
Plug  'mxw/vim-jsx'





Plug  'kana/vim-textobj-user'
Plug  'nelstrom/vim-textobj-rubyblock'
Plug  'abijr/colorpicker'
Plug  'othree/html5.vim'
Plug  'vim-scripts/closetag.vim'
Plug  'junegunn/rainbow_parentheses.vim'
Plug  'ekalinin/Dockerfile.vim'
Plug  'vim-scripts/nginx.vim'

Plug  'lucapette/vim-ruby-doc'
Plug  'danchoi/ri.vim'

Plug  'haya14busa/incsearch.vim'

Plug  'jaxbot/semantic-highlight.vim'

"Plug  'mhinz/vim-sayonara'

Plug  'suan/vim-instant-markdown'
Plug  'guns/vim-sexp'

Plug  'tpope/vim-sexp-mappings-for-regular-people'
Plug  'beloglazov/vim-online-thesaurus'

Plug  'vimwiki/vimwiki'

Plug  'nathanaelkane/vim-indent-guides'
Plug  'tommcdo/vim-exchange'

Plug  'junegunn/goyo.vim'
Plug  'junegunn/limelight.vim'

"Plug  'vim-scripts/zeavim.vim'

call plug#end()

filetype plugin indent on
syntax enable







