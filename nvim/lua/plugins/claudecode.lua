return {
  "coder/claudecode.nvim",
  config = true,
  keys = {
    { "<leader>c", nil, desc = "Claude Code" },
    { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Start Claude WebSocket" },
    { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    {
      "<leader>cs",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree" },
    },
    { "<leader>co", "<cmd>ClaudeCodeOpen<cr>", desc = "Open Claude terminal" },
    { "<leader>cx", "<cmd>ClaudeCodeClose<cr>", desc = "Close Claude connection" },
  },
  opts = {
    -- Server options
    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = "info",

    -- Terminal options (we use external tmux, not plugin's terminal)
    terminal = {
      split_side = "right",
      split_width_percentage = 0.3,
      provider = "native",
      auto_close = false,  -- Keep connection open for hybrid workflow
    },

    -- Diff options
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
    },
  },
}