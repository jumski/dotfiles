return {
  -- tpope
  'tpope/vim-abolish',
  'tpope/vim-bundler',
  'tpope/vim-capslock',
  'tpope/vim-classpath',
  'tpope/vim-dispatch',
  'tpope/vim-dotenv',
  'tpope/vim-endwise',
  'tpope/vim-eunuch',
  'tpope/vim-fireplace',
  'tpope/vim-fugitive',
  'tpope/vim-git',
  'tpope/vim-haml',
  'tpope/vim-markdown',
  'tpope/vim-obsession',
  'tpope/vim-projectionist',
  'tpope/vim-rails',
  'tpope/vim-rake',
  'tpope/vim-rhubarb',
  'tpope/vim-sensible',
  'tpope/vim-sexp-mappings-for-regular-people',
  'tpope/vim-sleuth',
  'tpope/vim-surround',
  'tpope/vim-unimpaired',
  'tpope/vim-vinegar',

  -- language server stuff and autocompletes

  -- use 'saadparwaiz1/cmp_luasnip'


  -- language specific
  'alcesleo/vim-uppercase-sql',
  'ekalinin/Dockerfile.vim',
  -- use {
  --   'salkin-mada/openscad.nvim',
  --   config = function ()
  --     require('openscad')
  --     -- load snippets, note dependencies
  --     vim.g.openscad_load_snippets = true
  --   end,
  --   dependencies = 'L3MON4D3/LuaSnip'
  -- }
  -- use 'nelstrom/vim-textobj-rubyblock' -- toggle block type in ruby

  -- snippets TODO
  ------use({"L3MON4D3/LuaSnip", tag = "v<CurrentMajor>.*"})

  -- useful stuff
  'DataWraith/auto_mkdir',
  'christoomey/vim-tmux-navigator',
  'duane9/nvim-rg',
  'godlygeek/tabular',
  'haya14busa/incsearch.vim',
  'michaeljsmith/vim-indent-object',
  'nathanaelkane/vim-indent-guides',
  'vim-scripts/repeat.vim',
  'vim-scripts/closetag.vim',
  'vim-scripts/file-line',
  'vim-scripts/matchit.zip',
  'gpanders/editorconfig.nvim',

  {
    'ldelossa/gh.nvim',
    dependencies = { { 'ldelossa/litee.nvim' } }
  },

  -- styles/visuals
  -- use "clinstid/eink.vim"
  "junegunn/limelight.vim",

  -- integration from other clients
  -- use {
  --   'glacambre/firenvim',
  --   run = function() vim.fn['firenvim#install'](0) end
  -- }

  --require 'plugins.configs.luasnip'
  --require 'plugins.configs.lspcontainers'
  --require 'plugins.configs.nvim-cmp'
  --require 'plugins.configs.vim-commentary'
  --require 'plugins.configs.vim-ai'
  --require 'plugins.configs.codi'
}
