local sign_indicator = '▌'
local sign_modified = '●'


--- @class WinbarFormatterItem
--- @field bufnr integer
--- @field index integer
--- @field prefix? string
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
    prefix = table.concat(path_list, '/', 1, #path_list-1) .. '/'
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

--- @return WinbarFormatterItemComponents
function M:parse()
  --- @type WinbarFormatterItemComponents
  local components = {}

  --- indicator
  local indicator_str = self.active and sign_indicator or ' '
  table.insert(components, { str = indicator_str, hl = 'Indicator', len = vim.fn.strdisplaywidth(indicator_str) })

  --- index
  local idx_str = self.index .. ' '
  table.insert(components, { str = idx_str, hl = 'Index', len = vim.fn.strdisplaywidth(idx_str) })

  --- prefix
  if self.prefix then
    table.insert(components, { str = self.prefix, hl = 'Prefix', len = vim.fn.strdisplaywidth(self.prefix) })
  end

  --- bufname
  local bufname_str = self.bufname .. ' '
  table.insert(components, { str = bufname_str, hl = '', len = vim.fn.strdisplaywidth(bufname_str) })

  --- diagnostic
  if self.diagnostic then
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
