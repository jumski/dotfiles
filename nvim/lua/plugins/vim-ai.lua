return {
  'madox2/vim-ai',
  enabled = false,
  config = function()
    local syntax_highlighting_prompt = [[
    If you attach a code block add syntax type after ``` to enable syntax highlighting.
    ]]

    local initial_chat_prompt = [[
    >>> system
    You are a concise helpful assistant and expert programmer.
    ]] .. syntax_highlighting_prompt

    vim.g.vim_ai_chat = {
      options = {
        -- model = "gpt-3.5-turbo",
        -- model = "gpt-4",
        -- model = "gpt-4-1106-preview",
        -- model = 'codellama:34b',
        model = 'dolphin-mixtral',
        endpoint_url = "http://jumski-manjaro-pc.local:11434/v1/chat/completions",
        temperature = 0.7,
        initial_prompt = initial_chat_prompt
      }
    }

    local vim = vim

    function Git_commit_message_fn()
      local diff = vim.fn.system('git --no-pager diff --staged')
      local prompt = "generate a short commit message from the diff below:\n" .. diff
      local range = 0
      local config = {
        engine = "chat",
        options = {
          model = "gpt-4-1106-preview",
          initial_prompt = ">>> system\nyou are a code assistant.",
          temperature = 1,
        },
      }
      vim.call('vim_ai#AIRun', range, config, prompt)
    end
    vim.cmd('command! -nargs=0 GitCommitMessage lua Git_commit_message_fn()')

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

    -- vim-ai mappings
    local vim_ai_opts = {noremap = true}
    local map = vim.api.nvim_set_keymap

    -- :AIChat
    -- map('n', '<leader>d', ':AIChat<CR>', vim_ai_opts)
    -- map('x', '<leader>d', ':AIChat ', vim_ai_opts)

    -- :AIEdit
    -- map('n', '<leader>e', ':AIEdit ', vim_ai_opts)
    -- map('x', '<leader>e', ':AIEdit ', vim_ai_opts)

    -- :GitCommitMessage
    -- map('n', '<leader>g', ':GitCommitMessage<CR>', vim_ai_opts)

  end
}
