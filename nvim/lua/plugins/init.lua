return {
  -- tpope
  'tpope/vim-abolish',
  { 'tpope/vim-bundler', ft = "ruby" },
  { 'tpope/vim-capslock', event = "VeryLazy" },
  { 'tpope/vim-classpath', ft = "clojure" },
  { 'tpope/vim-dispatch', event = "VeryLazy" },
  'tpope/vim-dotenv',
  'tpope/vim-endwise',
  'tpope/vim-eunuch',
  { 'tpope/vim-fireplace', ft = "clojure" },
  { 'tpope/vim-fugitive', event = "VeryLazy" },
  'tpope/vim-git',
  'tpope/vim-haml',
  { 'tpope/vim-markdown', ft = "markdown" },
  'tpope/vim-obsession',
  { 'tpope/vim-projectionist', event = "VeryLazy" },
  { 'tpope/vim-rails', event = "VeryLazy" },
  { 'tpope/vim-rake', event = "VeryLazy" },
  'tpope/vim-rhubarb',
  'tpope/vim-sensible',
  'tpope/vim-sexp-mappings-for-regular-people',
  'tpope/vim-sleuth',
  { 'tpope/vim-surround', event = "VeryLazy" },
  'tpope/vim-unimpaired',
  'tpope/vim-vinegar',
  { 'tpope/vim-dadbod', event = "VeryLazy" },

  -- language server stuff and autocompletes

  -- use 'saadparwaiz1/cmp_luasnip'


  -- language specific
  { 'alcesleo/vim-uppercase-sql', ft = "sql" },
  { 'ekalinin/Dockerfile.vim', ft = "dockerfile" },
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
  { 'DataWraith/auto_mkdir', event = "VeryLazy" },
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
