--- @class WinbarFormatterItemComponent
---
--- winbar 需要显示的内容
--- @field content string
---
--- winbar 显示内容的 highlight
--- @field hl string


--- @enum WinbarFormatterLevel
local WinbarFormatterLevel = {
  none = 1,    -- no bufname
  minimal = 2, -- 4 display width bufname with '…'
  base = 3,    -- basename of buffer
  init = 4,    -- init prefix with basename
  full = 5,    -- full prefix with basename
}


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
local WinbarFomatterItem = {}
WinbarFomatterItem.__index = WinbarFomatterItem

--- @param win_id integer
--- @param bufnr integer
--- @param index integer
--- @param path_list string[]  -- filepath list, eg: a/b/c -> ["a", "b", "c"]
--- @param diagnostic? { count: integer, severity: integer }
--- @return WinbarFormatterItem
function WinbarFomatterItem.new(win_id, bufnr, index, path_list, diagnostic)
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
  }, WinbarFomatterItem)

  return self
end


--- 从 str 中按 display width 截取，suffix=true 从后往前
--- @param str string
--- @param width integer  remaining display width
--- @param suffix boolean|nil
--- @return string|nil partial_string
local function partial_str(str, width, suffix)
  -- strcharlen('你好') = 2, 按照 char 计算
  -- string.len('你好') = 6, 按照 byte 计算
  -- strdisplaywidth('你好') = 4, 按照 display width 计算
  local char_count = vim.fn.strcharlen(str)
  local chars = {}

  local iter_start, iter_end, iter_step
  if suffix then
    iter_start, iter_end, iter_step = char_count-1, 0, -1  -- 倒序
  else
    iter_start, iter_end, iter_step = 0, char_count-1, 1   -- 顺序
  end

  for i = iter_start, iter_end, iter_step do
    -- NOTE: 按照 CJK 获取 char, CJK 文字占 1 个 charlen, 但是占 2 个 display width, 需要特殊处理
    -- string.sub('你好', 1, 1), 按照 byte 返回
    -- strcharpart('你好', 1, 1) = "你", 按照 char 返回
    local char = vim.fn.strcharpart(str, i, 1)
    local char_width = vim.fn.strdisplaywidth(char)

    if width < char_width then
      break
    end

    width = width - char_width
    if suffix then
      table.insert(chars, 1, char)  -- 倒序插入
    else
      table.insert(chars, char)
    end
  end

  if #chars == 0 then
    return nil
  end

  return table.concat(chars)
end


--- @param width integer
--- @param level WinbarFormatterLevel
--- @param mode? 'prefix'|'suffix'
--- @return WinbarFormatterItemComponent[]  -- indicator, index, bufname, diagnostic, modified
function WinbarFomatterItem:partial(width, level, mode)
  mode = mode or 'prefix'
  local suffix = mode == 'suffix'

  local components, item_width = self:parse_item_to_components(level)
  if width >= item_width then
    return components
  end

  --- @type WinbarFormatterItemComponent[]
  local partial_comps = {}
  local remain_width = width

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

    local comp_width = vim.fn.strdisplaywidth(comp.content)
    if remain_width >= comp_width then
      --- remain width 超过整个 component 长度
      _insert(comp)
      remain_width = remain_width - comp_width
    else
      --- remain width 小于整个 component 长度
      local p_str = partial_str(comp.content, remain_width, suffix)
      if p_str then
        _insert({ content = p_str, hl = comp.hl })
      end
      break  -- remain width 耗尽，后续无需遍历
    end
  end

  return partial_comps
end


--- @param level WinbarFormatterLevel
--- @return WinbarFormatterItemComponent[]  -- indicator, index, bufname, diagnostic, modified
--- @return integer width -- item width: including a trailing space
function WinbarFomatterItem:parse_item_to_components(level)
  --- @type WinbarFormatterItemComponent[]
  local components = {}
  local item_width = 1  -- NOTE: 每个 item 后一个空格

  --- indicator
  local indicator_str = self.active and sign_indicator or ' '
  --- @type WinbarFormatterItemComponent
  local comp = { content = indicator_str, hl = 'Indicator' }
  table.insert(components, comp)

  --- index
  local idx_str = self.index .. ' '
  comp = { content = idx_str, hl = 'Index' }
  table.insert(components, comp)

  --- filepath prefix
  if self.fp_prefix and level > WinbarFormatterLevel.base then
    local prefix_str = ''
    if level == WinbarFormatterLevel.full then
      prefix_str = table.concat(self.fp_prefix, '/') .. '/'
    elseif level == WinbarFormatterLevel.init then
      for _, path in ipairs(self.fp_prefix) do
        --- NOTE: strcharlen('你好') = 2, strcharpart('你好', 0, 1) = '你', strdisplaywidth('你') = 2
        --- 这是为了获取完整的 'CJK' 文字
        local s = vim.fn.strcharlen(path) > 0 and vim.fn.strcharpart(path, 0, 1) or ''
        prefix_str = prefix_str .. s .. '/'
      end
    end

    comp = { content = prefix_str, hl = 'Prefix' }
    table.insert(components, comp)
  end

  --- bufname
  local bufname_str = ''
  if level > WinbarFormatterLevel.minimal or self.active then
    --- 如果是 active buffer 不要省略 basename
    bufname_str = self.basename .. ' '
  elseif level == WinbarFormatterLevel.minimal then
    local display_width = 4
    local p_str = partial_str(self.basename, display_width)
    if p_str == self.basename then
      bufname_str = bufname_str .. p_str .. ' '
    else
      bufname_str = bufname_str .. p_str .. '… '
    end
  else
    bufname_str = '… '
  end
  comp = { content = bufname_str, hl = '' }
  table.insert(components, comp)

  --- diagnostic
  if self.diagnostic and (level > WinbarFormatterLevel.minimal or self.active) then
    local diag_str = '('..self.diagnostic.count..') '
    comp = { content = diag_str, hl = 'Severity_'..self.diagnostic.severity }
    table.insert(components, comp)
  end

  --- modified
  if vim.bo[self.bufnr].modified then
    local modified_str = sign_modified .. ' '
    comp = { content = modified_str, hl = 'Modified' }
    table.insert(components, comp)
  end

  --- update highlight prefix
  local hl_prefix_default = 'MyWinBarLineBuffer'
  local hl_prefix_selected = 'MyWinBarLineBufferSelected'

  for _, c in ipairs(components) do
    item_width = item_width + vim.fn.strdisplaywidth(c.content)
    --- 如果是 active & in current window 则使用 Selected highlight
    if self.in_current_win and self.active then
      c.hl = '%#' .. hl_prefix_selected .. c.hl .. '#'
    else
      c.hl = '%#' .. hl_prefix_default .. c.hl .. '#'
    end
  end

  return components, item_width
end

return WinbarFomatterItem
