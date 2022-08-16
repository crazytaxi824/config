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
  light_green = 85,  -- filename saved
  light_blue = 81,   -- filename modified

  grey  = 236,
  light_grey = 246,  -- inactive, hint

  red = 167,  -- error, readonly
  orange = 214, -- warn
  blue = 63,  -- info
  dark_orange = 202, -- trailing_whitespace && mixed_indent
}

--- Airline theme color
--- black = 233; white = 188
--- normal: a = black/190, b = white/grey, c = 190/black  -- yellow
--- insert: a = black/45, b = white/27, c = white/17      -- blue
--- visual: a = black/214, b = black/202, c = white/52    -- orange
--- replace: a = white/124, b = white/27, c = white/17    -- red
local my_theme = {
  normal = {
    a = { fg = colors.black, bg = colors.green, gui = "bold" },
    b = { fg = colors.white, bg = colors.grey },
    c = { fg = colors.light_green, bg = colors.black },
  },

  --- 其他模式如果缺省设置, 则继承 normal 的设置 --------------------------------------------------- {{{
  -- insert = {
  --   a = { fg = colors.black, bg = 45, gui = 'bold' },
  --   b = { fg = colors.white, bg = 27},
  --   c = { fg = colors.white, bg = 17},
  -- },
  -- visual = {
  --   a = { fg = colors.black, bg = 214, gui = 'bold' },
  --   b = { fg = colors.black, bg = 202},
  --   c = { fg = colors.white, bg = 52},
  -- },
  -- replace = {
  --   a = { fg = colors.white, bg = 124, gui = 'bold' },
  --   b = { fg = colors.white, bg = 27},
  --   c = { fg = colors.white, bg = 17},
  -- },
  -- command = {},
  -- -- }}}

  inactive = {
    a = { fg = colors.light_green, bg = colors.grey },
    b = { fg = colors.white, bg = colors.black },
    c = { fg = colors.light_grey, bg = colors.black },
  },
}
-- -- }}}

--- 自定义 components ------------------------------------------------------------------------------ {{{
--- NOTE: https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets
--- check Trailing-Whitespace && Mixed-indent ---------------------------------- {{{
--- check Trailing-Whitespace --------------------------------------------------
local function check_trailing_whitespace()
  local space = vim.fn.search([[\s\+$]], 'nwc')
  return space ~= 0 and "TS:"..space or ""
end

--- check Mixed-indent ---------------------------------------------------------
local function check_mixed_indent()
  local space_pat = [[\v^ +]]
  local tab_pat = [[\v^\t+]]
  local space_indent = vim.fn.search(space_pat, 'nwc')
  local tab_indent = vim.fn.search(tab_pat, 'nwc')
  local mixed = (space_indent > 0 and tab_indent > 0)  -- 判断同一个 file 中是否有 mixed_indent

  local mixed_same_line
  if not mixed then
    mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], 'nwc')  -- 判断同一行中是否有 mixed_indent
    mixed = mixed_same_line > 0
  end
  if not mixed then return '' end  --- no mixed_indent

  --- 如果 mixed_same_line 则先返回 mixed_same_line
  if mixed_same_line ~= nil and mixed_same_line > 0 then
     return 'MI:'..mixed_same_line
  end

  --- 如果 mixed_indent in file, 则返回数量少的 indent line.
  local space_indent_cnt = vim.fn.searchcount({pattern=space_pat, max_count=1e3}).total
  local tab_indent_cnt =  vim.fn.searchcount({pattern=tab_pat, max_count=1e3}).total
  if space_indent_cnt > tab_indent_cnt then
    return 'MI:'..tab_indent
  else
    return 'MI:'..space_indent
  end
end

--- 合并两个 check, 同时检查 ---------------------------------------------------
local function my_check()
  --- 通过设置 setbufvar() / getbufvar() 来缓存 whitespace && mixed_indent 结果.
  local bufvar_lualine = 'my_lualine_checks'

  --- NOTE: 在退出 insert mode 之后再进行计算并更新 lualine, 可以减少计算量.
  if vim.fn.mode() ~= 'i' then
    local mi = check_mixed_indent()
    local ts = check_trailing_whitespace()

    if mi ~= '' and ts ~= '' then
      vim.fn.setbufvar(vim.fn.bufnr(), bufvar_lualine, mi .. ' ' .. ts)
    else
      vim.fn.setbufvar(vim.fn.bufnr(), bufvar_lualine, mi .. ts)
    end
  end

  return vim.fn.getbufvar(vim.fn.bufnr(), bufvar_lualine)
end
-- -- }}}

--- 修改 location && progress component ---------------------------------------- {{{
--- 参照 https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/components/progress.lua
--- NOTE: `:help 'statusline'` 中有对 l p v L... 占位符的解释.
--- '%3l' && '%-2v' 中 3/-2 表示保留位数, 就算没有文字也将保留空位.

local function my_location()
  return '%3l:%-2v'
end

local function my_progress()
  return '%3p%%:𝌆 %L'
end
-- -- }}}

-- -- }}}

