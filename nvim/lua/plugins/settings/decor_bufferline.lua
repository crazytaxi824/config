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
    ctermfg=246, fg='#949494',
    ctermbg=236, bg='#303030',
  },
  buffer_visible = {  -- cursor 在别的 window 时, buffer filename 颜色.
    ctermbg=Colors.black.c, bg=Colors.black.g
  },
  buffer_selected = {
    ctermfg=Colors.func_gold.c, fg=Colors.func_gold.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
    italic = false,  -- 默认设置中是 buffer_selected.italic = true.
  },

  close_button = {
    ctermfg=246, fg='#949494',
    ctermbg=236, bg='#303030',
  },
  close_button_visible = {
    ctermfg=246, fg='#949494',
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },
  close_button_selected = {
    ctermfg=246, fg='#949494',
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },

  --- duplicate 默认是 italic.
  --- 这里是指相同文件名的 prefix 部分. eg: prefix1/abc.txt && prefix2/abc.txt
  duplicate = {
    ctermfg = 244, fg='#808080',
    ctermbg=236, bg='#303030',
    italic = true,
  },
  duplicate_visible = {
    ctermfg = 244, fg='#808080',
    ctermbg=Colors.black.c, bg=Colors.black.g,
    italic = true,
  },
  duplicate_selected = {
    ctermfg = 244, fg='#808080',
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
    ctermbg=236, bg='#303030',
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
    ctermfg=234, fg='#1c1c1c',
  },
  tab_separator_selected = {  -- selected tab 后面一个分隔线'▕'的颜色. 最好和 tab_sel_bg 颜色相同.
    ctermfg=Colors.yellow.c, fg=Colors.yellow.g,
    ctermbg=Colors.yellow.c, bg=Colors.yellow.g,
  },

  --- "offset_separator" 为 File Explorer 和 bufferline 之间的 separator, 样式不能自定义
  offset_separator = { link = 'VertSplit' },

  --- error, warning, info, hint 颜色 --------------------------------------------------------------
  --- NOTE: 这里只是 diagnostic 部分的颜色显示, 不包括 buffer_num && buffer_name 颜色. eg: (1)
  error_diagnostic = {           -- hi BufferLineErrorDiagnostic
    ctermfg=Colors.red.c, fg=Colors.red.g,
    ctermbg=236, bg='#303030',
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
    ctermfg=Color.orange, fg=Color_gui.orange,
    ctermbg=236, bg='#303030',
    bold = true,
  },
  warning_diagnostic_visible = {
    ctermfg=Color.orange, fg=Color_gui.orange,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
  },
  warning_diagnostic_selected = {
    ctermfg=Color.orange, fg=Color_gui.orange,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
    italic = false,
  },
  info_diagnostic = {
    ctermfg=Colors.blue.c, fg=Colors.blue.g,
    ctermbg=236, bg='#303030',
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
    ctermbg=236, bg='#303030',
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

-- -- }}}

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
  else
    --- 如果有任意一个 window 符合要求 go_to() 要求. 则当前 window 不允许 go_to() 到别的 buffer.
    for _, wininfo in ipairs(vim.fn.getwininfo()) do
      if check_buftype_buflisted_filetype(wininfo.bufnr) then
        return false
      end
    end
  end

  --- 如果所有 window 都不符合要求. 则当前 window 允许 go_to() 到别的 buffer.
  return true
end
-- -- }}}

