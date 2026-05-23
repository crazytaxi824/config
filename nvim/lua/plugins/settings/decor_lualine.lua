local lualine_status_ok, lualine = pcall(require, "lualine")
if not lualine_status_ok then
  return
end

--- 自定义 theme ----------------------------------------------------------------------------------- {{{
--- https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/themes/gruvbox_light.lua
local lualine_colors = {
  black = Colors.black.g,
  white = Colors.white.g,

  yellow = Colors.yellow.g,
  gold = Colors.gold_fn.g,  -- filename saved
  cyan = Colors.cyan.g,   -- filename modified

  grey_b = Colors.g238.g,  -- section_b
  grey_fg = Colors.g245.g, -- fg color: inactive, hint

  red = Colors.red.g,  -- error, readonly
  orange = Colors.orange.g, -- warn, readonly file, trailing_whitespace && mixed_indent
  blue = Colors.blue.g,  -- info background
  green = Colors.green_bg.g,  -- Command mode
}

--- airline 颜色设置 https://github.com/vim-airline/vim-airline/blob/master/autoload/airline/themes/dark.vim
local my_theme = {
  normal = {
    a = { fg = lualine_colors.black, bg = lualine_colors.yellow, gui = "bold" },
    b = { fg = lualine_colors.white, bg = lualine_colors.grey_b },
    c = { fg = lualine_colors.gold, bg = lualine_colors.black },
  },

  --- 其他模式如果缺省设置, 则继承 normal 的设置
  insert = {
    a = { fg = lualine_colors.black, bg = "#00D7FF", gui = 'bold' },
    b = { fg = lualine_colors.white, bg = "#0000D7" },
    c = { fg = lualine_colors.white, bg = "#00005F" },
  },
  replace = {
    a = { fg = lualine_colors.white, bg = "#AF0000", gui = 'bold' },
    b = { fg = lualine_colors.white, bg = "#0000D7" },
    c = { fg = lualine_colors.white, bg = "#00005F" },
  },
  visual = {
    a = { fg = lualine_colors.black, bg = lualine_colors.orange, gui = 'bold' },
    b = { fg = lualine_colors.black, bg = "#D75F00" },
    c = { fg = lualine_colors.white, bg = "#5F0000" },
  },
  command = {
    a = { fg = lualine_colors.black, bg = lualine_colors.green, gui = 'bold' },
    b = { fg = lualine_colors.white, bg = lualine_colors.grey_b },
    c = { fg = lualine_colors.white, bg = lualine_colors.black },
  },

  inactive = {
    a = { fg = lualine_colors.gold, bg = lualine_colors.grey_b },
    b = { fg = lualine_colors.white, bg = lualine_colors.black },
    c = { fg = lualine_colors.grey_fg, bg = lualine_colors.black },
  },
}
--- }}}

--- 自定义 components ------------------------------------------------------------------------------ {{{
--- NOTE: https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets

--- VVI: whitespace & mix-indent 非常消耗资源, 可能严重中拖慢 neovim 运行速度. 不推荐在大型文件中使用.
--- 目前只在 buftype=='' and filetype~='' 情况下使用.
--- check Trailing-Whitespace && Mixed-indent ---------------------------------- {{{
--- check Trailing-Whitespace --------------------------------------------------
local function check_trailing_whitespace()
  --- search() 是 C 实现的函数, 速度快.
  local space_lnum = vim.fn.search([[\s\+$]], 'nwc')
  return space_lnum > 0 and "Ts:"..space_lnum or ""
end

--- check Mixed-indent ---------------------------------------------------------
local function check_mixed_indent()
  ---@type integer lnum
  local indent_lnum
  if vim.bo.expandtab then
    --- using space as indent, find "\t" indent
    indent_lnum = vim.fn.search([[\v^\t+]], 'nwc')
  else
    --- using "\t" as indent, find space indent
    indent_lnum = vim.fn.search([[\v^ +]], 'nwc')
  end

  if indent_lnum > 0 then
    return 'Mi:'..indent_lnum
  end
  return ''
end

--- 合并两个 check, 同时检查 ---------------------------------------------------
--- NOTE: 通过设置 set/get buffer var 来缓存 whitespace && mixed_indent 结果.
local bufvar_mi_ts = 'my_mi_ts'
local bufvar_changedtick = 'my_prev_changedtick'

local function trailing_whitespace_mixed_indent()
  --- 只在 Normal mode 下 update lualine, 可以减少计算量.
  if vim.fn.mode() == 'n' and vim.b[bufvar_changedtick] ~= vim.b.changedtick then
    local mi = check_mixed_indent()
    local ts = check_trailing_whitespace()

    if mi ~= '' and ts ~= '' then
      vim.b[bufvar_mi_ts] = mi..' '..ts
    elseif mi == '' and ts == '' then
      vim.b[bufvar_mi_ts] = nil
    else
      vim.b[bufvar_mi_ts] = mi ~= '' and mi or ts
    end

    --- NOTE: 在计算结果之后 update changedtick.
    vim.b[bufvar_changedtick] = vim.b.changedtick
  end

  return vim.b[bufvar_mi_ts] or ''
end
--- }}}

--- 修改 location && progress component ---------------------------------------- {{{
--- 参照 https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/components/progress.lua
--- NOTE: `:help 'statusline'` 中有对 l p v L... 占位符的解释. v - Virtual Column; c - Byte index.
--- '%3l' && '%-2v' 中 3/-2 表示保留位数, 就算没有文字也将保留空位.
--- '3' 表示在前面(左边)保留2个位置; '-2' 表示在后面(右边)保留1个位置.
local function my_location()
  return '%3p%%:%-2v'
end

local function my_progress()
  --- 以下可用于显示 Percentage of file.
  --- ▁ ▂ ▃ ▄ ▅ ▆ ▇ █
  --- ▏ ▎ ▍ ▌ ▋ ▊ ▉ █
  return '%3p%%:𝌆 %L'
end
--- }}}

--- }}}

