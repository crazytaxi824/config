--- 跳转到 cursor 所在 filepath

local parse = require('utils.filepath.parse')
local vs = require('utils.visual_selected')

--- 则选择合适的 window 显示文件
---
--- @param absolute_path string
--- @return integer|nil
local function find_win_to_jump(absolute_path)
  local display_win_id

  --- 在当前 tab 中寻找第一个显示 listed-buffer 的 window, 用于显示 filepath.
  local tab_wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win_id in ipairs(tab_wins) do
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    local buffer_fullpath = vim.api.nvim_buf_get_name(bufnr)

    --- 寻找是否有 window 已经显示了指定文件.
    if buffer_fullpath == absolute_path then
      display_win_id = win_id
      break
    end

    --- 记录当前 tab 中第一个显示 listed-buffer 的 window, 用于显示 filepath.
    if not display_win_id and vim.fn.buflisted(bufnr) == 1 then
      display_win_id = win_id
    end
  end
  return display_win_id
end

--- 跳转到 file
---
--- @param absolute_path string
--- @param lnum integer
--- @param col integer
local function jump_to_file(absolute_path, lnum, col)
  lnum = lnum or 1
  col = col or 1

  --- 则选择合适的 window 显示文件.
  local display_win_id = find_win_to_jump(absolute_path)

  --- 进入 window
  if display_win_id and vim.fn.win_gotoid(display_win_id) == 1 then
    --- 如果 win_id 可以跳转, 则直接在该 window 中打开文件.
    vim.cmd.edit(absolute_path)
    vim.api.nvim_win_set_cursor(display_win_id, {lnum, col-1})
  else
    --- 如果 win_id 不能跳转, 则在 terminal 正上方创建一个新的 window 用于显示 log filepath
    vim.cmd.split({mods={split='leftabove'}, args={absolute_path}})
    vim.api.nvim_win_set_cursor(0, {lnum, col-1})
  end
end

--- 跳转到 directory
---
--- @param dir string
local function jump_to_dir(dir)
  --- NOTE: 新窗口中打开 dir, 因为 nvim-tree 设置 hijack_netrw=true & hijack_directories=true,
  --- 如果直接使用 `:edit dir` 会导致打开 dir 的窗口被关闭 (hijack).
  --- 如果 hijack_netrw=false & hijack_directories=false, 则这里可以使用 `:tabnew dir`
  vim.cmd.new(dir)
end

--- jump to file/directory
---
--- @param content string|nil filepath:{lnum}:{col}
local function jump(content)
  if not content then
    return
  end

  local r = parse.parse_content(content)
  if not r then
    return
  end

  if r.type == 'file' then
    jump_to_file(r.absolute_fp, r.lnum, r.col)
    return
  elseif r.type == 'directory' then
    jump_to_dir(r.absolute_fp)
    return
  end

  Notify('cannot open: "' .. content .. '"', "INFO", {timeout = 1500})
end

local M = {}

--- jump to <cword>
M.n_jump_cWORD = function() jump(vim.fn.expand('<cWORD>')) end

--- jump to VISUAL selected content
M.v_jump_selected = function() jump(vs.visual_selected(true)) end

return M
