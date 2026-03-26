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
    local comps, item_width = item:parse(level)
    total_width = total_width + item_width
    table.insert(all_components, comps)
  end
  return all_components, total_width
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
  for i, path_list in ipairs(uni_bufnames) do
    local bufnr = bufnrs[i]
    local b = g.get_buf(bufnr)
    if not b then
      error('buffer: ' .. bufnr .. ' is not cached')
    end

    local fmt_item = wb_fmt_item.new(win_id, bufnr, i, path_list, b:diagnostic())
    table.insert(fmt_items, fmt_item)
  end

  --- @type WinbarFormatterItemComponent[][]
  local components = {}
  for level = 5, 1, -1 do
    local comps, total_width = fmt_items_to_components(fmt_items, level)
    if level == 1 or total_width < vim.api.nvim_win_get_config(win_id).width then
      components = comps
      break
    end
  end

  return format_winbar_components(components)
end


return M