--- functions for delete buffer/tab ---------------------------------------------------------------- {{{
--- 用于 <leader>d 快捷键和 mouse actions 设置.

--- tab 是一组 win 的集合. `:tabclose` 本质是关闭 tab 中所有的 win. 并不 bdelete buffer.
--- 关闭整个 tab 以及其中的 buffer. 如果 tab 中的 buffer 同时存在于其他的 tab 中, 则不删除.
local function close_current_tab()
  local total_tab_num = vim.fn.tabpagenr('$')  --- 获取 tab 总数. 大于 1 说明有多个 tab.
  if total_tab_num < 2 then
    return false  -- 没有 tab 可以 close.
  end

  --- 获取当前 tab 中的所有 bufnr. return list.
  --- tabpagebuflist() 返回属于该 tab 的各个 win 正在显示的 buffer, NOTE: 包括 unlisted buffer.
  local cur_tab_buf_list = vim.fn.tabpagebuflist()

  --- 获取其他 tab 中的所有 buffer list.
  local current_tabnr = vim.fn.tabpagenr()
  local exclude_buffer_list = {}  --- buffers which also in other tabs
  for i = 1, total_tab_num, 1 do
    if i ~= current_tabnr then
      vim.list_extend(exclude_buffer_list, vim.fn.tabpagebuflist(i))
    end
  end

  --- 排除存在于其他 tab 中 buffer, 和 unsaved buffer.
  local del_nochanged_buf_list = {}
  for _, bufnr in ipairs(cur_tab_buf_list) do
    if not vim.tbl_contains(exclude_buffer_list, bufnr)  -- 排除存在于其他 tab 中 buffer.
      and vim.fn.getbufinfo(bufnr)[1].changed == 0  -- 排除 unsaved buffer.
      and vim.fn.buflisted(bufnr) == 1   -- 排除 unlisted buffer
    then
      table.insert(del_nochanged_buf_list, bufnr)
    end
  end

  vim.cmd('tabclose')

  --- `:tabclose` 关闭整个 tab
  --- `:bdelete 1 2 3` 删除 tab 中的所有 buffer
  if #del_nochanged_buf_list > 0 then
    --- tabclose 之后, 判断 buffer 是否存在.
    for _, bufnr in ipairs(del_nochanged_buf_list) do
      if vim.api.nvim_buf_is_valid(bufnr) and vim.fn.buflisted(bufnr) == 1 then
        vim.cmd('bdelete ' .. bufnr)
      end
    end
  end

  return true  -- 已经成功 close tab.
end

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
local function bufferline_del_current_buffer(ignore_tab)
  --- NOTE: multi tab 的情况下, 使用 :tabclose 关闭整个 tab, 同时 bdelete 该 tab 中的所有 buffer.
  if not ignore_tab and close_current_tab() then  -- return true: 有多个 tab, 并已关闭当前 tab.
    return
  end

  --- NOTE: 以下是 single tab 情况下删除 current buffer.
  local current_bufnr = vim.fn.bufnr()
  if current_bufnr < 1 then
    Notify("current bufnr < 1", "DEBUG")
    return
  end

  local current_bufinfo = vim.fn.getbufinfo(current_bufnr)[1]

  --- current buffer 修改后未保存.
  if current_bufinfo.changed == 1 then
    Notify("Cannot close Unsaved buffer", "WARN")
    return
  end

  --- current buffer 是 unlisted active buffer
  if current_bufinfo.listed == 0 then
    --- 如果有其他任何 window 中显示的是 listed buffer 则直接 :bdelete current buffer.
    for _, wininfo in ipairs(vim.fn.getwininfo()) do
      if vim.fn.buflisted(wininfo.bufnr) == 1 then
        vim.cmd('bdelete')
        return
      end
    end

    --- 如果所有 window 中的 buffer 都是 unlisted 则跳到 buffer #, '#' 表示 previous buffer.
    --- 如果 buffer # 也是 unlisted buffer, 则跳到最后一个 visible buffer.
    --- NOTE: 这里不再需要 ':bdelete #' 删除 current buffer, 因为 current buffer 本身就是 unlisted.
    local prev_bufnr = vim.fn.bufnr('#')
    if vim.fn.buflisted(prev_bufnr) == 1 then
      vim.api.nvim_set_current_buf(prev_bufnr)  -- ':buffer #'
    else
      bufferline.go_to(-1, true)  -- go_to(-1, true) 跳到最后一个 visible buffer
    end
    return
  end

  --- NOTE: 以下是 current_bufinfo.listed == 1 的情况.
  --- 如果 current buffer 是最后一个 listed buffer 则不删除.
  local listed_buffers = vim.fn.getbufinfo({buflisted=1})
  if #listed_buffers == 1 then
    --- listed_buffers 只剩一个, 而且 current_bufinfo.listed == 1,
    --- 说明 current buffer 一定是最后一个 listed buffer.
    Notify("Cannot close last listed-buffer", "WARN")
    return
  end

  --- 如果当前 buffer 是排在最后的 listed buffer 则跳到前一个 buffer;
  --- 如果当前 buffer 不是排在最后的 listed buffer 则跳到后一个 buffer;
  if is_last_bufferline_index(current_bufnr) then
    bufferline.cycle(-1)  -- 跳转到 prev buffer
  else
    bufferline.cycle(1)   -- 跳转到 next buffer
  end

  vim.cmd('bdelete #')
end

--- 删除指定 buffer
local function bufferline_del_buffer_by_bufnr(bufnr)
  --- 判断指定 bufnr 是否为仅剩的最后一个 listed buffer
  local listed_buffers = vim.fn.getbufinfo({buflisted=1})
  if #listed_buffers < 2 then
    Notify("Cannot close last listed-buffer", "WARN")
    return
  end

  if vim.fn.bufnr() == bufnr then
    --- NOTE: 删除的 buffer 是当前 buffer 时, 避免直接退出 nvim.
    bufferline_del_current_buffer('ignore_tab')
  else
    --- 如果关闭的不是当前 buffer, 则直接删除.
    vim.cmd('bdelete! ' .. bufnr)
  end
end

-- -- }}}

