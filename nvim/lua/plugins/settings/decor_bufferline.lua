local bufferline_status_ok, bufferline = pcall(require, "bufferline")
if not bufferline_status_ok then
  return
end

--- highlight 设置 --------------------------------------------------------------------------------- {{{
--- 默认设置 `:help bufferline-highlights`
local buf_highlights = {
  --- fill 整个 bufferline banner 的背景色, NOTE: 如果需要透明, 则不要设置.
  --fill = { ctermbg = colors.fill_bg },  -- hi TabLineFill

  background = {  -- 默认设置, 其他设置缺省的时候使用该设置.
    ctermfg=Colors.g246.c, fg=Colors.g246.g,
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
  },
  buffer_visible = {  -- cursor 在别的 window 时, buffer filename 颜色.
    ctermbg=Colors.black.c, bg=Colors.black.g
  },
  buffer_selected = {
    ctermfg=Colors.gold_fn.c, fg=Colors.gold_fn.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
    italic = false,  -- 默认设置中是 buffer_selected.italic = true.
  },

  close_button = {
    ctermfg=Colors.g246.c, fg=Colors.g246.g,
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
  },
  close_button_visible = {
    ctermfg=Colors.g246.c, fg=Colors.g246.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },
  close_button_selected = {
    ctermfg=Colors.g246.c, fg=Colors.g246.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },

  --- duplicate 默认是 italic.
  --- 这里是指相同文件名的 prefix 部分. eg: prefix1/abc.txt && prefix2/abc.txt
  duplicate = {
    ctermfg=Colors.g244.c, fg=Colors.g244.g,
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
    italic = true,
  },
  duplicate_visible = {
    ctermfg=Colors.g244.c, fg=Colors.g244.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    italic = true,
  },
  duplicate_selected = {
    ctermfg=Colors.g244.c, fg=Colors.g244.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    italic = true,
  },

  --- NOTE: indicator - 当前正在显示的 buffer. ▎
  indicator_visible = {  -- background 颜色需要和 buffer_visible bg 相同
    ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },
  indicator_selected = {  -- background 颜色需要和 buffer_selected bg 相同
    ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },

  --- 右上角 tab 颜色, 1 | 2 | 3 |
  tab_selected = {
    ctermfg=Colors.black.c, fg=Colors.black.g,
    ctermbg=Colors.yellow.c, bg=Colors.yellow.g,
  },

  --- ONLY the modified_icon color. ●
  modified = {
    ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
  },
  modified_visible = {
    ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },
  modified_selected = {
    ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },

  --- NOTE: separator 颜色 -------------------------------------------------------------------------
  --- "separator" 为 buffer 之间分隔线颜色, 样式可以使用 setup() 中 separator_style 设置.
  -- separator = {
  --   ctermfg = colors.separator_fg,
  --   ctermbg = colors.tab_sel_bg,
  -- },
  -- separator_selected = {},  -- NOTE: 好像没有任何作用

  --- tab_separator 为 tab 之间分隔线颜色, 样式不能自定义
  tab_separator = {  -- tab 之间分隔线的颜色.
    ctermfg=Colors.g234.c, fg=Colors.g234.g,
  },
  tab_separator_selected = {  -- selected tab 后面一个分隔线'▕'的颜色. 最好和 tab_sel_bg 颜色相同.
    ctermfg=Colors.yellow.c, fg=Colors.yellow.g,
    ctermbg=Colors.yellow.c, bg=Colors.yellow.g,
  },

  --- "offset_separator" 为 File Explorer 和 bufferline 之间的 separator
  offset_separator = { link = 'WinSeparator' },

  --- error, warning, info, hint 颜色 --------------------------------------------------------------
  --- NOTE: 这里只是 diagnostic 部分的颜色显示, 不包括 buffer_num && buffer_name 颜色. eg: (1)
  error_diagnostic = {           -- hi BufferLineErrorDiagnostic
    ctermfg=Colors.red.c, fg=Colors.red.g,
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
    bold = true,
  },
  error_diagnostic_visible = {   -- hi BufferLineErrorDiagnosticVisible
    ctermfg=Colors.red.c, fg=Colors.red.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
  },
  error_diagnostic_selected = {  -- hi BufferLineErrorDiagnosticSelected
    ctermfg=Colors.red.c, fg=Colors.red.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
    italic = false,
  },
  warning_diagnostic = {
    ctermfg=Colors.orange.c, fg=Colors.orange.g,
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
    bold = true,
  },
  warning_diagnostic_visible = {
    ctermfg=Colors.orange.c, fg=Colors.orange.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
  },
  warning_diagnostic_selected = {
    ctermfg=Colors.orange.c, fg=Colors.orange.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
    italic = false,
  },
  info_diagnostic = {
    ctermfg=Colors.blue.c, fg=Colors.blue.g,
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
    bold = true,
  },
  info_diagnostic_visible = {
    ctermfg=Colors.blue.c, fg=Colors.blue.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
  },
  info_diagnostic_selected = {
    ctermfg=Colors.blue.c, fg=Colors.blue.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
    italic = false,
  },
  hint_diagnostic = {
    ctermfg=Colors.hint_grey.c, fg=Colors.hint_grey.g,
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
    bold = true,
  },
  hint_diagnostic_visible = {
    ctermfg=Colors.hint_grey.c, fg=Colors.hint_grey.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
  },
  hint_diagnostic_selected = {
    ctermfg=Colors.hint_grey.c, fg=Colors.hint_grey.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
    italic = false,
  },
}

--- numbers 和 buffer 颜色相同,
--- NOTE: 这里是 buffer_num 部分的颜色显示, 不包括 buffer_name && diagnostic 部分. eg: 1. 2. 3.
buf_highlights.numbers = buf_highlights.background
buf_highlights.numbers_visible = buf_highlights.buffer_visible
buf_highlights.numbers_selected = buf_highlights.buffer_selected

--- 有 error, warning, info, hint 的 buffer_name text 部分颜色设置, 默认没有颜色和背景色.
--- NOTE: 这里是 buffer_name 部分的颜色显示, 不包括 buffer_num && diagnostic 部分颜色.
buf_highlights.error = buf_highlights.background                -- hi BufferLineError
buf_highlights.error_visible = buf_highlights.buffer_visible    -- hi BufferLineErrorVisible
buf_highlights.error_selected = buf_highlights.buffer_selected  -- hi BufferLineErrorSelected
buf_highlights.warning = buf_highlights.background
buf_highlights.warning_visible = buf_highlights.buffer_visible
buf_highlights.warning_selected = buf_highlights.buffer_selected
buf_highlights.info = buf_highlights.background
buf_highlights.info_visible = buf_highlights.buffer_visible
buf_highlights.info_selected = buf_highlights.buffer_selected
buf_highlights.hint = buf_highlights.background
buf_highlights.hint_visible = buf_highlights.buffer_visible
buf_highlights.hint_selected = buf_highlights.buffer_selected

--- for 'offsets' config.
vim.api.nvim_set_hl(0, 'NvimTreeFileExplorer', vim.tbl_deep_extend('force', Highlights.Directory, {
  ctermbg=Colors.g235.c, bg=Colors.g235.g, underline=true,
}))

--- }}}

