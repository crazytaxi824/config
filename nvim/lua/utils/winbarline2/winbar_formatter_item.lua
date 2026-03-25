--- @alias WinbarFormatterItemComponents { str: string, hl: string, len: integer }[]


local sign_indicator = '▌'
local sign_modified = '●'


--- @class WinbarFormatterItem
--- @field bufnr integer
--- @field index integer
--- @field prefix? string[]
--- @field bufname string
--- @field diagnostic? { count: integer, severity: integer }
--- @field in_current_win boolean
--- @field active boolean
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

  local self = setmetatable({
    bufnr = bufnr,
    index = index,
    prefix = prefix,
    bufname = path_list[#path_list],
    diagnostic = diagnostic,
    in_current_win = win_id == vim.api.nvim_get_current_win(),
    active = bufnr == vim.api.nvim_win_get_buf(win_id),
  }, M)

  return self
end

--- @param charlen integer
--- @param level 5|4|3|2|1 -- level: 'full', 'init', 'base', 'short', 'none'
--- @return WinbarFormatterItemComponents  -- indicator, index, bufname, diagnostic, modified
function M:partial(charlen, level)
  local components, item_len = self:parse(level)
  if charlen >= item_len then
    return components
  end

  --- @type WinbarFormatterItemComponents
  local partial_comps = {}
  local remain_len = charlen

  for i = #components, 1, -1 do
    local comp = components[i]

    if remain_len >= comp.len then
      table.insert(partial_comps, 1, comp)
      remain_len = remain_len - comp.len
    else
      --- 按照整字读取, 避免读取半个 CJK 文字.
      local chars = {}
      local char_count = vim.fn.strcharlen(comp.str)

      for j = char_count-1, 0, -1 do
        local char = vim.fn.strcharpart(comp.str, j, 1)
        local char_width = vim.fn.strdisplaywidth(char)

        if remain_len < char_width then
          break
        end

        remain_len = remain_len - char_width
        table.insert(chars, 1, char)
      end

      if #chars > 0 then
        local remain_str = table.concat(chars)
        table.insert(partial_comps, 1, {str = remain_str, hl = comp.hl, len = vim.fn.strdisplaywidth(remain_str)})
      end
    end
  end

  for _, comp in ipairs(components) do
    if remain_len >= comp.len then
      table.insert(partial_comps, comp)
      remain_len = remain_len - comp.len
    else
      --- 按照整字读取, 避免读取半个 CJK 文字.
      local chars = {}
      local char_count = vim.fn.strcharlen(comp.str)

      for i = 0, char_count-1, 1 do
        local char = vim.fn.strcharpart(comp.str, i, 1)
        local char_width = vim.fn.strdisplaywidth(char)

        if remain_len < char_width then
          break
        end

        remain_len = remain_len - char_width
        table.insert(chars, char)
      end

      if #chars > 0 then
        local remain_str = table.concat(chars)
        table.insert(partial_comps, {str = remain_str, hl = comp.hl, len = vim.fn.strdisplaywidth(remain_str)})
      end
    end
  end

  return partial_comps
end


--- @param level 5|4|3|2|1 -- level: 'full', 'init', 'base', 'short', 'none'
--- @return WinbarFormatterItemComponents  -- indicator, index, bufname, diagnostic, modified
--- @return integer  -- total_len: including trailing space
function M:parse(level)
  --- @type WinbarFormatterItemComponents
  local components = {}
  local item_len = 1  -- NOTE: 每个 item 后一个空格

  --- indicator
  local indicator_str = self.active and sign_indicator or ' '
  table.insert(components, { str = indicator_str, hl = 'Indicator', len = vim.fn.strdisplaywidth(indicator_str) })

  --- index
  local idx_str = self.index .. ' '
  table.insert(components, { str = idx_str, hl = 'Index', len = vim.fn.strdisplaywidth(idx_str) })

  --- prefix
  if self.prefix and level > 3 then
    local prefix_str = ''
    if level == 5 then
      prefix_str = table.concat(self.prefix, '/') .. '/'
    elseif level == 4 then
      for _, path in ipairs(self.prefix) do
        --- NOTE: strcharlen('你好') = 2, strcharpart('你好', 0, 1) = '你', strdisplaywidth('你') = 2
        --- 这是为了获取完整的 'CJK' 文字
        local s = vim.fn.strcharlen(path) > 0 and vim.fn.strcharpart(path, 0, 1) or ''
        prefix_str = prefix_str .. s .. '/'
      end
    end
    table.insert(components, { str = prefix_str, hl = 'Prefix', len = vim.fn.strdisplaywidth(prefix_str) })
  end

  --- bufname
  if level > 2 or self.active then
    local bufname_str = self.bufname .. ' '
    table.insert(components, { str = bufname_str, hl = '', len = vim.fn.strdisplaywidth(bufname_str) })
  elseif level == 2 then
    local bufname_str = self.bufname:sub(1,3) .. ' '
    table.insert(components, { str = bufname_str, hl = '', len = vim.fn.strdisplaywidth(bufname_str) })
  else
    local bufname_str = ' '
    table.insert(components, { str = bufname_str, hl = '', len = vim.fn.strdisplaywidth(bufname_str) })
  end

  --- diagnostic
  if self.diagnostic and level > 2 then
    local diag_str = '('..self.diagnostic.count..') '
    table.insert(components, { str = diag_str, hl = 'Severity_'..self.diagnostic.severity, len = vim.fn.strdisplaywidth(diag_str) })
  end

  --- modified
  if vim.bo[self.bufnr].modified then
    local modified_str = sign_modified .. ' '
    table.insert(components, { str = modified_str, hl = 'Modified', len = vim.fn.strdisplaywidth(modified_str)})
  end

  --- update highlight prefix
  local hl_prefix_default = 'MyWinBarLineBuffer'
  local hl_prefix_selected = 'MyWinBarLineBufferSelected'

  for _, comp in ipairs(components) do
    item_len = item_len + comp.len
    --- 如果是 active & in current window 则使用 Selected highlight
    if self.in_current_win and self.active then
      comp.hl = '%#' .. hl_prefix_selected .. comp.hl .. '#'
    else
      comp.hl = '%#' .. hl_prefix_default .. comp.hl .. '#'
    end
  end

  return components, item_len
end

return M
