local cmd = vim.cmd
local packer = require 'packer'

cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'nvim-treesitter/nvim-treesitter'

  -- tpope
  use 'tpope/vim-abolish'
  use 'tpope/vim-bundler'
  use 'tpope/vim-capslock'
  use 'tpope/vim-classpath'
  use 'tpope/vim-commentary'
  use 'tpope/vim-dispatch'
  use 'tpope/vim-dotenv'
  use 'tpope/vim-endwise'
  use 'tpope/vim-eunuch'
  use 'tpope/vim-fireplace'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-git'
  use 'tpope/vim-haml'
  use 'tpope/vim-markdown'
  use 'tpope/vim-obsession'
  use 'tpope/vim-projectionist'
  use 'tpope/vim-rails'
  use 'tpope/vim-rake'
  use 'tpope/vim-rhubarb'
  use 'tpope/vim-sensible'
  use 'tpope/vim-sexp-mappings-for-regular-people'
  use 'tpope/vim-sleuth'
  use 'tpope/vim-surround'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-vinegar'
  use 'tpope/vim-dadbod'

  -- language server stuff and autocompletes
  use 'neovim/nvim-lspconfig'
  use 'lspcontainers/lspcontainers.nvim'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'madox2/vim-ai'
  use 'metakirby5/codi.vim'

  use {
    'Exafunction/codeium.vim',
    -- config = function ()
    --   -- Change '<C-g>' here to any keycode you like.
    --   vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true })
    --   vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
    --   vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
    --   vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true })
    -- end
  }
  cmd [[ highlight CodeiumSuggestion guifg=#02a7a9 ctermfg=8 ]]

  -- use 'github/copilot.vim'
  -- cmd [[ highlight CopilotSuggestion guifg=#02a7a9 ctermfg=8 ]]

  -- use { 'codota/tabnine-nvim', run = "./dl_binaries.sh" }
  -- use 'L3MON4D3/LuaSnip'
  -- use 'saadparwaiz1/cmp_luasnip'


  -- language specific
  use 'alcesleo/vim-uppercase-sql'
  use 'ekalinin/Dockerfile.vim'
  -- use {
  --   'salkin-mada/openscad.nvim',
  --   config = function ()
  --     require('openscad')
  --     -- load snippets, note requires
  --     vim.g.openscad_load_snippets = true
  --   end,
  --   requires = 'L3MON4D3/LuaSnip'
  -- }
  -- use 'nelstrom/vim-textobj-rubyblock' -- toggle block type in ruby

  -- snippets
  use({"L3MON4D3/LuaSnip", tag = "v<CurrentMajor>.*"})

  -- useful stuff
  use 'DataWraith/auto_mkdir'
  use 'christoomey/vim-tmux-navigator'
  use 'duane9/nvim-rg'
  use 'godlygeek/tabular'
  use 'haya14busa/incsearch.vim'
  use 'michaeljsmith/vim-indent-object'
  use 'nathanaelkane/vim-indent-guides'
  use 'vim-scripts/repeat.vim'
  use 'vim-scripts/closetag.vim'
  use 'vim-scripts/file-line'
  use 'vim-scripts/matchit.zip'
  use 'gpanders/editorconfig.nvim'

  use {
    'ldelossa/gh.nvim',
    requires = { { 'ldelossa/litee.nvim' } }
  }

  -- styles/visuals
  -- use "clinstid/eink.vim"
  use {"ellisonleao/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}
  use "junegunn/limelight.vim"
  -- use {
  --   'nvim-lualine/lualine.nvim',
  --   requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  -- }

  -- integration from other clients
  -- use {
  --   'glacambre/firenvim',
  --   run = function() vim.fn['firenvim#install'](0) end
  -- }

  require 'plugins.configs.luasnip'
  require 'plugins.configs.lspcontainers'
  require 'plugins.configs.nvim-cmp'
  require 'plugins.configs.vim-commentary'
  require 'plugins.configs.vim-ai'
  require 'plugins.configs.codi'
end)