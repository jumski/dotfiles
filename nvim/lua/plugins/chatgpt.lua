local CHAT_API =
  -- 'openai';
  -- 'groq';
  'ollama';

local OPENAI_MODEL =
  'gpt-4-1106-preview';
  -- 'gpt-4';
  -- 'gpt-3.5-turbo';

local GROQ_MODEL =
  "mixtral-8x7b-32768";
  -- "llama2-70b-4096";
  -- "gemma-7b-it";
  -- "gemma-2b-it";

local OLLAMA_MODEL =
  -- 'dolphincoder:15b-starcoder2-q8_0';
  -- 'deepseek-coder:6.7b-instruct-q8_0';
  -- 'deepseek-coder:33b-instruct-q5_K_M';
  -- 'codellama:34b';
  'dolphin-mixtral';

local WHICH_KEY_MAPPINGS = {
  c = {
    name = "ChatGPT",
    c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
    e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
    g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
    t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
    k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
    d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
    a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
    o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
    s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
    f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
    x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
    r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
    l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
  },
}

local UI_MAPPINGS = {
  close = "<C-c>",
  yank_last = "<C-y>",
  yank_last_code = "<C-k>",
  scroll_up = "<C-u>",
  scroll_down = "<C-d>",
  new_session = "<C-n>",
  cycle_windows = "<Tab>",
  cycle_modes = "<C-f>",
  next_message = "<C-j>",
  prev_message = "<C-k>",
  select_session = "<Space>",
  rename_session = "r",
  delete_session = "d",
  draft_message = "<C-r>",
  edit_message = "e",
  delete_message = "d",
  toggle_settings = "<C-o>",
  toggle_sessions = "<C-p>",
  toggle_help = "<C-/>",
  toggle_message_role = "<C-r>",
  toggle_system_role_open = "<C-s>",
  stop_generating = "<C-x>",
}

local HOME_PATH = vim.fn.expand("$HOME")

local openai_config = {
  api_key_cmd = HOME_PATH .. "/.get_openai_token",
  openai_params = {
    model = OPENAI_MODEL,
    frequency_penalty = 0,
    presence_penalty = 0,
    max_tokens = 2000,
    temperature = 0,
    top_p = 1,
    n = 1,
  },
}

local ollama_config = {
  api_host_cmd = 'echo -n http://pc.netbird.cloud:11434',
  api_key_cmd = 'echo whatever',
  openai_params = {
    model = OLLAMA_MODEL,
    frequency_penalty = 0,
    presence_penalty = 0,
    max_tokens = 2000,
    temperature = 0,
    top_p = 1,
    n = 1,
  },
  openai_edit_params = {
    model = OLLAMA_MODEL,
    frequency_penalty = 0,
    presence_penalty = 0,
    temperature = 0,
    top_p = 1,
    n = 1,
  },
}

local groq_config = {
  api_host_cmd = 'echo -n https://api.groq.com/openai',
  api_key_cmd = HOME_PATH .. "/.get_groq_token",
  openai_params = {
    model = GROQ_MODEL,
    frequency_penalty = 0,
    presence_penalty = 0,
    max_tokens = 2000,
    temperature = 0,
    top_p = 1,
    n = 1,
  },
  openai_edit_params = {
    model = GROQ_MODEL,
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
  config = function()
    local config
    if CHAT_API == 'openai' then
      config = openai_config
    elseif CHAT_API == 'groq' then
      config = groq_config
    else
      config = ollama_config
    end

    config.keymap = UI_MAPPINGS
    config.actions_paths = {
      HOME_PATH .. "/.dotfiles/nvim/lua/plugins/chatgpt-actions.json",
    }

    require("chatgpt").setup(config)
    require("which-key").register(WHICH_KEY_MAPPINGS, { prefix = "<leader>", })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim"
  }
}
