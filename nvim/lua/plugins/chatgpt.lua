local CONFIG_TYPE = 'ollama' -- or 'openai'

local ollama_config = {
  api_host_cmd = 'echo -n http://jumski-manjaro-pc.local:11434',
  api_key_cmd = 'echo whatever',
  openai_params = {
    model = "dolphin-mixtral",
    frequency_penalty = 0,
    presence_penalty = 0,
    max_tokens = 500,
    temperature = 0,
    top_p = 1,
    n = 1,
  },
  openai_edit_params = {
    model = "dolphin-mixtral",
    frequency_penalty = 0,
    presence_penalty = 0,
    temperature = 0,
    top_p = 1,
    n = 1,
  },
}


return {
  "jackMort/ChatGPT.nvim",
  -- enabled = false,
  event = "VeryLazy",
  config = function(_, opts)
    local home = vim.fn.expand("$HOME")

    local openai_config = {
      api_key_cmd = home .. "/.get_openai_token",
    }

    local config

    if CONFIG_TYPE == 'openai' then
      require("chatgpt").setup(openai_config)
    else
      require("chatgpt").setup(ollama_config)
    end
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim"
  }
}
