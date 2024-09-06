return {
  "frankroeder/parrot.nvim",
  dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim', 'rcarriga/nvim-notify' },
  -- dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim' },
  config = function()
    local env_file = vim.fn.expand('~/.env.local')
    local env = require('core.helpers').parse_env_file(env_file)

    require("parrot").setup {
      -- Providers must be explicitly added to make them available.
      providers = {
        anthropic = {
          api_key = env['ANTHROPIC_API_KEY']
          -- api_key = os.getenv "ANTHROPIC_API_KEY",
        },
        -- gemini = {
        --   api_key = os.getenv "GEMINI_API_KEY",
        -- },
        groq = {
          api_key = env['GROQ_API_KEY']
          -- api_key = os.getenv "GROQ_API_KEY",
        },
        -- mistral = {
        --   api_key = os.getenv "MISTRAL_API_KEY",
        -- },
        -- pplx = {
        --   api_key = os.getenv "PERPLEXITY_API_KEY",
        -- },
        -- provide an empty list to make provider available (no API key required)
        -- ollama = {},
        openai = {
          api_key = env['OPENAI_API_KEY']
          -- api_key = os.getenv "OPENAI_API_KEY",
        },
        -- github = {
        --   api_key = os.getenv "GITHUB_TOKEN",
        -- },
      },
    }
  end,
}