--- functions for gotoable ------------------------------------------------------------------------- {{{
--- 是否可以 go_to() 到别的 buffer.
local function check_buftype_buflisted_filetype(bufnr)
  --- 自定义: 不允许使用 bufferline.go_to() 的 filetype
  local exclude_filetypes = {
    'help', 'qf',  --- 'quickfix' && 'location-list' 的 filetype 都是 'qf'.
    'vimfiler', 'nerdtree', 'tagbar', 'NvimTree',
  }

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  --- `:help 'buftype'`, exclude buftype: nofile, terminal, quickfix, prompt, help ...
  if vim.bo[bufnr].buftype == ''
    and vim.fn.buflisted(bufnr) == 1  -- listed buffer
    and not vim.tbl_contains(exclude_filetypes, vim.bo[bufnr].filetype)
  then
    return true
  end

  return false
end

local function gotoable()
  if check_buftype_buflisted_filetype() then
    return true
  end

  --- 如果有任意一个 window 符合要求 go_to() 要求. 则当前 window 不允许 go_to() 到别的 buffer.
  for _, wininfo in ipairs(vim.fn.getwininfo()) do
    if check_buftype_buflisted_filetype(wininfo.bufnr) then
      return false
    end
  end

  --- 如果所有 window 都不符合要求. 则当前 window 允许 go_to() 到别的 buffer.
  return true
end
--- }}}

