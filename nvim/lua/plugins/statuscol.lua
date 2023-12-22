return {
  "luukvbaal/statuscol.nvim",
  enabled = false,
  config = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      setopt = true,
      relculright = true,
      segments = {
        { text = { "%C" }, click = "v:lua.ScFa" },
        { text = { "%s" }, click = "v:lua.ScSa" },
        {
          text = { builtin.lnumfunc, " " },
          condition = { true, builtin.not_empty },
          click = "v:lua.ScLa",
        }
      },
      -- segments = {
      --   { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
      --   {
      --     sign = { name = { "Diagnostic" }, maxwidth = 2, auto = true },
      --     click = "v:lua.ScSa"
      --   },
      --   { text = { builtin.lnumfunc }, click = "v:lua.ScLa", },
      --   {
      --     sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
      --     click = "v:lua.ScSa"
      --   },
      -- }
    })
  end,
}
