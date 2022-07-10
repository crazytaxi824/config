local lualine_status_ok, lualine = pcall(require, "lualine")
if not lualine_status_ok then
  return
end

lualine.setup {
  options = {
    theme = "ayu_mirage",  -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
    icons_enabled = false, -- 不使用 icon
    component_separators = { left = '', right = ''},
    section_separators = { left = ' ', right = ' '},
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = false,
  },

  --- VVI: https://github.com/nvim-lualine/lualine.nvim#changing-components-in-lualine-sections
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff'},
    lualine_c = {
      {'filename',
        path = 3,  -- Absolute path, with ~ as the home directory
        symbols = {
          modified = '[+]',      -- Text to show when the file is modified.
          readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
          unnamed = '[No Name]', -- Text to show for unnamed buffers.
        },
      },
    },
    lualine_x = {'encoding', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location',
      {'diagnostics',
        diagnostics_color = {
          error = 'ErrorMsg',        -- Changes diagnostics' error color.
          warn  = 'WarningMsg',      -- Changes diagnostics' warn color.
          info  = 'SpecialComment',  -- Changes diagnostics' info color.
          hint  = 'DiagnosticHint',  -- Changes diagnostics' hint color.
        },
      },
    },
  },

  --- cursor 不在窗口时(失去焦点的窗口)所显示的信息, 以及颜色.
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'diagnostics'},
    lualine_y = {},
    lualine_z = {}
  },

  --- display components in tabline at top.
  tabline = {},

  --- lualine extensions change statusline appearance for a window/buffer with specified filetypes.
  --- https://github.com/nvim-lualine/lualine.nvim#extensions
  extensions = {'nvim-tree'},
}



