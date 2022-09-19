local bufferline_status_ok, bufferline = pcall(require, "bufferline")
if not bufferline_status_ok then
  return
end

--- highlight 设置 --------------------------------------------------------------------------------- {{{
local colors = {
  --normal_fg = 188,  -- NOTE: colors.lua 设置中 highlight Normal ctermfg=188, 所有默认 fg 都是 188.
  fill_bg = 234,  -- fill 整个 bufferline banner 的背景色

  buf_fg = 246,        -- light_grey
  buf_bg = 236,        -- grey
  buf_sel_fg = 85,     -- light_green
  buf_sel_bg = 233,    -- black
  buf_vis_bg = 233,    -- black

  duplicate_fg = 243,  -- grey
  tab_sel_fg = 233,    -- black
  tab_sel_bg = 190,    -- yellow

  modified_fg = 81,    -- cyan
  separator_fg = 238,  -- grey
  indicator_fg = 81,   -- cyan

  error_fg = 167,      -- red
  warning_fg = 214,    -- orange
  info_fg = 75,        -- blue
  hint_fg = 246,       -- light_grey
}

--- 默认设置 `:help bufferline-highlights`
local buf_highlights = {
  --- fill 整个 bufferline banner 的背景色, NOTE: 如果需要透明, 则不要设置.
  --fill = { ctermbg = colors.fill_bg },  -- hi TabLineFill

  background = {  -- 默认设置, 其他设置缺省的时候使用该设置.
    ctermfg = colors.buf_fg,
    ctermbg = colors.buf_bg,
  },
  buffer_visible = {  -- cursor 在别的 window 时, buffer filename 颜色.
    ctermbg = colors.buf_vis_bg,
  },
  buffer_selected = {
    ctermfg = colors.buf_sel_fg,
    ctermbg = colors.buf_sel_bg,
    bold = true,
    italic = false,  -- 默认设置中是 buffer_selected.italic = true.
  },

  close_button = {
    ctermfg = colors.buf_fg,
    ctermbg = colors.buf_bg,
  },
  close_button_visible = {
    ctermfg = colors.buf_fg,
    ctermbg = colors.buf_vis_bg,
  },
  close_button_selected = {
    ctermfg = colors.buf_fg,
    ctermbg = colors.buf_sel_bg,
  },

  --- duplicate 默认是 italic.
  --- 这里是指相同文件名的 prefix 部分. eg: prefix1/abc.txt && prefix2/abc.txt
  duplicate = {
    ctermfg = colors.duplicate_fg,
    ctermbg = colors.buf_bg,
    italic = true,
  },
  duplicate_visible = {
    ctermfg = colors.duplicate_fg,
    ctermbg = colors.buf_vis_bg,
    italic = true,
  },
  duplicate_selected = {
    ctermfg = colors.duplicate_fg,
    ctermbg = colors.buf_sel_bg,
    italic = true,
  },

  --- NOTE: indicator - 当前正在显示的 buffer. ▎
  indicator_visible = {  -- background 颜色需要和 buffer_visible bg 相同
    ctermfg = colors.indicator_fg,
    ctermbg = colors.buf_vis_bg,
  },
  indicator_selected = {  -- background 颜色需要和 buffer_selected bg 相同
    ctermfg = colors.indicator_fg,
    ctermbg = colors.buf_sel_bg,
  },

  --- NOTE: separator 是 buffer 之间的间隔符, separator_selected 是 tab 之间的间隔符
  tab_selected = {  -- 右上角 tab 颜色
    ctermfg = colors.tab_sel_fg,
    ctermbg = colors.tab_sel_bg,
  },
  tab_separator = {  -- tab 之间分隔线 | 的颜色.
    ctermfg = colors.duplicate_fg,
    -- ctermbg = colors.tab_sel_bg,
  },
  tab_separator_selected = {  -- selected tab 后面一个分隔线 | 的颜色.
    ctermfg = colors.tab_sel_bg,
    ctermbg = colors.tab_sel_bg,
  },

  -- separator = {  -- buffer 之间分隔线 | 颜色, NOTE: 目前设置是 ' ' 空格, 所以 fg 不起作用, 只有 bg 起作用.
  --   ctermfg = colors.separator_fg,
  --   ctermbg = colors.tab_sel_bg,
  -- },
  -- separator_selected = {  -- NOTE: 好像没有任何作用
  --   ctermfg = colors.tab_sel_bg,
  --   ctermbg = colors.tab_sel_bg,
  -- },

  --- ONLY modified_icon color. ●
  modified = {
    ctermfg = colors.modified_fg,
    ctermbg = colors.buf_bg,
  },
  modified_visible = {
    ctermfg = colors.modified_fg,
    ctermbg = colors.buf_vis_bg,
  },
  modified_selected = {
    ctermfg = colors.modified_fg,
    ctermbg = colors.buf_sel_bg,
  },

  --- error, warning, info, hint 颜色设置.
  --- NOTE: 这里只是 diagnostic 部分的颜色显示, 不包括 buffer_num && buffer_name 颜色. eg: (1)
  error_diagnostic = {           -- hi BufferLineErrorDiagnostic
    ctermfg = colors.error_fg,
    ctermbg = colors.buf_bg,
    bold = true,
  },
  error_diagnostic_visible = {   -- hi BufferLineErrorDiagnosticVisible
    ctermfg = colors.error_fg,
    ctermbg = colors.buf_vis_bg,
    bold = true,
  },
  error_diagnostic_selected = {  -- hi BufferLineErrorDiagnosticSelected
    ctermfg = colors.error_fg,
    ctermbg = colors.buf_sel_bg,
    bold = true,
    italic = false,
  },
  warning_diagnostic = {
    ctermfg = colors.warning_fg,
    ctermbg = colors.buf_bg,
    bold = true,
  },
  warning_diagnostic_visible = {
    ctermfg = colors.warning_fg,
    ctermbg = colors.buf_vis_bg,
    bold = true,
  },
  warning_diagnostic_selected = {
    ctermfg = colors.warning_fg,
    ctermbg = colors.buf_sel_bg,
    bold = true,
    italic = false,
  },
  info_diagnostic = {
    ctermfg = colors.info_fg,
    ctermbg = colors.buf_bg,
    bold = true,
  },
  info_diagnostic_visible = {
    ctermfg = colors.info_fg,
    ctermbg = colors.buf_vis_bg,
    bold = true,
  },
  info_diagnostic_selected = {
    ctermfg = colors.info_fg,
    ctermbg = colors.buf_sel_bg,
    bold = true,
    italic = false,
  },
  hint_diagnostic = {
    ctermfg = colors.hint_fg,
    ctermbg = colors.buf_bg,
    bold = true,
  },
  hint_diagnostic_visible = {
    ctermfg = colors.hint_fg,
    ctermbg = colors.buf_vis_bg,
    bold = true,
  },
  hint_diagnostic_selected = {
    ctermfg = colors.hint_fg,
    ctermbg = colors.buf_sel_bg,
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

--- functions for delete buffer/tab ---------------------------------------------------------------- {{{
--- 用于 <leader>d 快捷键和 mouse actions 设置.
--- 是否可以 go_to() 到别的 buffer.
local function gotoable()
  --- 自定义: 不允许使用 bufferline.go_to() 的 filetype
  local exclude_filetypes = {
    'help', 'qf',  --- 'quickfix' && 'location-list' 的 filetype 都是 'qf'.
    'vimfiler', 'nerdtree', 'tagbar', 'NvimTree',
    'toggleterm', 'myterm',
  }

  --- `:help 'buftype'`, exclude buftype: nofile, terminal, quickfix, prompt, help ...
  if vim.bo.buftype ~= '' or vim.tbl_contains(exclude_filetypes, vim.bo.filetype) then
    --- 如果有其他任何 window 中显示的是 listed buffer 则 current win 不能 go_to() 到别的 buffer.
    for _, wininfo in ipairs(vim.fn.getwininfo()) do
      if vim.fn.buflisted(wininfo.bufnr) == 1 then
        return false
      end
    end
  end

  --- 如果所有 window 都显示的是 unlisted buffer, 则 current win 可以 go_to() 别的 buffer.
  --- 如果 buftype == '' 或者 filetype 不是 exclude_filetypes, 则 current win 可以 go_to() 别的 buffer.
  return true
end

--- tab 是一组 win 的集合. `:tabclose` 本质是关闭 tab 中所有的 win. 并不 bdelete buffer.
--- 关闭整个 tab 以及其中的 buffer. 如果 tab 中的 buffer 同时存在于其他的 tab 中, 则不删除.
local function close_current_tab()
  local total_tab_num = vim.fn.tabpagenr('$')  --- 获取 tab 总数. 大于 1 说明有多个 tab.
  if total_tab_num < 2 then
    return false  -- 没有 tab 可以 close.
  end

  --- 获取当前 tab 中的所有 bufnr. return list.
  --- 这里返回的 buffer list 是属于该 tab 的各个 win 正在显示的 buffer.
  local cur_tab_buf_list = vim.fn.tabpagebuflist()

  --- 获取其他 tab 中的所有 buffer list.
  local current_tabnr = vim.fn.tabpagenr()
  local exclude_buffer_list = {}  --- buffers which also in other tabs
  for i = 1, total_tab_num, 1 do
    if i ~= current_tabnr then
      vim.list_extend(exclude_buffer_list, vim.fn.tabpagebuflist(i))
    end
  end

  --- 排除同时存在于其他 tab 中 buffer.
  local del_buffer_list = {}
  for _, bufnr in ipairs(cur_tab_buf_list) do
    if not vim.tbl_contains(exclude_buffer_list, bufnr) then
      table.insert(del_buffer_list, bufnr)
    end
  end

  --- 排除未保存的 buffers (changed/modified)
  --local modified_buffer = vim.fn.getbufinfo({bufmodified=1})
  local del_nochanged_buf_list = {}
  for _, bufnr in ipairs(del_buffer_list) do
    if vim.fn.getbufinfo(bufnr)[1].changed == 0 then
      table.insert(del_nochanged_buf_list, bufnr)
    end
  end

  --- `:tabclose` 关闭整个 tab
  --- `:bdelete 1 2 3` 删除 tab 中的所有 buffer
  if #del_nochanged_buf_list > 0 then
    vim.cmd([[ tabclose | bdelete ]] .. table.concat(del_nochanged_buf_list, ' '))
  else
    vim.cmd([[ tabclose ]])
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
  --- 不删除 nvim-tree
  if vim.bo.filetype == 'NvimTree' then
    return
  end

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
    Notify("can't close Unsaved buffer", "WARN")
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

    --- 如果所有 window 中的 buffer 都是 unlisted 则跳到 buffer #,
    --- 如果 buffer # 也是 unlisted buffer, 则跳到最后一个 visible buffer.
    --- NOTE: 这里不再需要 ':bdelete #' 删除 current buffer, 因为 current buffer 本身就是 unlisted.
    if vim.fn.buflisted(vim.fn.bufnr('#')) == 1 then
      vim.cmd('buffer #')
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
    Notify("can't close the Only listed-buffer", "WARN")
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
    Notify("can't close the Only listed-buffer", "WARN")
    return
  end

  if vim.fn.bufnr() == bufnr then
    --- NOTE: 删除的 buffer 是当前 buffer 时, 避免直接退出 nvim.
    bufferline_del_current_buffer(true)
  else
    --- 如果关闭的不是当前 buffer, 则直接删除.
    vim.cmd('bdelete! ' .. bufnr)
  end
end

-- -- }}}

--- functions for left_mouse_command --------------------------------------------------------------- {{{
--- load 鼠标点击的 buffer
local function load_bufnr_on_left_click(bufnr)
  --- 如果当前 window 中是一个 unlisted-buffer 则 return.
  if vim.fn.getbufinfo('%')[1].listed == 0 then
    Notify("can't load buffer {" .. bufnr .. "} in this window (unlisted-buffer)", "WARN")
    return
  end

  vim.cmd(bufnr..'buffer')  -- load 指定 buffer
end
-- -- }}}

--- `:help bufferline-configuration`
--- https://github.com/akinsho/bufferline.nvim#configuration
bufferline.setup({
  --- 颜色设置
  highlights = buf_highlights,

  options = {
    mode = "buffers", -- set to "tabs" to only show tabpages instead
    numbers = "ordinal", -- "none" | "ordinal" | "buffer_id" | "both" | func({ordinal,id,lower,raise}):string
    sort_by = 'id',  -- 其他选项有 BUG.
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist between sessions.
                                -- 会创建一个全局变量 g:BufferlinePositions 保存自 state.custom_sort

    always_show_bufferline = true, -- VVI: 一直显示 bufferline
    show_tab_indicators = true, -- 多个 tab 时在右上角显示 1 | 2 | ...

    --- icon 显示
    color_icons = false, -- whether or not to add the filetype icon highlights
    show_buffer_icons = false, -- disable filetype icons for buffers
    show_buffer_default_icon = false, -- whether or not an unrecognised filetype should show a default icon
    show_close_icon = false,  -- tab close icon. 无法自定义 tab close command, 所以不使用.
    show_buffer_close_icons = true, -- buffer close icon

    --- NOTE: this plugin is designed with this icon in mind,
    --- and so changing this is NOT recommended, this is intended
    --- as an escape hatch for people who cannot bear it for whatever reason
    indicator = {
      style = 'icon',  -- 'icon' | 'underline' | 'none',
      icon = '▎',  --  █ ▎▌, style = 'icon' 时生效.
    },
    buffer_close_icon = '✕',  -- 每个 buffer 后面显示 close icon.
    modified_icon = '●',
    close_icon = '✕',  -- close tab
    left_trunc_marker = '',
    right_trunc_marker = '',
    separator_style = {' ', ' '},  -- 'thin', 'thick', {'',''} - [focused and unfocused]

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
      -- {filetype="tagbar", text="TagBar", text_align="center", highlight="Directory", separator=true},
    },

    --- NOTE: this will be called a lot so don't do any heavy processing here --- {{{
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
  {'n', '<lt>', function() bufferline.cycle(-1) end, opt, 'buffer: go to Prev buffer'},  --- <lt>, less than, 代表 '<'
  {'n', '>', function() bufferline.cycle(1) end, opt, 'buffer: go to Next buffer'},

  --- 左右移动 buffer
  {'n', '<leader><Left>', '<cmd>BufferLineMovePrev<CR>', opt, 'buffer: Move Buffer Left'},
  {'n', '<leader><Right>', '<cmd>BufferLineMoveNext<CR>', opt, 'buffer: Move Buffer Right'},

  --- 关闭 buffer
  --- bufnr("#") > 0 表示 '#' (previous buffer) 存在, 如果不存在则 bufnr('#') = -1.
  --- 如果 # 存在, 但处于 unlisted 状态, 则 bdelete # 报错. 因为 `:bdelete` 本质就是 unlist buffer.
  {'n', '<leader>d', bufferline_del_current_buffer, opt, 'buffer: Close Current Buffer/Tab'},
  {'n', '<leader>D<Right>', '<cmd>BufferLineCloseRight<CR>', opt, 'buffer: Close Right Side Buffers'},
  {'n', '<leader>D<Left>', '<cmd>BufferLineCloseLeft<CR>', opt, 'buffer: Close Left Side Buffers'},
}

Keymap_set_and_register(bufferline_keymaps)

--- HACK: 被 bdelete / bwipeout 的 buffer 重新打开时, 分配到 bufferline list 的最后 ----------------
--- 原理: 在 buffer 被 bdelete / bwipeout 的时候修改 state.custom_sort = {bufnr ...},
--- 来改变 bufferline 的显示顺序.
--- 需要用到 state.components, 即 bufferline.exec(callback()) 中的 visible_buffers_info
--- 如果需要自动刷新 bufferline 显示, 需要使用 require("bufferline.ui").refresh()
local state = require("bufferline.state")

local function table_index(list, elem)
  for index, value in ipairs(list) do
    if value == elem then
      return index
    end
  end
end

local function remove_bufnr_from_custom_sort(bufnr)
  local list = {}

  if state.custom_sort then
    --- 如果 custom_sort 存在, 说明 buffer 位置排序已经被改变过.
    --- 从 state.components 中获取位置顺序
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

  --- 从 list 中移除被删除的 bufnr
  table.remove(list, table_index(list, bufnr))

  --- 手动改变 sort 顺序, 下次 bufferline 刷新的时候会根据该顺序显示.
  state.custom_sort = list
  -- print(vim.inspect(state.custom_sort))
end

--- BufDelete 触发条件: bdelete, bwipeout
vim.api.nvim_create_autocmd("BufDelete", {
  pattern = {"*"},
  callback = function(params)
    remove_bufnr_from_custom_sort(params.buf)
  end
})

--- DEBUG: 用
function Bufferline_info(index)
  -- print("state.components:", vim.inspect(state.components))
  print("state.custom_sort (bufnrs order):", vim.inspect(state.custom_sort))
  if index then
    bufferline.exec(index, function (index_info, vis_infos)
      if index then
        print("ordinal:", index_info.ordinal, "; bufnr:", index_info.id, "; bufname:", index_info.path)
      end
    end)
  else
    bufferline.exec(1, function (i, vis_infos)
      for i, value in ipairs(vis_infos) do
        print("index:", i, "ordinal:", value.ordinal, "; bufnr:", value.id, "; bufname:", value.path)
      end
    end)
  end
end



