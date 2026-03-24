local g = require('utils.winbarline2.global')
local u = require('utils.winbarline2.utils')
local wb_fmt_item = require('utils.winbarline2.winbar_formatter_item')


--- @class WinbarFormatter
--- @field items WinbarFormatterItem[]
--- @field tabnr integer
local M = {}

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
--- @return string[][]
local function uniqie_bufnames(bufnrs)
  local bufnames = {}  ---@type string[]
  for _, bufnr in ipairs(bufnrs) do
    table.insert(bufnames, bufname_mod(bufnr))
  end

  return u.unique_short_paths(bufnames)
end


--- @param fmt_items WinbarFormatterItemComponents[]
--- @return integer
local function fmt_items_len(fmt_items)
  local count = 0
  for _, item in ipairs(fmt_items) do
    for _, comp in ipairs(item) do
      count = count + comp.len + 1 -- 每个 buffer 后的空格
    end
  end
  return count
end


--- @param fmt_items WinbarFormatterItemComponents[]
--- @return string
local function format_winbar_items(fmt_items)
  local str_list = {}
  for _, item in ipairs(fmt_items) do
    local str = ''
    for _, comp in ipairs(item) do
      str = str .. comp.hl .. comp.str
    end
    str = str .. '%*'  -- '%*' reset highligh>
    table.insert(str_list, str)
  end

  --- concat 所有 buffer 的 winbar format
  local str = table.concat(str_list, ' ')

  --- 添加 tabpagenr
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    str = str .. '%=%#MyWinBarLineTab# ' .. vim.fn.tabpagenr() ..'/'.. #tabs .. ' '
  end

  return str
end

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
  for i, path_list in ipairs(uni_bufnames) do
    local bufnr = bufnrs[i]
    local b = g.get_buf(bufnr)
    if not b then
      error('buffer: ' .. bufnr .. ' is not cached')
    end

    local fmt_item = wb_fmt_item.new(win_id, bufnr, i, path_list, b:diagnostic())
    table.insert(fmt_items, fmt_item)
  end

  --- @type WinbarFormatterItemComponents[]
  local components = {}
  for level = 5, 1, -1 do
    for _, item in ipairs(fmt_items) do
      local comp = item:parse(level)
      table.insert(components, comp)
    end
    if fmt_items_len(components) < vim.api.nvim_win_get_config(win_id).width or level == 1 then
      print(fmt_items_len(components), vim.api.nvim_win_get_config(win_id).width)
      break
    end
    components = {}
  end

  return format_winbar_items(components)
end


return M
