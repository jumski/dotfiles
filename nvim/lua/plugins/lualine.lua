      -- tabline = {},
return {
  'nvim-lualine/lualine.nvim',
  enabled = true,
  dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
  config = function()
    require('lualine').setup {
      theme = 'gruvbox_material',
      tabline = {
          -- -- lualine_a = {'buffers'},
          -- -- lualine_b = {'branch'},
          -- -- lualine_c = {'filename'},
          -- -- lualine_x = {},
          -- -- lualine_y = {},
          -- lualine_a = {'tabs', 'buffers'}
      },
      -- sections = {lualine_c = {'lsp_progress'}, lualine_x = {'tabnine'}}

      -- options = {
      --   icons_enabled = true,
      --   theme = 'auto',
      --   component_separators = { left = '', right = ''},
      --   section_separators = { left = '', right = ''},
      --   disabled_filetypes = {
      --     statusline = {},
      --     winbar = {},
      --   },
      --   ignore_focus = {},
      --   always_divide_middle = true,
      --   globalstatus = false,
      --   refresh = {
      --     statusline = 1000,
      --     tabline = 1000,
      --     winbar = 1000,
      --   }
      -- },
      -- sections = {
      --   lualine_a = {'mode'},
      --   lualine_b = {'branch', 'diff', 'diagnostics'},
      --   lualine_c = {'filename'},
      --   lualine_x = {'encoding', 'fileformat', 'filetype'},
      --   lualine_y = {'progress'},
      --   lualine_z = {'location'}
      -- },
      -- inactive_sections = {
      --   lualine_a = {},
      --   lualine_b = {},
      --   lualine_c = {'filename'},
      --   lualine_x = {'location'},
      --   lualine_y = {},
      --   lualine_z = {}
      -- },
      -- tabline = {},
      -- winbar = {},
      -- inactive_winbar = {},
      -- extensions = {}
    }
  end
}
