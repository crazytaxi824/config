local g = require('utils.winbarline.global')
local u = require('utils.winbarline.utils')
local wb_fmt_item = require('utils.winbarline.winbar_formatter_item')


--- @class WinbarFormatter
--- @field items WinbarFormatterItem[]
--- @field tabnr integer
local M = {}

--- 返回 modified buffer name
--- @return string
local function bufname_mod(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname ~= '' then
    return bufname
  end

  --- 以下是特殊情况
  if vim.fn.getcmdwintype() ~= '' then
    return "[Command Line]"
  end

  local bt = vim.bo[bufnr].buftype
  if bt == "quickfix" then
    return "[List]"
  elseif bt == "nofile" then
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
--- @param bufnrs integer[]
--- @return string[][] fp_list
local function uniqie_bufnames(bufnrs)
  local bufnames = {}  ---@type string[]
  for _, bufnr in ipairs(bufnrs) do
    table.insert(bufnames, bufname_mod(bufnr))
  end

  return u.unique_short_paths(bufnames)
end

--- 将 items 转成 ordered components
---
--- @param fmt_items WinbarFormatterItem[]
--- @return WinbarFormatterItemComponent[][]
--- @return integer total_width
local function fmt_items_to_components(fmt_items, level)
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
--- @return WinbarFormatterItemComponent|nil
local function tabpage_component()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    local tab_str = ' ' .. vim.fn.tabpagenr() ..'/'.. #tabs .. ' '
    --- @type WinbarFormatterItemComponent
    local tab_comp = { content = tab_str, hl = '%=%#MyWinBarLineTab#' }
    return tab_comp
  end
end


--- format all items' components to winbar string
---
--- @param fmt_comps_list WinbarFormatterItemComponent[][]
--- @return string winbar_str
local function format_winbar_components(fmt_comps_list)
  local str_list = {}
  for _, comps in ipairs(fmt_comps_list) do
    local str = ''
    for _, comp in ipairs(comps) do
      str = str .. comp.hl .. comp.content
    end
    str = str .. '%*'  -- '%*' reset highligh
    table.insert(str_list, str)
  end

  --- concat 所有 buffer 的 winbar format
  return table.concat(str_list, ' ')
end


--- @param fmt_items WinbarFormatterItem[]
--- @param win_width integer
--- @param active_buf_idx integer
--- @param min_level 5|4|3|2|1 -- level: 'full', 'init', 'base', 'short', 'none'
--- @return WinbarFormatterItemComponent[][]
local function reduce_items_to_display(fmt_items, win_width, active_buf_idx, min_level)
  --- @type WinbarFormatterItemComponent[][]
  local components = {}

  --- @type WinbarFormatterItem[]
  local partial_items = {}

  local p_item_idx
  local full = false

  --- 优先填充左侧
  for i = active_buf_idx, 1, -1 do
    table.insert(partial_items, 1, fmt_items[i])
    local _, p_width = fmt_items_to_components(partial_items, min_level)

    --- win_width-4 是为了给 '<', '>' 留出位置
    if p_width > win_width-4 then
      table.remove(partial_items, 1)  -- 移除第一个 item
      p_item_idx = i
      full = true
      break
    end
  end

  --- 填充右侧
  if not full then
    for i = active_buf_idx+1, #fmt_items, 1 do
      table.insert(partial_items, fmt_items[i])
      local _, p_width = fmt_items_to_components(partial_items, min_level)

      --- win_width-4 是为了给 '<', '>' 留出位置
      if p_width > win_width-4 then
        table.remove(partial_items, #partial_items)  -- 移除最后一个 item
        p_item_idx = i
        full = true
        break
      end
    end
  end

  local comps, comp_width = fmt_items_to_components(partial_items, min_level)
  components = comps

  --- 追加 <, > 显示
  local remain_width
  if p_item_idx < active_buf_idx then
    if active_buf_idx < #fmt_items then
      --- 左右都需要添加 '<', '>'
      remain_width = win_width-4 - comp_width
      table.insert(components, {{ content='>', hl='%*' }})
    else
      --- 只有左侧需要添加 '<'
      remain_width = win_width-2 - comp_width
    end

    table.insert(components, 1, fmt_items[p_item_idx]:partial(remain_width, min_level, 'suffix'))
    table.insert(components, 1, {{ content='<', hl='%*' }})
  else
    --- 只有右侧需要添加 '>'
    remain_width = win_width-2 - comp_width
    table.insert(components, fmt_items[p_item_idx]:partial(remain_width, min_level, 'prefix'))
    table.insert(components, {{ content='>', hl='%*' }})
  end

  return components
end


--- @param fmt_items WinbarFormatterItem[]
--- @param win_id integer
--- @param active_buf_idx integer
--- @param min_level 5|4|3|2|1 -- level: 'full', 'init', 'base', 'short', 'none'
--- @return string winbar_str
local function format_winbar_items(fmt_items, win_id, active_buf_idx, min_level)
  local win_width = vim.api.nvim_win_get_config(win_id).width
  if not win_width then
    error("win_id: " .. win_id .. "do not have 'width'")
  end

  local tab_comp = tabpage_component()
  if tab_comp then
    win_width = win_width - vim.fn.strdisplaywidth(tab_comp.content) - 2  -- table.concat() 的空格
  end

  --- @type WinbarFormatterItemComponent[][]
  local components = {}
  for level = 5, min_level, -1 do
    local comps, total_width = fmt_items_to_components(fmt_items, level)
    if total_width < win_width then
      components = comps
      break
    end
  end

  if vim.tbl_isempty(components) then
    components = reduce_items_to_display(fmt_items, win_width, active_buf_idx, min_level)
  end

  --- 添加 tabpagenr component
  if tab_comp then
    table.insert(components, { tab_comp })
  end

  return format_winbar_components(components)
end


--- 获取 window 中的所有 buffer, format 成适合的 winbar string
---
--- @param win_id integer
--- @return string|nil winbar_str
function M.winbar_format(win_id)
  local w = g.get_win(win_id)
  if not w then
    return
  end

  local bufnrs = w:list_bufs()
  local uni_bufnames = uniqie_bufnames(bufnrs)

  --- @type WinbarFormatterItem[]
  local fmt_items = {}
  local active_buf_idx

  for i, path_list in ipairs(uni_bufnames) do
    local bufnr = bufnrs[i]
    local b = g.get_buf(bufnr)
    if not b then
      error('buffer: ' .. bufnr .. ' is not cached')
    end

    local fmt_item = wb_fmt_item.new(win_id, bufnr, i, path_list, b:diagnostic())
    if fmt_item.active then
      active_buf_idx = i
    end

    table.insert(fmt_items, fmt_item)
  end

  local min_level = 2
  return format_winbar_items(fmt_items, win_id, active_buf_idx, min_level)
end


return M
