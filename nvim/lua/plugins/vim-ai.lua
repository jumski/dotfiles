-- This prompt instructs model to work with syntax highlighting
initial_chat_prompt = [[
>>> system

You are a general assistant.
If you attach a code block add syntax type after ``` to enable syntax highlighting.
]]

vim.g.vim_ai_chat = {
  options = {
    model = "gpt-3.5-turbo",
    -- model = "gpt-4",
    temperature = 0.7,
  }
}

local vim = vim
local api = vim.api

function git_commit_message_fn()
  local diff = vim.fn.system('git --no-pager diff --staged')
  local prompt = "generate a short commit message from the diff below:\n" .. diff
  local range = 0
  local config = {
    engine = "chat",
    options = {
      model = "gpt-3.5-turbo",
      initial_prompt = ">>> system\nyou are a code assistant",
      temperature = 1,
    },
  }
  vim.call('vim_ai#AIRun', range, config, prompt)
end

print("Hello World!")


-- vim.cmd("command! XdKek lua Gcx()")
vim.cmd('command! -nargs=0 GitCommitMessage lua git_commit_message_fn()')
-- api.nvim_command('command! -nargs=0 GitCommitMessage lua git_commit_message_fn()')

-- vim.g.vim_ai_chat = {
--   options = {
--     model = "gpt-3.5-turbo",
--     max_tokens = 1000,
--     temperature = 1,
--     request_timeout = 20,
--     selection_boundary = "",
--     initial_prompt = s.initial_chat_prompt,
--   },
--   ui = {
--     code_syntax_enabled = 1,
--     populate_options = 0,
--     open_chat_command = "preset_below",
--     scratch_buffer_keep_open = 0,
--   },
-- }
