local fmt_item = require('myplugins.wbl.winbar_formatter_item')
local bimap = require('myplugins.wbl.bimap')


---@class WinbarFormatter
---@field items WinbarFormatterItem[]
---@field tabnr integer
local WinbarFormatter = {}


-- 将路径分割为段列表（从后往前）
-- "/a/b/c.lua" -> {"c.lua", "b", "a"}
--
---@param path string
---@return string[]
local function split_path_reversed(path)
  local parts = {}
  for part in path:gmatch("[^/]+") do
    -- 倒序插入
    table.insert(parts, 1, part)
  end
  return parts
end


-- 获取多个路径各自的最短唯一显示名
---@param paths string[]  multi buffer's filepath
---@return string[][] filepaths  multi buffers' split filepath list
local function unique_short_paths(paths)
  local all_parts = {}
  for _, path in ipairs(paths) do
    all_parts[#all_parts + 1] = split_path_reversed(path)
  end

  local n = #all_parts
  -- 预先计算每条路径需要的最大深度，避免重复对比
  local max_depths = {}
  for i = 1, n do
    max_depths[i] = 1
  end

  -- 只遍历上三角 (i < j)，同时更新 i 和 j 的 max_depth
  for i = 1, n - 1 do
    local parts_a = all_parts[i]
    for j = i + 1, n do
      local parts_b = all_parts[j]
      local max_len = math.max(#parts_a, #parts_b)
      for k = 1, max_len do
        if parts_a[k] ~= parts_b[k] then
          if k > max_depths[i] then max_depths[i] = k end
          if k > max_depths[j] then max_depths[j] = k end
          break
        end
      end
    end
  end

  local results = {}
  for i, parts_a in ipairs(all_parts) do
    local max_depth = max_depths[i]
    local result = {}
    local actual_depth = math.min(max_depth, #parts_a)

    if actual_depth < 3 then
      for k = actual_depth, 1, -1 do
        -- 逆向读取 elem, 按顺序写入
        result[#result + 1] = parts_a[k]
      end
    else
      -- 保留最深的一段(倒数第一 filename)、"..."、最近的一段(prefix1)
      result[#result + 1] = parts_a[actual_depth]
      result[#result + 1] = ""
      result[#result + 1] = parts_a[1]
    end

    if max_depth > #parts_a then
      table.insert(result, 1, "")
    end
    results[#results + 1] = result
  end

  return results
end


---@return { count: integer, severity: integer }|nil
local function buf_diagnostic(bufnr)
  local diagnostics = vim.diagnostic.count(bufnr) or {}
  local diag_count = 0
  local severity = 9
  for s, c in pairs(diagnostics) do
    diag_count = diag_count + c

    if s < severity then
      severity = s
    end
  end

  if diag_count > 0 then
    return { count = diag_count, severity = severity }
  end
end

-- 返回 modified buffer name
---@return string
local function bufname_mod(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname ~= '' then
    return bufname
  end

  -- 特殊情况
  -- command line window 中不能加载任何其他 buffer. `q:`, `q/`, `q?` ...
  if vim.fn.getcmdwintype() ~= '' then
    return "[Command Line]"
  end

  -- NOTE: buftype = 'terminal' 是锁死的, 无法被手动设置
  local bt = vim.bo[bufnr].buftype
  if bt == "quickfix" then
    return "[List]"
  elseif bt == "nofile" then
    -- return filetype
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

-- 如果有相同的 base name 则向上寻找直至 dir name 不同
--
---@param bufnrs integer[]
---@return string[][] fp_list  -- {{ "prefix1", "prefix2" ... "filename1" }, { "prefix1", "prefix2" ... "filename2" }}
local function unique_bufnames(bufnrs)
  local bufnames = {}  ---@type string[]
  for _, bufnr in ipairs(bufnrs) do
    table.insert(bufnames, bufname_mod(bufnr))
  end

  return unique_short_paths(bufnames)
end

-- 将 items 转成 ordered components
--
---@param fmt_items WinbarFormatterItem[]
---@param level WinbarFormatterLevel
---@param focused boolean
---@return WinbarFormatterItemComponent[][]
---@return integer total_width
local function fmt_items_to_components(fmt_items, level, focused)
  ---@type WinbarFormatterItemComponent[][]
  local all_components = {}
  local total_width = 0

  for _, item in ipairs(fmt_items) do
    local comps, item_width = item:parse_item_to_components(level, focused)
    total_width = total_width + item_width
    table.insert(all_components, comps)
  end

  return all_components, total_width
end


-- 返回当前 tabpage info
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


-- format all items' components to winbar string
--
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

  -- concat 所有 buffer 的 winbar format
  return table.concat(str_list, ' ')
end


---@param fmt_items WinbarFormatterItem[]
---@param win_width integer
---@param active_buf_idx integer
---@param min_level WinbarFormatterLevel
---@param focused boolean
---@return WinbarFormatterItemComponent[][]
local function reduce_items_to_display(fmt_items, win_width, active_buf_idx, min_level, focused)
  ---@type WinbarFormatterItemComponent[][]
  local components = {}

  local p_item_idx  -- 需要计算 partial item 的 index
  local comp_width = 0

  -- 优先填充左侧
  for i = active_buf_idx, 1, -1 do
    local comp, i_width = fmt_items[i]:parse_item_to_components(min_level, focused)
    comp_width = comp_width + i_width

    -- 'win_width - 4' 是为了给 '<', '>' 留出位置
    if comp_width > win_width - 4 then
      comp_width = comp_width - i_width  -- 还原 width
      p_item_idx = i
      break
    end

    table.insert(components, 1, comp)
  end

  -- 填充右侧
  if not p_item_idx then
    for i = active_buf_idx+1, #fmt_items, 1 do
      local comp, i_width = fmt_items[i]:parse_item_to_components(min_level, focused)
      comp_width = comp_width + i_width

      -- 'win_width - 4' 是为了给 '<', '>' 留出位置
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

  -- 追加左右 '<', '>' 显示
  local remain_width = win_width - comp_width
  if p_item_idx < active_buf_idx then
    -- 左侧 item 需要 partial suffix, 并添加 '<'
    remain_width = remain_width - 2
    table.insert(components, 1, {{ content='<', hl='%*' }})

    if active_buf_idx < #fmt_items then
      -- active buffer 不是最后一个 buffer, 右侧也需要添加 '>'
      remain_width = remain_width - 2
      table.insert(components, {{ content='>', hl='%*' }})
    end

    -- components 插入在第二个位置
    table.insert(components, 2, fmt_items[p_item_idx]:partial(remain_width, min_level, 'suffix', focused))
  elseif p_item_idx == active_buf_idx then
    -- active buffer 已经超过 window width 了, 只能显示一个 buffer, 即 active buffer
    local insert_pos = 1  -- item 需要根据情况插入在第 1 | 2 的位置

    if active_buf_idx > 1 then
      -- active buffer 不是第一个 buffer, 则左侧需要添加 '<'
      insert_pos = 2  -- item 需要插入在第 2 的位置上
      remain_width = remain_width - 2
      table.insert(components, 1, {{ content='<', hl='%*' }})
    end

    if active_buf_idx < #fmt_items then
      -- active buffer 不是最后一个 buffer, 则右侧需要添加 '>'
      remain_width = remain_width - 2
      table.insert(components, {{ content='>', hl='%*' }})
    end

    -- components 插入在中间
    table.insert(components, insert_pos, fmt_items[p_item_idx]:partial(remain_width, min_level, 'prefix', focused))
  else
    -- 只有右侧需要添加 '>'
    remain_width = remain_width - 2
    table.insert(components, fmt_items[p_item_idx]:partial(remain_width, min_level, 'prefix', focused))
    table.insert(components, {{ content='>', hl='%*' }})
  end

  return components
end


---@param fmt_items WinbarFormatterItem[]
---@param win_width integer
---@param active_buf_idx integer
---@param min_level WinbarFormatterLevel
---@param focused boolean
---@return string winbar_str
local function format_winbar_items(fmt_items, win_width, active_buf_idx, min_level, focused)
  ---@type WinbarFormatterItemComponent[][]
  local components = {}

  local tab_comp = tabpage_component()
  if tab_comp then
    -- '-1': table.concat(components, ' ') 前的 n 个空格
    win_width = win_width - vim.fn.strdisplaywidth(tab_comp.content) - 1
  end

  -- 兜底效果
  if win_width <= 4 then
    components = {{{ content = '<...', hl='' }}}
  else
    for level = 5, min_level, -1 do
      local comps, comps_width = fmt_items_to_components(fmt_items, level, focused)
      if comps_width < win_width then
        components = comps
        break
      end
    end

    -- window width 不够, 只显示部分 items
    if vim.tbl_isempty(components) then
      components = reduce_items_to_display(fmt_items, win_width, active_buf_idx, min_level, focused)
    end
  end

  -- 添加 tabpagenr component
  if tab_comp then
    table.insert(components, { tab_comp })
  end

  return format_winbar_components(components)
end


-- 获取 window 中的所有 buffer, format 成适合的 winbar string
--
---@param win_id integer
---@param focused boolean
---@return string|nil winbar_str
function WinbarFormatter.winbar_format(win_id, focused)
  local bufnrs = bimap.win_get_buf_list(win_id)
  if not bufnrs or #bufnrs <= 0 then
    return
  end

  local uni_bufnames = unique_bufnames(bufnrs)

  ---@type WinbarFormatterItem[]
  local items = {}
  local active_buf_idx

  for i, path_list in ipairs(uni_bufnames) do
    local bufnr = bufnrs[i]
    if bimap.buf_is_valid(bufnr) then
      local item = fmt_item.new(win_id, bufnr, i, path_list, buf_diagnostic(bufnr))
      if item.active then
        active_buf_idx = i
      end

      table.insert(items, item)
    else
      -- buf 没有被 cache, 该问题不应该出现
      vim.notify(string.format('buffer: %d is not cached', bufnr), vim.log.levels.WARN)
    end
  end

  -- no item display in window 或者 win 中没有 active buffer
  -- NOTE: `:h help` 时出现该问题
  if vim.tbl_isempty(items) or not active_buf_idx then
    return
  end

  -- TODO: refactor format_winbar_items()
  local min_level = 4
  return format_winbar_items(items, vim.api.nvim_win_get_width(win_id), active_buf_idx, min_level, focused)
end


return WinbarFormatter
