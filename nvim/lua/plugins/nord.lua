 return {
   'shaunsingh/nord.nvim',
   enabled = false,
   lazy = false,
   priority = 1000,
   opts = {},
   config = function()
     vim.cmd[[colorscheme nord]]
   end
 }
