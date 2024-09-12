return {
  -- enable Avante only if the ANTHROPIC_API_KEY env variable is set
  -- this is because Avante nags with api key dialog if it is not set
  enabled = (vim.fn.getenv("ANTHROPIC_API_KEY") ~= vim.NIL);

  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make", -- This is Optional, only if you want to use tiktoken_core to calculate tokens count
  opts = {
    -- provider = "openai"
    provider = "claude"
    -- add any opts here
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below is optional, make sure to setup it properly if you have lazy=true
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