--- functions for delete buffer/tab ---------------------------------------------------------------- {{{
--- 用于 <leader>d 快捷键和 mouse actions 设置.

--- `:help bufferline-functions`
--- require("bufferline").exec(index, function(index_bufinfo, visible_buffers_info))
---  - index 是指在 bufferline 中 (最上方的文件栏) 从左向右的位置,
---    也是 visible_buffers_info 中 buffer 的 index 顺序.
---    如果传入的 index 不存在, 则不执行 callback. eg: exec(0, callback), exec(999, callback)
---  - callback 中提供: 指定的 index 的 bufinfo, 和 bufferline 中所有 buffer 的 bufinfo.
--- VVI: filename 在 bufferline 中的显示顺序一定是按照 {visible_buffers_info} 中的排序来的,
---    但是 ordinal 值则不一定和 index 相同. 它不一定是左向右的位置, 也有可能重复. eg :BufferLineTogglePin.

--- 判断 bufnr 是否为第一个 listed buffer
local function is_first_bufferline_index(bufnr)
  local is_first_index

  bufferline.exec(1, function(index_bufinfo, visible_buffers_info)
    is_first_index = index_bufinfo.id == bufnr
  end)

  return is_first_index
end

--- 判断 bufnr 是否为最后一个 listed buffer
local function is_last_bufferline_index(bufnr)
  local is_last_index

  --- 这里使用 index=1 只是为了保证该函数能运行, 这里主要用到的是 visible_buffers_info,
  --- 即: 所有 bufferline 中显示的 buffer, list 排列按显示顺序, 而不是 bufnr 顺序.
  bufferline.exec(1, function(index_bufinfo, visible_buffers_info)
    is_last_index = visible_buffers_info[#visible_buffers_info].id == bufnr
  end)

  return is_last_index
end

--- 删除当前 buffer.
--- ignore_tab 用于避免 close 最后一个 tab 导致报错: "Cannot close last tab page"
--- 如果 ignore_tab == true, 则不运行 close_current_tab()
local function bufferline_del_current_buffer()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()

  --- current buffer 修改后未保存.
  if vim.bo[current_bufnr].modified then
    Notify("Cannot close Unsaved buffer", "WARN")
    return
  end

  --- current buffer is not listed buffer
  if vim.fn.buflisted(current_bufnr) == 0 then
    vim.cmd.bdelete(current_bufnr)
    return
  end

  --- current buffer is listed buffer in multi windows, close current window
  if #vim.fn.win_findbuf(current_bufnr) > 1 then
    vim.api.nvim_win_close(current_win, false)
    return
  end

  --- current buffer is the only listed buffer in only one window
  local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
  if #listed_buffers == 1 then
    Notify("cannot delete last listed-buffer", "WARN")
    return
  end

  --- current_bufnr is Not the only listed buffer
  local prev_buf = vim.fn.bufnr('#')  -- prev_buf 可能为不存在(-1), 或者指向 unlisted buffer.

  if vim.fn.buflisted(prev_buf) == 1 then
    vim.api.nvim_win_set_buf(current_win, prev_buf)
  elseif is_first_bufferline_index(current_bufnr) then
    --- 如果当前 buffer 是排在最前面的 listed buffer 则跳到后一个 buffer;
    bufferline.cycle(1)   -- 跳转到 next buffer
  else
    --- 如果当前 buffer 不是排在最前面的 listed buffer 则跳到前一个 buffer;
    bufferline.cycle(-1)  -- 跳转到 prev buffer
  end

  vim.cmd.bdelete(current_bufnr)
end

--- 删除指定 buffer
local function bufferline_del_buffer_by_bufnr(bufnr)
  --- 判断指定 bufnr 是否为仅剩的最后一个 listed buffer
  local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
  if #listed_buffers < 2 then
    Notify("cannot delete last listed-buffer", "WARN")
    return
  end

  if vim.api.nvim_get_current_buf() == bufnr then
    --- NOTE: 删除的 buffer 是当前 buffer 时, 避免直接退出 nvim.
    bufferline_del_current_buffer()
  else
    --- 如果关闭的不是当前 buffer, 则直接删除.
    vim.cmd.bdelete({ args = {bufnr}, bang=true})  -- `:bdelete! bufnr`
  end
end

--- }}}

--- functions for left_mouse_command --------------------------------------------------------------- {{{
--- load 鼠标点击的 buffer
local function load_bufnr_on_left_click(bufnr)
  --- cursor 所在 window 中是 listed-buffer, 则允许加载指定 bufnr.
  if vim.fn.buflisted(0) == 1 then
    vim.api.nvim_set_current_buf(bufnr)  -- load 指定 buffer
    return
  end

  --- cursor 所在 window 中是 unlisted-buffer 的情况.
  for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    --- 如果有任意 window 是 listed-buffer 则不允许加载指定 bufnr.
    if vim.fn.buflisted(vim.api.nvim_win_get_buf(win_id)) == 1 then
      Notify("Cannot load buffer {" .. bufnr .. "} in this window (unlisted-buffer)", "WARN")
      return
    end
  end

  --- 如果所有 window 都是 unlisted-buffer 则允许加载指定 bufnr.
  vim.api.nvim_set_current_buf(bufnr)  -- load 指定 buffer
end
--- }}}

--- `:help bufferline-configuration`
bufferline.setup({
  --- 颜色设置
  highlights = buf_highlights,

  --- NOTE: id = bufnr; ordinal = bufferline_index
  options = {
    mode = "buffers", -- set to "tabs" to only show tabpages instead
    numbers = "ordinal", -- "none" | "ordinal" | "buffer_id" | "both" | func({ordinal,id,lower,raise}):string
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist between sessions.
                                -- 会创建一个全局变量 g:BufferlinePositions 保存自 state.custom_sort

    -- sort_by = 'id',  -- insert_after_current |insert_at_end | id | extension | relative_directory | directory | tabs | func(buf_a, buf_b)
    sort_by = function(buffer_a,buffer_b)
      local time_a = vim.b[buffer_a.id]["my_winenter_time"] or -1
      local time_b = vim.b[buffer_b.id]["my_winenter_time"] or -1

      --- '-1' means the biggest number
      if time_a == -1 then
        return false
      elseif time_b == -1 then
        return true
      end
      return time_a < time_b
    end,

    always_show_bufferline = true, -- VVI: 一直显示 bufferline
    show_tab_indicators = true, -- 多个 tab 时在右上角显示 1 | 2 | ...
    show_duplicate_prefix = true, -- VVI: whether to show duplicate buffer prefix

    --- icon 显示
    color_icons = true, -- whether or not to add the filetype icon highlights

    --- enable/disable filetype icons for buffers, using devicons.
    show_buffer_icons = true,

    --- buffer close icon
    show_buffer_close_icons = true,
    buffer_close_icon = Nerd_icons.cross,

    --- tab close icon. 无法自定义 tab close command, 所以不使用.
    show_close_icon = false,
    close_icon = Nerd_icons.cross,

    --- modified but not saved buffer icon
    modified_icon = Nerd_icons.modified,

    --- 打开的 buffer 太多, 'tabline' 放不下的情况.
    -- left_trunc_marker = '',
    -- right_trunc_marker = '',

    --- NOTE: this plugin is designed with this icon in mind,
    --- and so changing this is NOT recommended, this is intended
    --- as an escape hatch for people who cannot bear it for whatever reason
    indicator = {
      style = 'icon',  -- 'icon' | 'underline' | 'none',
      icon = '▌',  --  █ ▎▌, style = 'icon' 时生效.
    },

    --- buffer name 之间的 separator icon. [focused and unfocused]. eg: { '|', '|' }
    separator_style = {' ', ' '},

    --- mouse actions, can be a string | function, see "Mouse actions"
    --- NOTE: 这里 %d 是 bufnr() 的 placeholder. 可以使用 function(bufnr) 来设置.
    close_command = bufferline_del_buffer_by_bufnr,  -- delete 指定 bufnr, 默认 "bdelete! %d"
    left_mouse_command = load_bufnr_on_left_click,  -- load bufnr in current window. 默认 "buffer %d"
    right_mouse_command = "",  -- 取消默认值, 默认 "bdelete! %d"
    --middle_mouse_command = nil,

    --- NOTE: name_formatter can be used to change the buffer's label in the bufferline.
    -- name_formatter = function(buf)  -- buf contains a "name", "path" and "bufnr"
    --   -- remove extension from markdown files for example
    --   if buf.name:match('%.md') then
    --     return vim.fn.fnamemodify(buf.name, ':t:r')
    --   end
    -- end,

    enforce_regular_tabs = false,  -- VVI: 固定 tab size
    tab_size = 8,  -- 最小宽度
    max_name_length = 18,  -- 最大宽度
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated

    --- 显示 diagnostics info
    diagnostics = "nvim_lsp",  -- 在文件名后显示 diagnostic 错误信息.
    diagnostics_update_in_insert = false,
    --- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "("..count..")"
    end,

    --- ':help bufferline-configuration', 在 nvim-tree 上显示 "File Explorer"
    offsets = {
      {filetype="NvimTree", text="File Explorer", text_align="center", highlight="NvimTreeFileExplorer", separator=Nerd_icons.separator},
      {filetype="trouble", text="Trouble", text_align="center", highlight="NvimTreeFileExplorer", separator=Nerd_icons.separator}
    },
    --- 要使用 hover 必须 enable 'mousemoveevent'
    -- hover = {
    --   enabled = true,
    --   delay = 200,
    --   reveal = {'close'}
    -- },

    --- NOTE: this will be called a lot so don't do any heavy processing here -- {{{
    -- custom_filter = function(buf_number, buf_numbers)
    --   --- NOTE: filter out filetypes you don't want to see
    --   if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
    --     return true
    --   end
    --   --- filter out by buffer name
    --   if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
    --     return true
    --   end
    --   --- filter out based on arbitrary rules
    --   --- e.g. filter out vim wiki buffer from tabline in your work repo
    --   if vim.uv.cwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
    --     return true
    --   end
    --   --- filter out by it's index number in list (don't show first buffer)
    --   if buf_numbers[1] ~= buf_number then
    --     return true
    --   end
    -- end,
    --- }}}
  },
})

