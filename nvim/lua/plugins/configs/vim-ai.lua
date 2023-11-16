syntax_highlighting_prompt = [[
If you attach a code block add syntax type after ``` to enable syntax highlighting.
]]

initial_chat_prompt = [[
>>> system
You are a concise helpful assistant and expert programmer.
]] .. syntax_highlighting_prompt

vim.g.vim_ai_chat = {
  options = {
    -- model = "gpt-3.5-turbo",
    -- model = "gpt-4",
    model = "gpt-4-1106-preview",
    temperature = 0.7,
    initial_prompt = initial_chat_prompt
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
      initial_prompt = ">>> system\nyou are a code assistant.",
      temperature = 1,
    },
  }
  vim.call('vim_ai#AIRun', range, config, prompt)
end
vim.cmd('command! -nargs=0 GitCommitMessage lua git_commit_message_fn()')

vim.cmd([[
function! CodeReviewFn(range) range
  let l:prompt = "programming syntax is " . &filetype . ", review the code below"
  let l:config = {
  \  "options": {
  \    "initial_prompt": ">>> system\nyou are a clean code expert",
  \  },
  \}
  '<,'>call vim_ai#AIChatRun(a:range, l:config, l:prompt)
endfunction
command! -range CodeReview <line1>,<line2>call CodeReviewFn(<range>)
]])
