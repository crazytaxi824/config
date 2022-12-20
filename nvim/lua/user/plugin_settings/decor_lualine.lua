local lualine_status_ok, lualine = pcall(require, "lualine")
if not lualine_status_ok then
  return
end

--- 自定义 theme ----------------------------------------------------------------------------------- {{{
--- https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/themes/gruvbox_light.lua
local lualine_colors = {
  black = Color.black,
  white = Color.white,

  yellow = Color.statusline_yellow,
  gold = Color.func_gold,  -- filename saved
  cyan = Color.cyan,   -- filename modified

  grey  = 236,       -- section_b
  light_grey = 245,  -- inactive, hint

  red = Color.error_red,  -- error, readonly
  orange = Color.warn_orange, -- warn
  blue = Color.info_blue,  -- info background
  green = Color.comment_green,  -- Command mode

  dark_orange = Color.dark_orange, -- trailing_whitespace && mixed_indent
}

--- airline 颜色设置 https://github.com/vim-airline/vim-airline/blob/master/autoload/airline/themes/dark.vim
local my_theme = {
  normal = {
    a = { fg = lualine_colors.black, bg = lualine_colors.yellow, gui = "bold" },
    b = { fg = lualine_colors.white, bg = lualine_colors.grey },
    c = { fg = lualine_colors.gold, bg = lualine_colors.black },
  },

  --- 其他模式如果缺省设置, 则继承 normal 的设置
  insert = {
    a = { fg = lualine_colors.black, bg = 45, gui = 'bold' },
    b = { fg = lualine_colors.white, bg = 20 },
    c = { fg = lualine_colors.white, bg = 17 },
  },
  visual = {
    a = { fg = lualine_colors.black, bg = lualine_colors.orange, gui = 'bold' },
    b = { fg = lualine_colors.black, bg = lualine_colors.dark_orange },
    c = { fg = lualine_colors.white, bg = 52 },
  },
  replace = {
    a = { fg = lualine_colors.white, bg = 124, gui = 'bold' },
    b = { fg = lualine_colors.white, bg = 20 },
    c = { fg = lualine_colors.white, bg = 17 },
  },
  command = {
    a = { fg = lualine_colors.black, bg = Color.comment_green, gui = 'bold' },
    b = { fg = lualine_colors.white, bg = lualine_colors.grey },
    c = { fg = lualine_colors.white, bg = lualine_colors.black },
  },

  inactive = {
    a = { fg = lualine_colors.gold, bg = lualine_colors.grey },
    b = { fg = lualine_colors.white, bg = lualine_colors.black },
    c = { fg = lualine_colors.light_grey, bg = lualine_colors.black },
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
--- NOTE: 通过设置 setbufvar() / getbufvar() 来缓存 whitespace && mixed_indent 结果.
local function my_check()
  local bufvar_lualine = 'my_lualine_checks'

  --- 在退出 insert mode 之后再进行计算并更新 lualine, 可以减少计算量.
  if vim.fn.mode() ~= 'i' then
    local mi = check_mixed_indent()
    local ts = check_trailing_whitespace()

    if mi ~= '' and ts ~= '' then
      vim.fn.setbufvar(vim.fn.bufnr(), bufvar_lualine, ' '..mi..' '..ts)
    elseif mi ~= '' and ts == '' then
      vim.fn.setbufvar(vim.fn.bufnr(), bufvar_lualine, ' '..mi)
    elseif mi == '' and ts ~= '' then
      vim.fn.setbufvar(vim.fn.bufnr(), bufvar_lualine, ' '..ts)
    else
      vim.fn.setbufvar(vim.fn.bufnr(), bufvar_lualine, '')
    end
  end

  return vim.fn.getbufvar(vim.fn.bufnr(), bufvar_lualine)
end
-- -- }}}

--- 修改 location && progress component ---------------------------------------- {{{
--- 参照 https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/components/progress.lua
--- NOTE: `:help 'statusline'` 中有对 l p v L... 占位符的解释. v - Virtual Column; c - Byte index.
--- '%3l' && '%-2v' 中 3/-2 表示保留位数, 就算没有文字也将保留空位.
--- '3' 表示在前面(左边)保留2个位置; '-2' 表示在后面(右边)保留1个位置.

local function my_location()
  return '%3l:%-2v'
end

local function my_progress()
  return '%3p%%:𝌆 %L'
end
-- -- }}}

--- indicate 文件是否 modified / readonly -------------------------------------- {{{
--- NOTE: 这里主要是为了解决 inactive_sections 中的 filename 无法分别设置颜色.
local function modified_readonly()
  if vim.bo.modified and vim.bo.readonly then  -- 对 readonly 文件做出修改
    return "modified readonly"
  end
  return ''
end

local function readonly()
  if vim.bo.readonly and not vim.bo.modified then  -- 如果是 modified_readonly 则不显示
    return "readonly"
  end
  return ''
end

local function modified()
  if vim.bo.modified and not vim.bo.readonly then  -- 如果是 modified_readonly 则不显示
    return "modified"
  end
  return ''
end
-- -- }}}

-- -- }}}