--- keymaps ----------------------------------------------------------------------------------------
local opt = { silent = true }
local bufferline_keymaps = {
  --- https://github.com/akinsho/bufferline.nvim/blob/master/lua/bufferline.lua
  {'n', '<leader>\\', function() if gotoable() then bufferline.go_to(vim.v.count1, true) end end, opt, 'which_key_ignore'},

  --- NOTE: 如果 cursor 所在的 window 中显示的(active) buffer 是 unlisted (即: 不显示在 tabline 上的 buffer),
  --- 不能使用 BufferLineCycleNext/Prev 来进行 buffer 切换, 但是可以使用 bufferline.go_to() 直接跳转.
  {'n', '<S-D-[>', function() bufferline.cycle(-1) end, opt, 'buffer: go to Prev buffer'},
  {'n', '<S-D-]>', function() bufferline.cycle(1)  end, opt, 'buffer: go to Next buffer'},

  --- 左右移动 buffer
  {'n', '<leader><Left>', '<cmd>BufferLineMovePrev<CR>', opt, 'buffer: Move Buffer Left'},
  {'n', '<leader><Right>', '<cmd>BufferLineMoveNext<CR>', opt, 'buffer: Move Buffer Right'},

  --- 关闭 buffer
  --- bufnr("#") > 0 表示 '#' (previous buffer) 存在, 如果不存在则 bufnr('#') = -1.
  --- 如果 # 存在, 但处于 unlisted 状态, 则 bdelete # 报错. 因为 `:bdelete` 本质就是 unlist buffer.
  {'n', '<leader>d', function() bufferline_del_current_buffer() end, opt, 'buffer: Close Current Buffer/Tab'},

  --- NOTE: ":BufferLineCloseRight" and ":BufferLineCloseRight" skip unwritten buffers without a bang [!].
  {'n', '<leader>Da', '<cmd>BufferLineCloseOthers<CR>', opt, 'buffer: Close all other buffers'},
  {'n', '<leader>D<Right>', '<cmd>BufferLineCloseRight<CR>', opt, 'buffer: Close Right Side Buffers'},
  {'n', '<leader>D<Left>', '<cmd>BufferLineCloseLeft<CR>', opt, 'buffer: Close Left Side Buffers'},
}

require('utils.keymaps').set(bufferline_keymaps)



