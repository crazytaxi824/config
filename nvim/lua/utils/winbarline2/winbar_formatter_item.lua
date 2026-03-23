local g = require('utils.winbarline2.global')


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


--- @return string
function M:format()
  local hl_prefix = 'MyWinBarLineBuffer'

  --- @type { str: string, hl_suffix: string }[]
  local components = {}

  --- indicator
  if self.active then
    table.insert(components, { str = sign_indicator, hl_suffix = 'Indicator' })
  else
    table.insert(components, { str = ' ', hl_suffix = 'Indicator' })
  end

  --- index
  table.insert(components, { str = self.index .. '. ', hl_suffix = '' })

  --- prefix
  if self.prefix then
    table.insert(components, { str = self.prefix, hl_suffix = 'Prefix' })
  end

  --- bufname
  table.insert(components, { str = self.bufname .. ' ', hl_suffix = '' })

  --- diagnostic
  if self.diagnostic then
    table.insert(components, { str = '('..self.diagnostic.count..') ', hl_suffix = 'Severity_'..self.diagnostic.severity })
  end

  --- modified
  if vim.bo[self.bufnr].modified then
    table.insert(components, { str = sign_modified .. ' ', hl_suffix = 'Modified'})
  end


  local str = ''
  for _, comp in ipairs(components) do
    local hl
    if self.in_current_win and self.active then
      hl = '%#' .. hl_prefix .. 'Selected' .. comp.hl_suffix .. '#'
    else
      hl = '%#' .. hl_prefix .. comp.hl_suffix .. '#'
    end

    str = str .. hl .. comp.str
  end

  return str .. '%*'
end

return M
