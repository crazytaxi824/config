local g = require('myplugins.winbarline.global')
local u = require('myplugins.winbarline.utils')
local wb_fmt_item = require('myplugins.winbarline.winbar_formatter_item')


---@class WinbarFormatter
---@field items WinbarFormatterItem[]
---@field tabnr integer
local WinbarFormatter = {}

--- 返回 modified buffer name
---@return string
local function bufname_mod(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname ~= '' then
    return bufname
  end

  --- 特殊情况
  --- command line window 中不能加载任何其他 buffer. `q:`, `q/`, `q?` ...
  if vim.fn.getcmdwintype() ~= '' then
    return "[Command Line]"
  end

  --- NOTE: buftype = 'terminal' 是锁死的, 无法被手动设置
  local bt = vim.bo[bufnr].buftype
  if bt == "quickfix" then
    return "[List]"
  elseif bt == "nofile" then
    --- return filetype
    local ft = vim.bo[bufnr].filetype
    return ft ~= '' and '['..ft..']' or "[Scratch]"
  elseif bt == "terminal" then
    return "[Terminal]"
  elseif bt == "prompt" then
    return "[Prompt]"
  elseif bt == "help" then
    return "[Help]"
  else
    return "[No Name]"  -- buftype == ''
  end
end

--- 如果有相同的 base name 则向上寻找直至 dir name 不同
---
---@param bufnrs integer[]
---@return string[][] fp_list
local function unique_bufnames(bufnrs)
  local bufnames = {}  ---@type string[]
  for _, bufnr in ipairs(bufnrs) do
    table.insert(bufnames, bufname_mod(bufnr))
  end

  return u.unique_short_paths(bufnames)
end

--- 将 items 转成 ordered components
---
---@param fmt_items WinbarFormatterItem[]
---@param level WinbarFormatterLevel
---@return WinbarFormatterItemComponent[][]
---@return integer total_width
local function fmt_items_to_components(fmt_items, level)
  ---@type WinbarFormatterItemComponent[][]
  local all_components = {}
  local total_width = 0

  for _, item in ipairs(fmt_items) do
    local comps, item_width = item:parse_item_to_components(level)
    total_width = total_width + item_width
    table.insert(all_components, comps)
  end

  return all_components, total_width
end


--- 返回当前 tabpage info
---@return WinbarFormatterItemComponent|nil
local function tabpage_component()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    local tab_str = string.format(' %d/%d ', vim.fn.tabpagenr(), #tabs)
    ---@type WinbarFormatterItemComponent
    local tab_comp = { content = tab_str, hl = '%=%#MyWinBarLineTab#' }
    return tab_comp
  end
end


--- format all items' components to winbar string
---
---@param fmt_comps_list WinbarFormatterItemComponent[][]
---@return string winbar_str
local function format_winbar_components(fmt_comps_list)
  local str_list = {}
  for _, comps in ipairs(fmt_comps_list) do
    local str = ''
    for _, comp in ipairs(comps) do
      str = str .. comp.hl .. comp.content:gsub('%%', '%%%%')
    end
    str = str .. '%*'  -- '%*' reset highligh
    table.insert(str_list, str)
  end

  --- concat 所有 buffer 的 winbar format
  return table.concat(str_list, ' ')
end


---@param fmt_items WinbarFormatterItem[]
---@param win_width integer
---@param active_buf_idx integer
---@param min_level WinbarFormatterLevel
---@return WinbarFormatterItemComponent[][]
local function reduce_items_to_display(fmt_items, win_width, active_buf_idx, min_level)
  ---@type WinbarFormatterItemComponent[][]
  local components = {}

  local p_item_idx  -- 需要计算 partial item 的 index
  local comp_width = 0

  --- 优先填充左侧
  for i = active_buf_idx, 1, -1 do
    local comp, i_width = fmt_items[i]:parse_item_to_components(min_level)
    comp_width = comp_width + i_width

    --- 'win_width - 4' 是为了给 '<', '>' 留出位置
    if comp_width > win_width - 4 then
      comp_width = comp_width - i_width  -- 还原 width
      p_item_idx = i
      break
    end

    table.insert(components, 1, comp)
  end

  --- 填充右侧
  if not p_item_idx then
    for i = active_buf_idx+1, #fmt_items, 1 do
      local comp, i_width = fmt_items[i]:parse_item_to_components(min_level)
      comp_width = comp_width + i_width

      --- 'win_width - 4' 是为了给 '<', '>' 留出位置
      if comp_width > win_width - 4 then
        comp_width = comp_width - i_width  -- 还原 width
        p_item_idx = i
        break
      end

      table.insert(components, comp)
    end
  end

  if not p_item_idx then
    error("winbarline: window width is enough, should not need to use reduce_items_to_display()")
  end

  --- 追加左右 '<', '>' 显示
  local remain_width = win_width - comp_width
  if p_item_idx < active_buf_idx then
    --- 左侧 item 需要 partial suffix, 并添加 '<'
    remain_width = remain_width - 2
    table.insert(components, 1, {{ content='<', hl='%*' }})

    if active_buf_idx < #fmt_items then
      --- active buffer 不是最后一个 buffer, 右侧也需要添加 '>'
      remain_width = remain_width - 2
      table.insert(components, {{ content='>', hl='%*' }})
    end

    --- components 插入在第二个位置
    table.insert(components, 2, fmt_items[p_item_idx]:partial(remain_width, min_level, 'suffix'))
  elseif p_item_idx == active_buf_idx then
    --- active buffer 已经超过 window width 了, 只能显示一个 buffer, 即 active buffer
    local insert_pos = 1  -- item 需要根据情况插入在第 1 | 2 的位置

    if active_buf_idx > 1 then
      --- active buffer 不是第一个 buffer, 则左侧需要添加 '<'
      insert_pos = 2  -- item 需要插入在第 2 的位置上
      remain_width = remain_width - 2
      table.insert(components, 1, {{ content='<', hl='%*' }})
    end

    if active_buf_idx < #fmt_items then
      --- active buffer 不是最后一个 buffer, 则右侧需要添加 '>'
      remain_width = remain_width - 2
      table.insert(components, {{ content='>', hl='%*' }})
    end

    --- components 插入在中间
    table.insert(components, insert_pos, fmt_items[p_item_idx]:partial(remain_width, min_level, 'prefix'))
  else
    --- 只有右侧需要添加 '>'
    remain_width = remain_width - 2
    table.insert(components, fmt_items[p_item_idx]:partial(remain_width, min_level, 'prefix'))
    table.insert(components, {{ content='>', hl='%*' }})
  end

  return components
end


---@param fmt_items WinbarFormatterItem[]
---@param win_width integer
---@param active_buf_idx integer
---@param min_level WinbarFormatterLevel
---@return string winbar_str
local function format_winbar_items(fmt_items, win_width, active_buf_idx, min_level)
  ---@type WinbarFormatterItemComponent[][]
  local components = {}

  local tab_comp = tabpage_component()
  if tab_comp then
    --- '-1': table.concat(components, ' ') 前的 n 个空格
    win_width = win_width - vim.fn.strdisplaywidth(tab_comp.content) - 1
  end

  --- 兜底效果
  if win_width <= 4 then
    components = {{{ content = '<...', hl='' }}}
  else
    for level = 5, min_level, -1 do
      local comps, comps_width = fmt_items_to_components(fmt_items, level)
      if comps_width < win_width then
        components = comps
        break
      end
    end

    --- window width 不够, 只显示部分 items
    if vim.tbl_isempty(components) then
      components = reduce_items_to_display(fmt_items, win_width, active_buf_idx, min_level)
    end
  end

  --- 添加 tabpagenr component
  if tab_comp then
    table.insert(components, { tab_comp })
  end

  return format_winbar_components(components)
end


--- 获取 window 中的所有 buffer, format 成适合的 winbar string
---
---@param win_id integer
---@return string|nil winbar_str
function WinbarFormatter.winbar_format(win_id)
  local w = g.get_win(win_id)
  if not w then
    vim.notify(string.format("win(%d) is not cached in WinBarLine", win_id), vim.log.levels.ERROR)
    return
  end

  local bufnrs = w:list_bufs()
  if #bufnrs <= 0 then
    return
  end

  local uni_bufnames = unique_bufnames(bufnrs)

  ---@type WinbarFormatterItem[]
  local fmt_items = {}
  local active_buf_idx

  for i, path_list in ipairs(uni_bufnames) do
    local bufnr = bufnrs[i]
    local b = g.get_buf(bufnr)
    if not b then
      vim.notify(string.format('buffer: %d is not cached', bufnr), vim.log.levels.ERROR)
      return
    end

    local fmt_item = wb_fmt_item.new(win_id, bufnr, i, path_list, b:diagnostic())
    if fmt_item.active then
      active_buf_idx = i
    end

    table.insert(fmt_items, fmt_item)
  end

  --- no item display in window 或者 win 中没有 active buffer
  --- NOTE: `:h help` 时出现该问题
  if vim.tbl_isempty(fmt_items) or not active_buf_idx then
    return
  end

  local min_level = 2
  return format_winbar_items(fmt_items, w.width, active_buf_idx, min_level)
end


return WinbarFormatter