--- `:help lualine-Global-options`
lualine.setup {
  options = {
    theme = my_theme,  -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
    icons_enabled = false, -- 不使用默认 icon, 可以在 sections 中设置自定义 icon. `:help lualine-Global-options`
    component_separators = { left = '', right = ''},  -- 'mode', 'filename', 'branch' ... 这些属于 components
    section_separators = { left = ' ', right = ' '},  -- lualine_a, lualine_b, ...
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {'tagbar'},  -- If current filetype is in this list it'll always be drawn as inactive statusline
    always_divide_middle = true,
    globalstatus = false,  -- true - 则全局所有 window 使用同一个 status line;
                           -- false - 每个window 单独自己的 status line.
    refresh = {
      statusline = 1000, -- (ms)
      tabline = 1000,
      winbar = 1000,
    }
  },

  --- VVI: https://github.com/nvim-lualine/lualine.nvim#changing-components-in-lualine-sections
  sections = {
    lualine_a = {'mode'},  -- NOTE: 如果要显示自定义文字需要使用 function() return "foo" end
    lualine_b = {
      {'branch',
        icons_enabled = true, -- 单独设置 branch 使用 icon.
        icon = {'', color={ gui='bold' }},
      },
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
          if vim.bo.modified and vim.bo.readonly then  -- 对 readonly 文件做出修改
            return {fg = lualine_colors.white, bg = lualine_colors.red, gui='bold'}
          elseif vim.bo.modified then  -- 修改后未保存的文件
            return {fg = lualine_colors.cyan, gui='bold'}
          elseif vim.bo.readonly then  -- readonly 文件
            return {fg = lualine_colors.dark_orange, gui='bold'}
          end
          return {fg = lualine_colors.gold} -- 其他情况
        end,

        --- number of clicks incase of multiple clicks
        --- mouse button used (l(left)/r(right)/m(middle)/...)
        --- modifiers pressed (s(shift)/c(ctrl)/a(alt)/m(meta)...)
        --on_click = function(number, mouse, modifiers) end,
      },
    },
    lualine_x = {'encoding', 'filetype'},
    lualine_y = {my_progress},  -- 自定义 component, 修改自 builtin 'progress' component
    lualine_z = {
      {my_location},
      {my_check, color = {bg=lualine_colors.black, fg=lualine_colors.light_grey, gui='bold'}},  -- 自定义 component
      { 'diagnostics',
        symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'},
        update_in_insert = false, -- Update diagnostics in insert mode.
        diagnostics_color = {
          --error = 'ErrorMsg',  -- 也可以使用 highlight group.
          error = {bg=lualine_colors.black, fg=lualine_colors.red, gui='bold'},        -- Changes diagnostics' error color.
          warn  = {bg=lualine_colors.black, fg=lualine_colors.orange, gui='bold'},     -- Changes diagnostics' warn color.
          info  = {bg=lualine_colors.black, fg=lualine_colors.blue, gui='bold'},       -- Changes diagnostics' info color.
          hint  = {bg=lualine_colors.black, fg=lualine_colors.light_grey, gui='bold'}, -- Changes diagnostics' hint color.
        },
      },
    },
  },

  --- cursor 不在窗口时(失去焦点的窗口)所显示的信息, 以及颜色.
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      --- NOTE: 以下三个 components 主要是为了解决 inactive_sections 中的 filename 无法分别设置颜色.
      {modified_readonly, color = {fg=lualine_colors.white, bg=lualine_colors.red, gui='bold'}},
      {readonly, color = {fg=lualine_colors.dark_orange, gui='bold'}},
      {modified, color = {fg=lualine_colors.cyan, gui='bold'}},
      {'filename',
        path = 3,  -- Absolute path, with ~ as the home directory
        symbols = {
          modified = '[+]',       -- Text to show when the file is modified.
          readonly = '[-]',       -- Text to show when the file is non-modifiable or readonly.
          unnamed  = '[No Name]', -- Text to show for unnamed buffers.
          --- NOTE: 这里设置 color = function() 会导致所有 inactive buffer 的 filename 颜色一起改变.
        },
      },
    },
    lualine_x = {
      {my_check, color = {bg=lualine_colors.black, fg=lualine_colors.light_grey, gui='bold'}},  -- 自定义 component
      { 'diagnostics',
        symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'},
        diagnostics_color = {
          --error = 'ErrorMsg',  -- 也可以使用 highlight group.
          error = {bg=lualine_colors.black, fg=lualine_colors.red, gui='bold'},        -- Changes diagnostics' error color.
          warn  = {bg=lualine_colors.black, fg=lualine_colors.orange, gui='bold'},     -- Changes diagnostics' warn color.
          info  = {bg=lualine_colors.black, fg=lualine_colors.blue, gui='bold'},       -- Changes diagnostics' info color.
          hint  = {bg=lualine_colors.black, fg=lualine_colors.light_grey, gui='bold'}, -- Changes diagnostics' hint color.
        },
      },
    },
    lualine_y = {},
    lualine_z = {},
  },

  --- You can use lualine to display components in tabline. The configuration for
  --- tabline sections is exactly the same as that of the statusline(sections).
  --- tabline, winbar --- {{{
  -- tabline = {
  --   lualine_a = {'buffers'},
  --   lualine_b = {'branch'},
  --   lualine_c = {'filename'},
  --   lualine_x = {},
  --   lualine_y = {},
  --   lualine_z = {'tabs'},
  -- },
  -- winbar = {},  -- 设置方法都一样.
  -- inactive_winbar = {},
  -- -- }}}

  --- lualine extensions change statusline appearance for a window/buffer with specified filetypes.
  --- https://github.com/nvim-lualine/lualine.nvim#extensions
  --- NOTE: 'quickfix' includes loclist and quickfix
  extensions = {'nvim-tree', 'nerdtree', 'quickfix'},
}



