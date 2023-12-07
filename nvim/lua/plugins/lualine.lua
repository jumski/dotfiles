return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
  config = function()
    require('lualine').setup {
      options = {
        theme = 'gruvbox',
        icons_enabled = true,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },

        -- defaults
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 100,
          tabline = 100,
          winbar = 100,
        }
      },
      sections = {
        lualine_a = {'mode'},
        -- lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_b = {'branch', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {},
      winbar = {},
      inactive_winbar = {},
      tabline = {},
      inactive_tabline = {},
      extensions = {},
    }
  end
}

