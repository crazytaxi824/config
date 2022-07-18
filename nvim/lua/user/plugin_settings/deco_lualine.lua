local lualine_status_ok, lualine = pcall(require, "lualine")
if not lualine_status_ok then
  return
end

--- 自定义 theme ----------------------------------------------------------------------------------- {{{
--- https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/themes/gruvbox_light.lua
local colors = {
  black = 233,
  white = 188,

  green = 190,
  light_green = 85,

  grey  = 236,
  light_grey = 246,
}

local my_theme = {
  normal = {
    a = { fg = colors.black, bg = colors.green, gui = "bold" },
    b = { fg = colors.white, bg = colors.grey },
    c = { fg = colors.light_green, bg = colors.black },
  },

  --- 以下都是和 normal 相同
  -- insert = { a = { fg = colors.black, bg = colors.blue } },
  -- visual = { a = { fg = colors.black, bg = colors.cyan } },
  -- replace = { c = { fg = colors.white, bg = 17 } },

  inactive = {
    a = { fg = colors.light_green, bg = colors.grey },
    b = { fg = colors.white, bg = colors.black },
    c = { fg = colors.light_grey, bg = colors.black },
  },
}
-- -- }}}

lualine.setup {
  options = {
    theme = my_theme,  -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
    icons_enabled = false, -- 不使用 icon, NOTE: 可以在 sections 中单独设置. `:help lualine-Global-options`
    component_separators = { left = '', right = ''},
    section_separators = { left = ' ', right = ' '},
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = false,  -- true - 则全局所有 window 使用同一个 status line; false - 每个window 单独自己的 status line.
  },

  --- VVI: https://github.com/nvim-lualine/lualine.nvim#changing-components-in-lualine-sections
  sections = {
    lualine_a = {'mode'},  -- NOTE: 如果要显示自定义文字需要使用 function() return "foo" end
    lualine_b = {
      {'branch',
        icons_enabled = true, -- 单独设置 branch 使用 icon.
        icon = {'', color={fg='green'}},
      }
    },
    lualine_c = {
      {'filename',
        path = 3,  -- Absolute path, with ~ as the home directory
        symbols = {
          modified = '[+]',      -- Text to show when the file is modified.
          readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
          unnamed = '[No Name]', -- Text to show for unnamed buffers.
        },
        --- NOTE: output format
        -- fmt = function(content)
        --   print(content:sub(-3,-1))
        --   return content
        -- end,
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
    lualine_x = {'diagnostics'},
    lualine_y = {},
    lualine_z = {}
  },

  --- display components in tabline at top.
  tabline = {},

  --- lualine extensions change statusline appearance for a window/buffer with specified filetypes.
  --- https://github.com/nvim-lualine/lualine.nvim#extensions
  --- NOTE: 'quickfix' includes loclist and quickfix
  extensions = {'nvim-tree', 'nerdtree', 'quickfix'},
}

--- 无法使用 lualine 的情况下 StatusLine 颜色 ------------------------------------------------------
--- eg: tagbar 有自己设置的 ':set statusline?'
vim.cmd('hi! StatusLine cterm=NONE ctermfg=' .. colors.light_green .. ' ctermbg=' .. colors.black)  -- active
vim.cmd('hi! StatusLineNC cterm=NONE ctermfg=' .. colors.light_grey .. ' ctermbg=' .. colors.black) -- inactive



