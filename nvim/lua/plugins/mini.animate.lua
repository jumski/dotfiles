return {
  "echasnovski/mini.animate",
  version = "*",
  opts = {},
  config = function()
    require("mini.animate").setup()

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "Avante", "AvanteInput" },
      callback = function()
        vim.b.minianimate_disable = true     -- For mini.animate
        vim.b.miniindentscope_disable = true -- For mini.indentscope
      end,
    })
  end,
}