--- functions for left_mouse_command --------------------------------------------------------------- {{{
--- load 鼠标点击的 buffer
local function load_bufnr_on_left_click(bufnr)
  --- cursor 所在 window 中是 listed-buffer, 则允许加载指定 bufnr.
  if vim.fn.buflisted(vim.api.nvim_get_current_buf()) == 1 then
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
-- -- }}}

--- `:help bufferline-configuration`
bufferline.setup({
  --- 颜色设置
  highlights = buf_highlights,

  --- NOTE: id = bufnr; ordinal = bufferline_index
  options = {
    mode = "buffers", -- set to "tabs" to only show tabpages instead
    numbers = "ordinal", -- "none" | "ordinal" | "buffer_id" | "both" | func({ordinal,id,lower,raise}):string
    sort_by = 'id',  -- insert_after_current |insert_at_end | id | extension | relative_directory | directory | tabs | func(buf_a, buf_b)
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist between sessions.
                                -- 会创建一个全局变量 g:BufferlinePositions 保存自 state.custom_sort

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
      {filetype="NvimTree", text="File Explorer", text_align="center", highlight="Directory", separator=true},
      {filetype="tagbar", text="TagBar", text_align="center", highlight="Directory", separator=true},
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
    --   if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
    --     return true
    --   end
    --   --- filter out by it's index number in list (don't show first buffer)
    --   if buf_numbers[1] ~= buf_number then
    --     return true
    --   end
    -- end,
    -- -- }}}
  },
})

