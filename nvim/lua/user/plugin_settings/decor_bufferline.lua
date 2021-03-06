local bufferline_status_ok, bufferline = pcall(require, "bufferline")
if not bufferline_status_ok then
  return
end

--- highlight 设置 --------------------------------------------------------------------------------- {{{
local colors = {
  --normal_fg = 188,  -- NOTE: colors.lua 设置中 highlight Normal ctermfg=188, 所有默认 fg 都是 188.
  fill_bg = 234,  -- fill 整个 bufferline banner 的背景色

  buf_fg = 246,
  buf_bg = 236,
  buf_sel_fg = 85,
  buf_sel_bg = 233,
  buf_vis_bg = 233,
  buf_style = "bold",

  duplicate_fg = 243,
  tab_sel_fg = 233,
  tab_sel_bg = 190,

  modified_fg = 81,
  separator_fg = 238,
  indicator_fg = 81,

  diag_style = "bold",
  error_fg = 167,
  warning_fg = 215,
  info_fg = 75,
  hint_fg = 246,
}

local buf_highlights = {
  fill = { ctermbg = colors.fill_bg },  -- fill 整个 bufferline banner 的背景色

  background = {  -- 每个 buffer 的颜色
    ctermfg = colors.buf_fg,
    ctermbg = colors.buf_bg,
  },
  buffer_visible = {  -- unfocused window
    ctermbg = colors.buf_vis_bg,
  },
  buffer_selected = {
    ctermfg = colors.buf_sel_fg,
    ctermbg = colors.buf_sel_bg,
    gui = colors.buf_style,
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

  --- duplicate 默认是 italic
  duplicate = {
    ctermfg = colors.duplicate_fg,
    ctermbg = colors.buf_bg,
  },
  duplicate_visible = {
    ctermfg = colors.duplicate_fg,
    ctermbg = colors.buf_vis_bg,
  },
  duplicate_selected = {  -- 需要和 buffer_selected 相同
    ctermfg = colors.duplicate_fg,
    ctermbg = colors.buf_sel_bg,
  },

  --- NOTE: indicator 不显示, 通过 XXX_selected bg 显示.
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
  separator_selected = {  -- tab 之间的间隔颜色, 和 tab_selected 颜色一样
    ctermfg = colors.tab_sel_bg,
    ctermbg = colors.tab_sel_bg,
  },
  separator = {  -- buffer & tab 之间的间隔颜色
    ctermfg = colors.separator_fg,
    --ctermbg = bufline_hi.buf_bg,  -- NOTE: 如果需要显示 separator 使用 buffer bg 颜色.
  },

  --- ONLY modified_icon color
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
  error_diagnostic = {
    ctermfg = colors.error_fg,
    ctermbg = colors.buf_bg,
    gui = colors.diag_style,
  },
  error_diagnostic_visible = {
    ctermfg = colors.error_fg,
    ctermbg = colors.buf_vis_bg,
    gui = colors.diag_style,
  },
  error_diagnostic_selected = {
    ctermfg = colors.error_fg,
    ctermbg = colors.buf_sel_bg,
    gui = colors.diag_style,
  },
  warning_diagnostic = {
    ctermfg = colors.warning_fg,
    ctermbg = colors.buf_bg,
    gui = colors.diag_style,
  },
  warning_diagnostic_visible = {
    ctermfg = colors.warning_fg,
    ctermbg = colors.buf_vis_bg,
    gui = colors.diag_style,
  },
  warning_diagnostic_selected = {
    ctermfg = colors.warning_fg,
    ctermbg = colors.buf_sel_bg,
    gui = colors.diag_style,
  },
  info_diagnostic = {
    ctermfg = colors.info_fg,
    ctermbg = colors.buf_bg,
    gui = colors.diag_style,
  },
  info_diagnostic_visible = {
    ctermfg = colors.info_fg,
    ctermbg = colors.buf_vis_bg,
    gui = colors.diag_style,
  },
  info_diagnostic_selected = {
    ctermfg = colors.info_fg,
    ctermbg = colors.buf_sel_bg,
    gui = colors.diag_style,
  },
  hint_diagnostic = {
    ctermfg = colors.hint_fg,
    ctermbg = colors.buf_bg,
    gui = colors.diag_style,
  },
  hint_diagnostic_visible = {
    ctermfg = colors.hint_fg,
    ctermbg = colors.buf_vis_bg,
    gui = colors.diag_style,
  },
  hint_diagnostic_selected = {
    ctermfg = colors.hint_fg,
    ctermbg = colors.buf_sel_bg,
    gui = colors.diag_style,
  },
}

--- numbers 和 buffer 颜色相同
buf_highlights.numbers = buf_highlights.background
buf_highlights.numbers_visible = buf_highlights.buffer_visible
buf_highlights.numbers_selected = buf_highlights.buffer_selected

--- error, warning, info, hint 和 buffer 颜色相同
buf_highlights.error = buf_highlights.background
buf_highlights.error_visible = buf_highlights.buffer_visible
buf_highlights.error_selected = buf_highlights.buffer_selected
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

--- functions for delete current buffer from tabline ----------------------------------------------- {{{
--- 用于 <leader>d 快捷键和 mouse actions 设置.
--- NOTE: 指定 filetype 不能使用 go_to() 功能.
local function buf_jumpable()
  --- 不能使用 bufferline.go_to() 的 filetype
  local exclude_filetype = {'vimfiler', 'nerdtree', 'tagbar', 'NvimTree', 'toggleterm', 'myterm'}

  if vim.tbl_contains(exclude_filetype, vim.bo.filetype) then
    return false
  end

  return true
end

--- NOTE: tab 是一组 win 的集合. `:tabclose` 本质是关闭 tab 中所有的 win. 并不 bdelete buffer.
--- 关闭整个 tab 以及其中的 buffer.
local function close_current_tab()
  local total_tab_num = vim.fn.tabpagenr('$')  --- 获取 tab 总数. 大于 1 说明有多个 tab.
  if total_tab_num < 2 then
    return false  -- 没有 tab 可以 close.
  end

  --- 获取当前 tab 中的所有 bufnr. return list.
  --- NOTE: 这里返回的 buffer list 是属于该 tab 的各个 win 正在显示的 buffer.
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
    vim.cmd([[ tabclose | bdelete ]] .. vim.fn.join(del_nochanged_buf_list, ' '))
  else
    vim.cmd([[ tabclose ]])
  end

  return true  -- 已经成功 close tab.
end

--- 删除当前 buffer, NOTE: if ignore_tab == true, DO NOT run close_current_tab()
local function bufferline_del_current_buffer(ignore_tab)
  --- NOTE: multi tab 的情况下, 使用 :tabclose 关闭整个 tab, 同时 bdelete 该 tab 中的所有 buffer.
  if not ignore_tab and close_current_tab() then  -- return true: 有多个 tab, 并已关闭当前 tab.
    return
  end

  --- 如果当前 buffer 不允许 jump 到别的 buffer 则直接返回.
  if not buf_jumpable() then
    return
  end

  --- NOTE: single tab 情况下删除 current buffer.
  local before_select_bufnr = vim.fn.bufnr('%')  --- 获取当前 bufnr()
  --- 判断当前 buffer 是否未保存.
  if vim.fn.getbufinfo(before_select_bufnr)[1].changed == 1 then
    Notify("can't close Unsaved buffer", "WARN")
    return
  end

  bufferline.cycle(-1)  -- 跳转到 prev buffer
  local after_select_bufnr = vim.fn.bufnr('%')   --- 获取跳转后 bufnr()

  if before_select_bufnr ~= after_select_bufnr then
    --- 如果 before != after 则执行 bdelete #.
    vim.cmd([[bdelete #]])
  else
    --- 如果 before == after 则说明是最后一个 listed buffer, 或者当前 buffer 是 unlisted active buffer.
    bufferline.go_to(-1, true)   --- NOTE: go_to(-1, true) 跳到最后一个 buffer.
  end
end

--- 删除指定 buffer
local function bufferline_del_buffer_by_bufnr(bufnr)
  --- 判断指定 bufnr 是否是 last listed buffer
  local listed_buffers = vim.fn.getbufinfo({buflisted=1})
  if #listed_buffers < 2 then
    Notify("can't close last listed-buffer", "WARN")
    return
  end

  --- NOTE: 删除的 buffer 是当前 buffer 时, 避免直接退出 nvim.
  if vim.fn.bufnr() == bufnr then
    bufferline_del_current_buffer(true)
  else
    vim.cmd('bdelete! ' .. bufnr)
  end
end

-- -- }}}

--- https://github.com/akinsho/bufferline.nvim#configuration
bufferline.setup({
  options = {
    mode = "buffers", -- set to "tabs" to only show tabpages instead
    numbers = "ordinal", -- "none" | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
    always_show_bufferline = true, -- VVI: 一直显示 bufferline

    --- icon 显示
    color_icons = false, -- whether or not to add the filetype icon highlights
    show_buffer_icons = false, -- disable filetype icons for buffers
    show_buffer_default_icon = false, -- whether or not an unrecognised filetype should show a default icon
    show_close_icon = false,  -- tab close icon
    show_buffer_close_icons = true, -- buffer close icon

    --- NOTE: this plugin is designed with this icon in mind,
    --- and so changing this is NOT recommended, this is intended
    --- as an escape hatch for people who cannot bear it for whatever reason
    indicator_icon = '▎',  --  █ ▎▌, NOTE: 这里不设置任何值, 只是站位作用.
    buffer_close_icon = '✕',  -- 每个 buffer 后面显示 close icon.
    modified_icon = '●',
    close_icon = '✕',  -- close tab
    left_trunc_marker = '',
    right_trunc_marker = '',

    --- mouse actions, can be a string | function, see "Mouse actions"
    --- NOTE: 这里 %d 是 bufnr() 的 placeholder. 可以使用 function(bufnr) 来设置.
    close_command = bufferline_del_buffer_by_bufnr,     -- delete 指定 bufnr, 默认 "bdelete! %d"
    --left_mouse_command = "buffer %d",  -- jump to buffer bufnr
    right_mouse_command = "",            -- 取消默认值, 默认 "bdelete! %d"
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

    --- NOTE: this will be called a lot so don't do any heavy processing here
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

    --- 在 nvim-tree 上显示 "File Explorer"
    offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "center", highlight="Directory"}},

    show_tab_indicators = true, -- 多个 tab 时在右上角显示 1 | 2 | ...
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist

    separator_style = {' ', ' '},  -- thin thick, {'',''}, -- [focused and unfocused]
    sort_by = 'id',
  },

  --- 颜色设置
  highlights = buf_highlights,
})

--- keymaps ----------------------------------------------------------------------------------------
local opt = { noremap = true, silent = true }
local bufferline_keymaps = {
  --- NOTE: according to bufferline source code, `go_to_buffer()` is deprecate. it calls `go_to()`
  --- https://github.com/akinsho/bufferline.nvim/ -> /lua/bufferline.lua
  {'n', '<leader>1', function() if buf_jumpable() then bufferline.go_to(1, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>2', function() if buf_jumpable() then bufferline.go_to(2, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>3', function() if buf_jumpable() then bufferline.go_to(3, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>4', function() if buf_jumpable() then bufferline.go_to(4, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>5', function() if buf_jumpable() then bufferline.go_to(5, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>6', function() if buf_jumpable() then bufferline.go_to(6, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>7', function() if buf_jumpable() then bufferline.go_to(7, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>8', function() if buf_jumpable() then bufferline.go_to(8, true) end end, opt, 'which_key_ignore'},
  {'n', '<leader>9', function() if buf_jumpable() then bufferline.go_to(9, true) end end, opt, 'which_key_ignore'},

  --- NOTE: 如果 cursor 所在的 window 中显示的(active) buffer 是 unlisted (即: 不显示在 tabline 上的 buffer),
  --- 不能使用 BufferLineCycleNext/Prev 来进行 buffer 切换, 但是可以使用 bufferline.go_to() 直接跳转.
  {'n', '<lt>', function() bufferline.cycle(-1) end, opt},  --- <lt>, less than, 代表 '<'. 也可以使用 '\<'
  {'n', '>', function() bufferline.cycle(1) end, opt},

  --- 关闭 buffer
  --- bufnr("#") > 0 表示 '#' (previous buffer) 存在, 如果不存在则 bufnr('#') = -1.
  --- 如果 # 存在, 但处于 unlisted 状态, 则 bdelete # 报错. 因为 `:bdelete` 本质就是 unlist buffer.
  {'n', '<leader>d', bufferline_del_current_buffer, opt, 'Close This Buffer'},
}

Keymap_set_and_register(bufferline_keymaps)