--- `:help lualine-Global-options`
lualine.setup {
  options = {
    theme = my_theme,  -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
    icons_enabled = false, -- 不使用 icon, NOTE: 可以在 sections 中单独设置. `:help lualine-Global-options`
    component_separators = { left = '', right = ''},  -- 'mode', 'filename', 'branch' ... 这些属于 components
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
        path = 3, -- 路径显示模式.
                  -- 0: Just the filename
                  -- 1: Relative path
                  -- 2: Absolute path
                  -- 3: Absolute path, with tilde as the home directory '~'
        symbols = {
          modified = '[+]',       -- Text to show when the file is modified.
          readonly = '[-]',       -- Text to show when the file is non-modifiable or readonly.
          unnamed  = '[No Name]', -- Text to show for unnamed buffers.
        },
        color = function()
          if vim.bo.modified and vim.bo.readonly then
            return {fg = colors.white, bg = colors.red, gui='bold'}
          elseif vim.bo.modified then
            return {fg = colors.light_blue, gui='bold'}
          elseif vim.bo.readonly then
            return {fg = colors.red, gui='bold'}
          else
            return {fg = colors.light_green}
          end
        end,
        --on_click = function(number, mouse, modifiers) end,  -- - number of clicks incase of multiple clicks
                                                              -- - mouse button used (l(left)/r(right)/m(middle)/...)
                                                              -- - modifiers pressed (s(shift)/c(ctrl)/a(alt)/m(meta)...)
      },
    },
    lualine_x = {'encoding', 'filetype'},
    lualine_y = {my_progress},  -- 自定义 component, 修改自 builtin 'progress' component
    lualine_z = {
      {my_location},
      {my_check, color = {bg=colors.dark_orange, fg=colors.black, gui='bold'}},  -- 自定义 component
      { 'diagnostics',
        symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'},
        update_in_insert = false, -- Update diagnostics in insert mode.
        diagnostics_color = {
          --error = 'ErrorMsg',  -- 也可以使用 highlight group.
          error = {bg=colors.red, fg=colors.white, gui='bold'},        -- Changes diagnostics' error color.
          warn  = {bg=colors.orange, fg=colors.black, gui='bold'},     -- Changes diagnostics' warn color.
          info  = {bg=colors.blue, fg=colors.white, gui='bold'},       -- Changes diagnostics' info color.
          hint  = {bg=colors.light_grey, fg=colors.black, gui='bold'}, -- Changes diagnostics' hint color.
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
          modified = '[+]',       -- Text to show when the file is modified.
          readonly = '[-]',       -- Text to show when the file is non-modifiable or readonly.
          unnamed  = '[No Name]', -- Text to show for unnamed buffers.
        },
        color = function()
          if vim.bo.modified and vim.bo.readonly then
            return {fg = colors.white, bg = colors.red, gui='bold'}
          elseif vim.bo.modified then
            return {fg = colors.light_blue}
          elseif vim.bo.readonly then
            return {fg = colors.red}
          else
            return {fg = colors.light_grey}
          end
        end,
      },
    },
    lualine_x = {
      {my_check, color = {fg=colors.dark_orange, gui='bold'}},  -- 自定义 components
      { 'diagnostics',
        symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'},
        diagnostics_color = {
          --error = 'ErrorMsg',  -- 也可以使用 highlight group.
          error = {fg=colors.red, gui='bold'},        -- Changes diagnostics' error color.
          warn  = {fg=colors.orange, gui='bold'},     -- Changes diagnostics' warn color.
          info  = {fg=colors.blue, gui='bold'},       -- Changes diagnostics' info color.
          hint  = {fg=colors.light_grey, gui='bold'}, -- Changes diagnostics' hint color.
        },
      }
    },
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
vim.cmd('hi StatusLine cterm=NONE ctermfg=' .. colors.light_green .. ' ctermbg=' .. colors.black)  -- active
vim.cmd('hi StatusLineNC cterm=NONE ctermfg=' .. colors.light_grey .. ' ctermbg=' .. colors.black) -- inactive



