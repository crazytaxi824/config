--- @class WinbarFormatterItemComponent
---
--- winbar 需要显示的内容
--- @field str string
---
--- winbar 显示内容的 highlight
--- @field hl string
---
--- -- TODO: 改成 width
--- str 的 display width
--- @field len integer


local sign_indicator = '▌'
local sign_modified = '●'


--- @class WinbarFormatterItem
--- @field bufnr integer
---
--- display index in window
--- @field index integer
---
--- filepath head/dir
--- @field fp_prefix? string[]  -- filepath prefix
---
--- last part of filepath
--- @field basename string
---
--- vim.diagnostic.count()
--- @field diagnostic? { count: integer, severity: integer }
---
--- active buffer
--- @field active boolean
---
--- @field in_current_win boolean
local M = {}
M.__index = M

--- @param win_id integer
--- @param bufnr integer
--- @param index integer
--- @param path_list string[]
--- @param diagnostic? { count: integer, severity: integer }
--- @return WinbarFormatterItem
function M.new(win_id, bufnr, index, path_list, diagnostic)
  local prefix
  if #path_list < 1 then
    error(bufnr .. " path_list is empty")
  elseif #path_list > 1 then
    prefix = table.move(path_list, 1, #path_list-1, 1, {})
  end

  --- @type WinbarFormatterItem
  local self = setmetatable({
    bufnr = bufnr,
    index = index,
    fp_prefix = prefix,
    basename = path_list[#path_list],
    diagnostic = diagnostic,
    in_current_win = win_id == vim.api.nvim_get_current_win(),
    active = bufnr == vim.api.nvim_win_get_buf(win_id),
  }, M)

  return self
end

--- 从 str 中按 display width 截取，suffix=true 从后往前
--- @param comp WinbarFormatterItemComponent
--- @param remain_len integer
--- @param suffix boolean
--- @return WinbarFormatterItemComponent|nil -- 截取后的 comp
--- @return integer  -- 消耗的 len
local function partial_comp(comp, remain_len, suffix)
  local chars = {}
  local char_count = vim.fn.strcharlen(comp.str)

  local iter_start, iter_end, iter_step
  if suffix then
    iter_start, iter_end, iter_step = char_count-1, 0, -1  -- 倒序
  else
    iter_start, iter_end, iter_step = 0, char_count-1, 1   -- 顺序
  end

  for i = iter_start, iter_end, iter_step do
    -- NOTE: 按照 CJK 获取 char, CJK 文字占 1 个 len, 但是占 2 个 display width, 需要特殊处理
    -- string.sub('你好',1,1) 返回一个 byte
    -- strcharpart('你好',1,1) 返回 "你"
    local char = vim.fn.strcharpart(comp.str, i, 1)
    local char_width = vim.fn.strdisplaywidth(char)

    if remain_len < char_width then
      break
    end

    remain_len = remain_len - char_width
    if suffix then
      table.insert(chars, 1, char)  -- 倒序插入
    else
      table.insert(chars, char)
    end
  end

  if #chars == 0 then
    return nil, 0
  end

  local remain_str = table.concat(chars)
  local used_len = comp.len - remain_len

  --- @type WinbarFormatterItemComponent
  local p_comp = { str = remain_str, hl = comp.hl, len = vim.fn.strdisplaywidth(remain_str) }
  return p_comp, used_len
end

--- @param charlen integer
--- @param level 5|4|3|2|1 -- level: 'full', 'init', 'base', 'short', 'none'
--- @param mode? 'prefix'|'suffix'
--- @return WinbarFormatterItemComponent[]  -- indicator, index, bufname, diagnostic, modified
function M:partial(charlen, level, mode)
  mode = mode or 'prefix'
  local suffix = mode == 'suffix'

  local components, item_len = self:parse(level)
  if charlen >= item_len then
    return components
  end

  --- @type WinbarFormatterItemComponent[]
  local partial_comps = {}
  local remain_len = charlen

  local function _insert(comp)
    if suffix then
      table.insert(partial_comps, 1, comp)  -- 倒序插入
    else
      table.insert(partial_comps, comp)
    end
  end

  local iter_start, iter_end, iter_step
  if suffix then
    iter_start, iter_end, iter_step = #components, 1, -1  -- 倒序
  else
    iter_start, iter_end, iter_step = 1, #components, 1   -- 顺序
  end

  for i = iter_start, iter_end, iter_step do
    local comp = components[i]

    if remain_len >= comp.len then
      --- remain_len 超过整个 component 长度
      _insert(comp)
      remain_len = remain_len - comp.len
    else
      --- remain_len 小于整个 component 长度
      local result = partial_comp(comp, remain_len, suffix)
      if result then
        _insert(result)
      end
      break  -- remain_len 耗尽，后续无需遍历
    end
  end

  return partial_comps
end


--- @param level 5|4|3|2|1 -- level: 'full', 'init', 'base', 'short', 'none'
--- @return WinbarFormatterItemComponent[]  -- indicator, index, bufname, diagnostic, modified
--- @return integer  -- total_len: including trailing space
function M:parse(level)
  --- @type WinbarFormatterItemComponent[]
  local components = {}
  local item_len = 1  -- NOTE: 每个 item 后一个空格

  --- indicator
  local indicator_str = self.active and sign_indicator or ' '
  --- @type WinbarFormatterItemComponent
  local comp = { str = indicator_str, hl = 'Indicator', len = vim.fn.strdisplaywidth(indicator_str) }
  table.insert(components, comp)

  --- index
  local idx_str = self.index .. ' '
  --- @type WinbarFormatterItemComponent
  comp = { str = idx_str, hl = 'Index', len = vim.fn.strdisplaywidth(idx_str) }
  table.insert(components, comp)

  --- filepath prefix
  if self.fp_prefix and level > 3 then
    local prefix_str = ''
    if level == 5 then
      prefix_str = table.concat(self.fp_prefix, '/') .. '/'
    elseif level == 4 then
      for _, path in ipairs(self.fp_prefix) do
        --- NOTE: strcharlen('你好') = 2, strcharpart('你好', 0, 1) = '你', strdisplaywidth('你') = 2
        --- 这是为了获取完整的 'CJK' 文字
        local s = vim.fn.strcharlen(path) > 0 and vim.fn.strcharpart(path, 0, 1) or ''
        prefix_str = prefix_str .. s .. '/'
      end
    end

    --- @type WinbarFormatterItemComponent
    comp = { str = prefix_str, hl = 'Prefix', len = vim.fn.strdisplaywidth(prefix_str) }
    table.insert(components, comp)
  end

  --- bufname
  local bufname_str = ''
  if level > 2 or self.active then
    bufname_str = self.basename .. ' '
  elseif level == 2 then
    --- TODO: change to strcharpart()
    bufname_str = self.basename:sub(1,3) .. ' '
  else
    bufname_str = ' '
  end
  --- @type WinbarFormatterItemComponent
  comp = { str = bufname_str, hl = '', len = vim.fn.strdisplaywidth(bufname_str) }
  table.insert(components, comp)

  --- diagnostic
  if self.diagnostic and (level > 2 or self.active) then
    local diag_str = '('..self.diagnostic.count..') '
    --- @type WinbarFormatterItemComponent
    comp = { str = diag_str, hl = 'Severity_'..self.diagnostic.severity, len = vim.fn.strdisplaywidth(diag_str) }
    table.insert(components, comp)
  end

  --- modified
  if vim.bo[self.bufnr].modified then
    local modified_str = sign_modified .. ' '
    --- @type WinbarFormatterItemComponent
    comp = { str = modified_str, hl = 'Modified', len = vim.fn.strdisplaywidth(modified_str)}
    table.insert(components, comp)
  end

  --- update highlight prefix
  local hl_prefix_default = 'MyWinBarLineBuffer'
  local hl_prefix_selected = 'MyWinBarLineBufferSelected'

  for _, c in ipairs(components) do
    item_len = item_len + c.len
    --- 如果是 active & in current window 则使用 Selected highlight
    if self.in_current_win and self.active then
      c.hl = '%#' .. hl_prefix_selected .. c.hl .. '#'
    else
      c.hl = '%#' .. hl_prefix_default .. c.hl .. '#'
    end
  end

  return components, item_len
end

return M
