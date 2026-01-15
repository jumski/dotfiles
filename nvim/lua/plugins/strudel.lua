return {
  "gruvw/strudel.nvim",
  build = "npm ci",
  opts = {
    update_on_save = true,
  },
  config = function()
    require("strudel").setup()
  end,
}