--- current git branch
local bufvar_branch = 'my_current_branch'

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

    -- refresh = {  ------------------------------------------------------------ {{{
    --   statusline = 1000, -- (ms)
    --   tabline = 1000,
    --   winbar = 1000,
    --   events = {
    --     'WinEnter',
    --     'BufEnter',
    --     'BufWritePost',
    --     'SessionLoadPost',
    --     'FileChangedShellPost',
    --     'VimResized',
    --     'Filetype',
    --     'CursorMoved',
    --     'CursorMovedI',
    --     'ModeChanged',
    --   },
    -- },
    --- }}}
  },

  --- VVI: https://github.com/nvim-lualine/lualine.nvim#changing-components-in-lualine-sections
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(str)
          --- 如果 window 小于 n 则, 只显示 mode 第一个字母.
          if str ~= '' and vim.api.nvim_win_get_width(0) <= 60 then
            return string.sub(str,1,1) .. ' ' .. Nerd_icons.ellipsis
          end
          return str
        end,
      },
    },
    lualine_b = {
      {
        'branch',
        icons_enabled = true, -- 单独设置 branch 使用 icon.
        icon = {'', color={ gui='bold' }},
        fmt = function(git_branch)
          vim.b[bufvar_branch] = git_branch
          if git_branch ~= '' and vim.api.nvim_win_get_width(0) <= 80 then
            return Nerd_icons.ellipsis  -- 显示为 ` `
          end
          return git_branch
        end,
        color = function()
          --- 如果是 edit 没有 .git 的文件, 这里的函数不会运行.
          if vim.b[bufvar_branch] and (vim.b[bufvar_branch] == 'main' or vim.b[bufvar_branch] == 'master') then
            return { bg = "#D70000", gui = 'bold' }
          end
          --- NOTE: return nil 时使用 theme 的默认颜色.
        end,
      },
    },
    lualine_c = {
      {
        'diagnostics',
        symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'},
        update_in_insert = false, -- Update diagnostics in insert mode.
        diagnostics_color = {
          --error = 'ErrorMsg',  -- 也可以使用 highlight group.
          error = {fg=lualine_colors.red, gui='bold'},        -- Changes diagnostics' error color.
          warn  = {fg=lualine_colors.orange, gui='bold'},     -- Changes diagnostics' warn color.
          info  = {fg=lualine_colors.blue, gui='bold'},       -- Changes diagnostics' info color.
          hint  = {fg=lualine_colors.grey_fg, gui='bold'}, -- Changes diagnostics' hint color.
        },
      },
      {
        trailing_whitespace_mixed_indent,
        color = {fg=lualine_colors.blue, gui='bold'},
        cond = function()
          -- normal buffer with a filetype
          return vim.bo.filetype ~= '' and vim.bo.buftype == '' and vim.api.nvim_buf_line_count(0) < 5000
        end,
      },
    },
    lualine_x = {
      {
        'filename',
        path = 3, -- 路径显示模式:
                  -- 0: Just the filename
                  -- 1: Relative path
                  -- 2: Absolute path
                  -- 3: Absolute path, with tilde as the home directory '~'
                  -- 4: Filename and parent dir, with tilde as the home directory
        symbols = {
          modified = Nerd_icons.dot, -- Text to show when the file is modified.
          readonly = Nerd_icons.lock,     -- Text to show when the file is non-modifiable or readonly.
          unnamed  = '[No Name]', -- Text to show for unnamed buffers.
        },
        cond = function() return vim.api.nvim_win_get_width(0) > 50 end,
        fmt = function(str)
          if str ~= '' and vim.api.nvim_win_get_width(0) <= 100 then
            return vim.fs.basename(str)
          end
          return str
        end,
        color = function()
          if vim.bo.modified and vim.bo.readonly then  -- 对 readonly 文件做出修改
            return {fg = lualine_colors.white, bg = lualine_colors.red, gui='bold'}
          elseif vim.bo.modified then  -- 修改后未保存的文件
            return {fg = lualine_colors.cyan, gui='bold'}
          elseif vim.bo.readonly then  -- readonly 文件
            return {fg = lualine_colors.orange, gui='bold'}
          end
          return {fg = lualine_colors.gold} -- 其他情况
        end,

        --- number of clicks incase of multipl8 clicks
        --- mouse button used (l(left)/r(right)/m(middle)/...)
        --- modifiers pressed (s(shift)/c(ctrl)/a(alt)/m(meta)...)
        --on_click = function(number, mouse, modifiers) end,
      },
    },
    lualine_y = {
      {
        'filetype',
        fmt = function(str)
          return " " .. str
        end
      },
      {
        'encoding',
        padding = { left=0, right=1 },
        fmt = function(str)
          if str ~= '' and vim.api.nvim_win_get_width(0) <= 80 then
            return ""
          end
          return str
        end
      },
      {
        'fileformat',
        padding = { left=0, right=1 },
        fmt = function(str)
          if str ~= '' and vim.api.nvim_win_get_width(0) <= 80 then
            return ""
          end
          if str == 'unix' then
            return "[LF]"
          elseif str == 'dos' then
            return "[CRLF]"
          elseif str == 'mac' then
            return "[CR]"
          end
          return "[".. str .."]"
        end
      },
    },
    lualine_z = {
      {
        my_location,
        fmt = function(str)
          if str ~= '' and vim.api.nvim_win_get_width(0) <= 80 then
            return '%2v'
          end
          return str
        end
      },
    },
  },

  --- cursor 不在窗口时(失去焦点的窗口)所显示的信息, 以及颜色.
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        'diagnostics',
        icons_enabled = true,
        icon = {Nerd_icons.diag.warn, color={fg = lualine_colors.orange, gui = 'bold'}},
        symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'},
        diagnostics_color = {
          --error = 'ErrorMsg',  -- 也可以使用 highlight group.
          error = {fg=lualine_colors.red, gui='bold'},        -- Changes diagnostics' error color.
          warn  = {fg=lualine_colors.orange, gui='bold'},     -- Changes diagnostics' warn color.
          info  = {fg=lualine_colors.blue, gui='bold'},       -- Changes diagnostics' info color.
          hint  = {fg=lualine_colors.grey_fg, gui='bold'}, -- Changes diagnostics' hint color.
        },
      },
      {
        trailing_whitespace_mixed_indent,
        color = {fg=lualine_colors.blue, gui='bold'},
        cond = function() return vim.bo.filetype~='' and vim.bo.buftype=='' end,  -- normal buffer with a filetype
      },
    },
    lualine_x = {
      {
        'filename',
        path = 0,
        symbols = {
          modified = Nerd_icons.dot,  -- Text to show when the file is modified.
          readonly = Nerd_icons.lock, -- Text to show when the file is non-modifiable or readonly.
          unnamed  = '[No Name]',     -- Text to show for unnamed buffers.
        },
        color = function()
          if vim.bo.modified and vim.bo.readonly then  -- 对 readonly 文件做出修改
            return {fg = lualine_colors.white, bg = lualine_colors.red, gui='bold'}
          elseif vim.bo.modified then  -- 修改后未保存的文件
            return {fg = lualine_colors.cyan, gui='bold'}
          elseif vim.bo.readonly then  -- readonly 文件
            return {fg = lualine_colors.orange, gui='bold'}
          end

          -- NOTE: 必须设置 bg color, 否则会随 Insert Mode 改变 filename bg color
          return {fg = lualine_colors.grey_fg, bg = my_theme.inactive.c.bg}
        end,
      },
    },
    lualine_y = {},
    lualine_z = {},
  },

  --- You can use lualine to display components in tabline. The configuration for
  --- tabline sections is exactly the same as that of the statusline(sections).
  --- tabline, winbar ------------------------------------------------------------------------------ {{{
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
  --- }}}

  --- lualine extensions change statusline appearance for a window/buffer with specified filetypes.
  --- https://github.com/nvim-lualine/lualine.nvim#extensions
  extensions = {
    'nvim-tree', 'nerdtree', 'neo-tree',
    'quickfix',  --- 'quickfix' includes 'loclist' and 'quickfix'
    'trouble',
    -- 'mason', 'lazy', 'fzf',
  },
}



