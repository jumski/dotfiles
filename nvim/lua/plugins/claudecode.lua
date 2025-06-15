return {
  "coder/claudecode.nvim",
  lazy = true,
  cmd = { "ClaudeCodeStart", "ClaudeCodeStop", "ClaudeCodeStatus", "ClaudeCodeSend", "ClaudeCodeAdd", "ClaudeCodeTreeAdd" },
  config = function()
    -- Load the plugin with default config
    require("claudecode").setup({
      auto_start = false,
      port_range = { min = 10000, max = 65535 },
      log_level = "info",
      diff_opts = {
        auto_close_on_accept = true,
        vertical_split = true,
      },
    })
    
    -- Override the ClaudeCodeSend command to not open terminal
    vim.api.nvim_create_user_command("ClaudeCodeSend", function(opts)
      local selection = require("claudecode.selection")
      if opts.range and opts.range > 0 then
        selection.send_at_mention_for_visual_selection(opts.line1, opts.line2)
      else
        selection.send_at_mention_for_visual_selection()
      end
      -- Do NOT open terminal - we're using tmux!
    end, { desc = "Send selection to Claude (no terminal)", range = true })
  end,
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