local g = require('utils.winbarline2.global')
local u = require('utils.winbarline2.utils')
local wb_fmt_item = require('utils.winbarline2.winbar_formatter_item')


--- @class WinbarFormatter
--- @field items WinbarFormatterItem[]
--- @field tabnr integer
local M = {}

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
    return "[Scratch]"
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


--- @param bufnrs integer[]
local function uniqie_bufnames(bufnrs)
  local bufnames = {}  ---@type string[]
  for _, bufnr in ipairs(bufnrs) do
    table.insert(bufnames, bufname_mod(bufnr))
  end

  return u.unique_short_paths(bufnames)
end


--- @param win_id integer
function M.winbar_format(win_id)
  local w = g.get_win(win_id)
  if not w then
    return
  end

  local bufnrs = w:list_bufs()
  local uni_bufnames = uniqie_bufnames(bufnrs)

  --- @type string[]
  local fmt_items = {}
  for i, path_list in ipairs(uni_bufnames) do
    local bufnr = bufnrs[i]
    local b = g.get_buf(bufnr)
    if not b then
      error('buffer: ' .. bufnr .. ' is not cached')
    end

    local fmt_item = wb_fmt_item.new(win_id, bufnr, i, path_list, b:diagnostic())
    table.insert(fmt_items, fmt_item:format())
  end

  --- concat 所有 buffer 的 winbar format
  local str = table.concat(fmt_items, ' ')

  --- 添加 tabpagenr
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    str = str .. '%=%#MyWinBarLineTab# ' .. vim.fn.tabpagenr() ..'/'.. #tabs .. ' '
  end

  return str
end


return M
