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


--- @alias WinbarFormatterItemComponents { str: string, hl: string, len: integer }[]

--- @param opts 5|4|3|2|1 -- level: 'full', 'init', 'base', 'short', 'none'
--- @return WinbarFormatterItemComponents
function M:parse(opts)
  --- @type WinbarFormatterItemComponents
  local components = {}

  --- indicator
  local indicator_str = self.active and sign_indicator or ' '
  table.insert(components, { str = indicator_str, hl = 'Indicator', len = vim.fn.strdisplaywidth(indicator_str) })

  --- index
  local idx_str = self.index .. ' '
  table.insert(components, { str = idx_str, hl = 'Index', len = vim.fn.strdisplaywidth(idx_str) })

  --- prefix
  if self.prefix and opts > 3 then
    local prefix_str = ''
    if opts == 5 then
      prefix_str = table.concat(self.prefix, '/') .. '/'
    elseif opts == 4 then
      for _, path in ipairs(self.prefix) do
        local s = vim.fn.strcharlen(path) > 0 and vim.fn.strcharpart(path, 0, 1) or ''
        prefix_str = prefix_str .. s .. '/'
      end
    end
    table.insert(components, { str = prefix_str, hl = 'Prefix', len = vim.fn.strdisplaywidth(prefix_str) })
  end

  --- bufname
  if opts > 2 or self.active then
    local bufname_str = self.bufname .. ' '
    table.insert(components, { str = bufname_str, hl = '', len = vim.fn.strdisplaywidth(bufname_str) })
  elseif opts == 2 then
    local bufname_str = self.bufname:sub(1,3) .. ' '
    table.insert(components, { str = bufname_str, hl = '', len = vim.fn.strdisplaywidth(bufname_str) })
  else
    local bufname_str = ' '
    table.insert(components, { str = bufname_str, hl = '', len = vim.fn.strdisplaywidth(bufname_str) })
  end

  --- diagnostic
  if self.diagnostic and opts > 2 then
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
    --- 如果是 active & in current window 则使用 Selected highlight
    if self.in_current_win and self.active then
      comp.hl = '%#' .. hl_prefix_selected .. comp.hl .. '#'
    else
      comp.hl = '%#' .. hl_prefix_default .. comp.hl .. '#'
    end
  end

  return components
end

return M