--- keymaps ----------------------------------------------------------------------------------------
local opt = { noremap = true, silent = true }
local bufferline_keymaps = {
  --- NOTE: according to bufferline source code, `go_to_buffer()` is deprecate. it calls `go_to()`
  --- https://github.com/akinsho/bufferline.nvim/blob/master/lua/bufferline.lua
  {'n', '<leader>1', function() if gotoable() then bufferline.go_to(1, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>2', function() if gotoable() then bufferline.go_to(2, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>3', function() if gotoable() then bufferline.go_to(3, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>4', function() if gotoable() then bufferline.go_to(4, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>5', function() if gotoable() then bufferline.go_to(5, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>6', function() if gotoable() then bufferline.go_to(6, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>7', function() if gotoable() then bufferline.go_to(7, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>8', function() if gotoable() then bufferline.go_to(8, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>9', function() if gotoable() then bufferline.go_to(9, true) end end, opt, 'which_key_ignore'},

  --- NOTE: 如果 cursor 所在的 window 中显示的(active) buffer 是 unlisted (即: 不显示在 tabline 上的 buffer),
  --- 不能使用 BufferLineCycleNext/Prev 来进行 buffer 切换, 但是可以使用 bufferline.go_to() 直接跳转.
  {'n', '-', function() bufferline.cycle(-1) end, opt, 'buffer: go to Prev buffer'},
  {'n', '=', function() bufferline.cycle(1)  end, opt, 'buffer: go to Next buffer'},

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

--- HACK: 被 bdelete / bwipeout 的 buffer 重新打开时, 分配到 bufferline list 的最后 ---------------- {{{
--- 原理: 在 buffer 被 bdelete / bwipeout 的时候修改 state.custom_sort = {bufnr ...},
--- 来改变 bufferline 的显示顺序.
--- 需要用到 state.components, 即 bufferline.exec(callback()) 中的 visible_buffers_info
--- 如果需要手动刷新 bufferline 显示, 需要使用 require("bufferline.ui").refresh()
local state_ok, state = pcall(require, "bufferline.state")
if not state_ok then
  Notify('cannot load "bufferline.state", state.custom_sort cannot be changed', "WARN")
  return
end

--- 获取 elem 在 list 中的 pos
local function table_index(list, elem)
  for index, value in ipairs(list) do
    if value == elem then
      return index
    end
  end
end

--- 获取当前 bufferline 中 custom_sort 排序
local function bufferline_custom_sort_order()
  local list = {}
  if state.custom_sort then
    --- 如果 custom_sort 存在, 说明 buffer 位置排序已经被改变过.
    --- VVI: 从 state.components 中获取位置顺序
    list = vim.tbl_map(function(item)
      return item.id
    end, state.components)
  else
    --- 如果 custom_sort 不存在, 说明 buffer 位置是按照 bufnr 排序的(buffer 打开的顺序)
    local listed_buffer = vim.fn.getbufinfo({buflisted=1})
    list = vim.tbl_map(function(item)
      return item.bufnr
    end, listed_buffer)
  end
  return list
end

--- BufDelete 触发条件: bdelete, bwipeout
vim.api.nvim_create_autocmd({"BufDelete", "BufWinEnter"}, {
  pattern = {"*"},
  callback = function(params)
    --- 获取 bufferline 中 custom_sort 排序
    local list = bufferline_custom_sort_order()

    --- 获取 bufnr 在 list 中的 index
    local buf_index = table_index(list, params.buf)

    --- VVI: 手动给 custom_sort 赋值, 排序.
    if params.event == "BufWinEnter" and not buf_index then
      table.insert(list, params.buf)
      state.custom_sort = list
    elseif params.event == "BufDelete" and buf_index then
      table.remove(list, buf_index)
      state.custom_sort = list
    end
  end,
  desc = "bufferline: sort bufnr manually",
})
-- -- }}}

--- DEBUG: 用, 查看 ordinal, bufnr/id, list_index, 之间的关系 -------------------------------------- {{{
-- function Bufferline_info(bufferline_index)
--   -- vim.print("state.components:", state.components)
--   vim.print("state.custom_sort (bufnrs order):", state.custom_sort)
--   if bufferline_index then
--     bufferline.exec(bufferline_index, function(index_info, visible_infos)
--       --- 如果 index 不存在, 则 callback function 不执行.
--       if index_info then
--         print("index:", bufferline_index, "ordinal:", index_info.ordinal, "; bufnr:", index_info.id, "; bufname:", index_info.path)
--       end
--     end)
--   else
--     bufferline.exec(1, function(index_info, visible_infos)
--       for i, value in ipairs(visible_infos) do
--         print("index:", i, "ordinal:", value.ordinal, "; bufnr:", value.id, "; bufname:", value.path)
--       end
--     end)
--   end
-- end
-- -- }}}


