return {
  -- enable Avante only if the ANTHROPIC_API_KEY env variable is set
  -- this is because Avante nags with api key dialog if it is not set
  enabled = (vim.fn.getenv("ANTHROPIC_API_KEY") ~= vim.NIL),

  "yetone/avante.nvim",
  lazy = false,
  version = false,
  event = "VeryLazy",
  build = "make", -- This is Optional, only if you want to use tiktoken_core to calculate tokens count
  opts = {
    -- provider = "openai"
    provider = "claude",
    auto_suggestions_provider = "claude",
    cursor_applying_provider = "groq",

    behaviour = {
      --- ... existing behaviours
      enable_cursor_planning_mode = true,
      use_cwd_as_project_root = true,
      enable_claude_text_editor_tool_mode = true,
      enable_token_counting = false,
    },

    disabled_tools = { "git_commit", "delete_file", "delete_dir", "bash", "web_search" },

    providers = {
      claude = {
        -- model = "claude-3-5-sonnet-20241022",
        model = "claude-3-7-sonnet-20250219",
        -- disable_tools = true,
      },
      groq = { -- define groq provider
        __inherited_from = "openai",
        api_key_name = "GROQ_API_KEY",
        endpoint = "https://api.groq.com/openai/v1/",
        model = "qwen-2.5-coder-32b",
        extra_request_body = {
          max_tokens = 8192, -- remember to increase this value, otherwise it will stop generating halfway
        },
      },
      fastapply = {
        __inherited_from = "openai",
        api_key_name = "",
        endpoint = "http://pc.netbird.cloud:11434/v1",
        model = "hf.co/Kortix/FastApply-7B-v1.0_GGUF:Q4_K_M",
      },
    },

    custom_tools = {
      {
        name = "run_tests",
        description = "Run unit and integration tests and return results",
        param = {
          type = "table",
          fields = {
            {
              name = "target",
              description = "Path relative to root of the package (not root of monorepo) for test runner to run",
              type = "string",
              optional = true,
            },
          },
        },
        func = function(params, on_log, on_complete)
          local target = params.target or "./..."
          return vim.fn.system("pnpm nx test -- " .. target)
        end,
      },
      -- {
      --   name = "reset_sql_schema",
      --   description = "Reset SQL schema to include latest changes",
      --   func = function()
      --     return vim.fn.system("pnpm nx supabase:reset")
      --   end,
      --   -- command = "pnpm nx supabase:reset",
      --   param = {
      --     type = "table",
      --     fields = {
      --       {
      --         name = "noop",
      --         description = "noop param, dont use it",
      --         type = "string",
      --         optional = true,
      --       },
      --     },
      --
      --   }
      -- },
    },

    -- ollama = {
    --   ["local"] = true,
    --   -- api_key_name = "",
    --   parse_curl_args = function(opts, code_opts)
    --     return {
    --       url = opts.endpoint .. "/chat/completions",
    --       headers = {
    --         ["Accept"] = "application/json",
    --         ["Content-Type"] = "application/json",
    --         ["x-api-key"] = "ollama",
    --       },
    --       body = {
    --         model = opts.model,
    --         messages = require("avante.providers").copilot.parse_message(code_opts), -- you can make your own message, but this is very advanced
    --         max_tokens = 2048,
    --         stream = true,
    --       },
    --     }
    --   end,
    --   parse_response_data = function(data_stream, event_state, opts)
    --     require("avante.providers").openai.parse_response(data_stream, event_state, opts)
    --   end,
    -- },
    -- add any opts here
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below is optional, make sure to setup it properly if you have lazy=true
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
  },
}
