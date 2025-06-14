return {
  "coder/claudecode.nvim",
  lazy = true,
  cmd = { "ClaudeCodeStart", "ClaudeCodeStop", "ClaudeCodeStatus", "ClaudeCodeSend", "ClaudeCodeAdd", "ClaudeCodeTreeAdd" },
  config = true,
  keys = {
    { "<leader>c", nil, desc = "Claude Code" },
    { "<leader>cc", "<cmd>ClaudeCodeStart<cr>", desc = "Start Claude WebSocket" },
    { "<leader>cr", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude status" },
    { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    {
      "<leader>cs",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree" },
    },
    { "<leader>cx", "<cmd>ClaudeCodeStop<cr>", desc = "Stop WebSocket server" },
  },
  opts = {
    -- Server options
    port_range = { min = 10000, max = 65535 },
    auto_start = false,  -- Don't auto-start, we'll start manually with :ClaudeCodeStart
    log_level = "info",

    -- Diff options
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
    },
  },
}