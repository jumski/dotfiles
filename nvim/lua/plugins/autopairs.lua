return {
    'windwp/nvim-autopairs',
    -- enabled = false,
    event = "InsertEnter",
    opts = { }, -- this is equalent to setup({}) function
    config = function(_, opts)
      local npairs = require('nvim-autopairs')
      npairs.setup(opts)
      npairs.remove_rule("`")
    end
}
