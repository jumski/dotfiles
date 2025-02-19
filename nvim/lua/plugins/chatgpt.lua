local CHAT_API = "openai"
-- 'groq';
-- 'ollama';

local OPENAI_MODEL = "gpt-4o"
-- 'gpt-4-1106-preview';
-- 'gpt-4';
-- 'gpt-3.5-turbo';

local GROQ_MODEL = "mixtral-8x7b-32768"
-- "llama2-70b-4096";
-- "gemma-7b-it";
-- "gemma-2b-it";

local OLLAMA_MODEL =
  -- 'dolphincoder:15b-starcoder2-q8_0';
  -- 'deepseek-coder:6.7b-instruct-q8_0';
  -- 'codellama:7b',
  -- 'codellama:13b',
  -- 'codellama:34b';
  "dolphin-mixtral:8x7b-v2.7-q3_K_L"
-- 'dolphin-mixtral:8x7b-v2.7-q2_K';
--
-- DOES NOT FIT IN RAM:
-- 'codellama:70b';
-- 'deepseek-coder:33b-instruct-q5_K_M';
-- 'dolphin-mixtral';

local WHICH_KEY_MAPPINGS = {
  { "<leader>c", group = "ChatGPT" },
  { "<leader>cc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
  {
    mode = { "n", "v" },
    { "<leader>ca", "<cmd>ChatGPTRun add_tests<CR>", desc = "Add Tests" },
    { "<leader>cd", "<cmd>ChatGPTRun docstring<CR>", desc = "Docstring" },
    { "<leader>ce", "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" },
    { "<leader>cf", "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs" },
    { "<leader>cg", "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" },
    { "<leader>ck", "<cmd>ChatGPTRun keywords<CR>", desc = "Keywords" },
    { "<leader>cl", "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
    { "<leader>co", "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize Code" },
    { "<leader>cr", "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" },
    { "<leader>cs", "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize" },
    { "<leader>ct", "<cmd>ChatGPTRun translate<CR>", desc = "Translate" },
    { "<leader>cx", "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code" },
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
  api_host_cmd = "echo -n http://pc.netbird.cloud:11434",
  api_key_cmd = "echo whatever",
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
  api_host_cmd = "echo -n https://api.groq.com/openai",
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
  enabled = false,
  event = "VeryLazy",
  config = function()
    local config
    if CHAT_API == "openai" then
      config = openai_config
    elseif CHAT_API == "groq" then
      config = groq_config
    else
      config = ollama_config
    end

    config.keymap = UI_MAPPINGS
    config.actions_paths = {
      HOME_PATH .. "/.dotfiles/nvim/lua/plugins/chatgpt-actions.json",
    }

    require("chatgpt").setup(config)
    require("which-key").add(WHICH_KEY_MAPPINGS)
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
}
