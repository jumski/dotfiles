return {
  "echasnovski/mini.animate",
  -- enabled = false,
  version = "*",
  opts = {},
  config = function()
    require("mini.animate").setup({
      cursor = {
        timing = function() return 9 end, -- Default is 110
      },
      scroll = {
        timing = function() return 5 end, -- Default is 110
      },
      resize = {
        timing = function() return 11 end, -- Default is 110
      },
      open = {
        timing = function() return 11 end, -- Default is 110
      },
      close = {
        timing = function() return 11 end, -- Default is 110
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "Avante", "AvanteInput" },
      callback = function()
        vim.b.minianimate_disable = true     -- For mini.animate
        vim.b.miniindentscope_disable = true -- For mini.indentscope
      end,
    })
  end,
}
