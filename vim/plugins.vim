if &compatible
  set nocompatible
endif

call plug#begin('~/.vim/plugged')

Plug 'alcesleo/vim-uppercase-sql'
Plug 'chrisbra/Colorizer' " colorizes hex color codes
Plug 'DataWraith/auto_mkdir'
Plug 'KabbAmine/vCoolor.vim' " color-picker
Plug 'Lokaltog/vim-powerline'
Plug 'SirVer/ultisnips'
Plug 'autozimu/LanguageClient-neovim', {
  \ 'branch': 'next',
  \ 'do': 'bash install.sh',
  \ }
Plug 'christoomey/vim-tmux-navigator'
Plug 'dense-analysis/ale'
Plug 'ecomba/vim-ruby-refactoring'
Plug 'editorconfig/editorconfig-vim'
Plug 'ekalinin/Dockerfile.vim'
Plug 'godlygeek/tabular'
Plug 'guns/vim-clojure-highlight'
Plug 'guns/vim-clojure-static'
Plug 'guns/vim-sexp'
Plug 'haya14busa/incsearch.vim'
Plug 'itchyny/lightline.vim'
Plug 'jaxbot/semantic-highlight.vim'
Plug 'jgdavey/vim-blockle'
Plug 'joukevandermaas/vim-ember-hbs'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'kana/vim-fakeclip' " paste-clipboard support for tmux
Plug 'kana/vim-textobj-user' " vim-textobj-rubyblock dependency
Plug 'mattn/gist-vim'
Plug 'mattn/webapi-vim' " dependency of gist-vim
Plug 'michaeljsmith/vim-indent-object'
Plug 'morhetz/gruvbox' " colortheme
Plug 'mxw/vim-jsx'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'nelstrom/vim-textobj-rubyblock' " toggle block type in ruby
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nono/vim-handlebars'
Plug 'nullvoxpopuli/coc-ember', {'do': 'yarn install --frozen-lockfile'}
Plug 'othree/html5.vim'
Plug 'rking/ag.vim'
Plug 'sheerun/vim-polyglot' " all the language packs in one repo
Plug 'sickill/vim-pasta'
Plug 'suan/vim-instant-markdown'
Plug 'suy/vim-context-commentstring' " needed for vim-commentary to work in *.vue
Plug 'thoughtbot/vim-rspec'
Plug 'tommcdo/vim-exchange' " exchange two words with 'cxiw' on each one
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-capslock'
Plug 'tpope/vim-classpath'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-dotenv'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'tpope/vim-haml'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rake'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'
Plug 'vim-ruby/vim-ruby'
Plug 'vim-scripts/closetag.vim'
Plug 'vim-scripts/file-line'
Plug 'vim-scripts/matchit.zip'
Plug 'vim-scripts/nginx.vim'
Plug 'vim-scripts/repeat.vim'

if !has('nvim')
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" DISABLED PLUGINS:
" Plug 'abijr/colorpicker'
" Plug 'chase/vim-ansible-yaml'
" Plug 'danchoi/ri.vim'
" Plug 'delimitMate.vim'
" Plug 'ervandew/supertab'
" Plug 'jelera/vim-javascript-syntax'
" Plug 'jumski/vim-colors-solarized'
" Plug 'junegunn/fzf.vim'
" Plug 'junegunn/goyo.vim' " distraction-free writing in vim
" Plug 'junegunn/limelight.vim' " dim all other paragrapsh and focus on current
" Plug 'logstash.vim'
" Plug 'mhinz/vim-sayonara'
" Plug 'othree/yajs.vim'
" Plug 'sjl/gundo.vim'
" Plug 'tomtom/tcomment_vim'
" Plug 'tpope/vim-leiningen'
" Plug 'vim-scripts/ack.vim'
" Plug 'vim-scripts/zeavim.vim'
" Plug 'vimwiki/vimwiki'
" Plug '~/.fzf'

call plug#end()

filetype plugin indent on
syntax enable
