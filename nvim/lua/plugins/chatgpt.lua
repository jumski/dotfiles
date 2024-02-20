return {
  "jackMort/ChatGPT.nvim",
  enabled = false,
  event = "VeryLazy",
  config = function(_, opts)
    local home = vim.fn.expand("$HOME")

    require("chatgpt").setup({
      api_key_cmd = home .. "/.dotfiles/bin/get_openai_token",
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim"
  }
}
