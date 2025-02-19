local WHICH_KEY_MAPPINGS = {
  { "<leader>c", group = "CodeCompanion" },
  { "<leader>cc", "<cmd>CodeCompanionChat<CR>", desc = "Chat" },
  { "<leader>ca", "<cmd>CodeCompanionActions<CR>", desc = "Actions" },
}

return {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      chat = {
        adapter = "anthropic",
      },
      inline = {
        adapter = "anthropic",
      },
    },
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = "cmd:grep -o 'ANTHROPIC_API_KEY=.*' ~/.env.local | cut -d'=' -f2",
          },
        })
      end,
      deepseek = function()
        return require("codecompanion.adapters").extend("deepseek", {
          env = {
            api_key = "cmd:grep -o 'DEEPSEEK_API_KEY=.*' ~/.env.local | cut -d'=' -f2",
          },
        })
      end,
      openai = function()
        return require("codecompanion.adapters").extend("openai", {
          env = {
            api_key = "cmd:grep -o 'OPENAI_API_KEY=.*' ~/.env.local | cut -d'=' -f2",
          },
        })
      end,
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = "http://pc.netbird.cloud:11434",
            api_key = "yolo",
          },
          headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer ${api_key}",
          },
          parameters = {
            sync = true,
          },
        })
      end,
    },
  },

  config = function(_, opts)
    require("codecompanion").setup(opts)
    require("which-key").add(WHICH_KEY_MAPPINGS)
  end,

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
