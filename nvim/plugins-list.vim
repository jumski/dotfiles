Plug 'yasuhiroki/circleci.vim'

Plug 'AaronLasseigne/yank-code'
Plug 'chrisbra/Colorizer' " colorizes hex color codes
Plug 'KabbAmine/vCoolor.vim' " color-picker
Plug 'Lokaltog/vim-powerline'
Plug 'SirVer/ultisnips'
" Plug 'autozimu/LanguageClient-neovim', {
"   \ 'branch': 'next',
"   \ 'do': 'bash install.sh',
"   \ }
Plug 'delphinus/vim-firestore'
Plug 'dense-analysis/ale'
Plug 'ecomba/vim-ruby-refactoring'
Plug 'guns/vim-clojure-highlight'
Plug 'guns/vim-clojure-static'
Plug 'guns/vim-sexp'
Plug 'itchyny/lightline.vim'
Plug 'jaxbot/semantic-highlight.vim'
Plug 'jgdavey/vim-blockle'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'kana/vim-fakeclip' " paste-clipboard support for tmux
Plug 'kana/vim-textobj-user' " vim-textobj-rubyblock dependency
Plug 'mattn/gist-vim'
Plug 'mattn/webapi-vim' " dependency of gist-vim
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nono/vim-handlebars'
Plug 'othree/html5.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'sheerun/vim-polyglot' " all the language packs in one repo
Plug 'sickill/vim-pasta'
Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
Plug 'suy/vim-context-commentstring' " needed for vim-commentary to work in *.vue
Plug 'thoughtbot/vim-rspec'
Plug 'tommcdo/vim-exchange' " exchange two words with 'cxiw' on each one
Plug 'vim-ruby/vim-ruby'
Plug 'vim-scripts/nginx.vim'

Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

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
