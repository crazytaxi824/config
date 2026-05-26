-- 跳转到 cursor 所在 filepath

local parser = require('utils.filepath.parser')
local vs = require('utils.visual_selected')

-- 在当前 tab 中选择合适的 window 用于显示文件
-- 优先选择已显示目标文件的 window，其次选择第一个 listed buffer window
--
---@param absolute_path string
---@return integer|nil
local function find_win_to_jump(absolute_path)
  local display_win_id

  -- 在当前 tab 中寻找第一个显示 listed-buffer 的 window, 用于显示 filepath.
  local tab_wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win_id in ipairs(tab_wins) do
    local bufnr = vim.api.nvim_win_get_buf(win_id)

    -- 寻找是否有 window 已经显示了指定文件.
    local buffer_fullpath = vim.api.nvim_buf_get_name(bufnr)
    if buffer_fullpath == absolute_path then
      display_win_id = win_id
      break
    end

    -- 记录当前 tab 中第一个显示 listed-buffer 的 window, 用于显示 filepath.
    if not display_win_id and vim.bo[bufnr].buflisted then
      display_win_id = win_id
    end
  end

  return display_win_id
end

-- 跳转到 file
--
---@param absolute_path string
---@param lnum? integer
---@param col? integer
local function jump_to_file(absolute_path, lnum, col)
  lnum = lnum or 1
  col = col or 1

  -- 则选择合适的 window 显示文件.
  local display_win_id = find_win_to_jump(absolute_path)

  -- 进入 window
  if display_win_id and vim.fn.win_gotoid(display_win_id) == 1 then
    -- 如果 win_id 可以跳转, 则直接在该 window 中打开文件.
    vim.cmd.edit(absolute_path)
    vim.api.nvim_win_set_cursor(display_win_id, {lnum, col-1})
  else
    -- 如果 win_id 不能跳转, 则在 terminal 正上方创建一个新的 window 用于显示 log filepath
    vim.cmd.split({ mods = { split = 'leftabove' }, args = { absolute_path } })
    vim.api.nvim_win_set_cursor(0, { lnum, col - 1 })
  end
end

-- 跳转到 directory
--
---@param dir string
local function jump_to_dir(dir)
  -- NOTE: 新窗口中打开 dir, 因为 nvim-tree 设置 hijack_netrw=true & hijack_directories=true,
  -- 如果直接使用 `:edit dir` 会导致打开 dir 的窗口被关闭 (hijack).
  -- 如果 hijack_netrw=false & hijack_directories=false, 则这里可以使用 `:tabnew dir`
  vim.cmd.new(dir)
end

-- jump to file/directory
--
---@param content string|nil filepath:{lnum}:{col}
local function jump(content)
  if not content then
    return
  end

  local r = parser.parse_content(content)
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

-- visual selected content, 不需要 parse
---@param v_selected? string filepath:{lnum}:{col}
local function v_jump(v_selected)
  if not v_selected then
    return
  end

  local splits = vim.split(v_selected, ':', { trimempty = false })
  if not splits[1] then
    return
  end

  local abs_path = vim.fs.abspath(splits[1])
  local lnum = tonumber(splits[2])  -- tonumber(nil) = nil
  local col = tonumber(splits[2])

  local finfo = vim.uv.fs_stat(abs_path)
  if not finfo then
    vim.notify(string.format("try open file: '%s', it is not a file or dir", v_selected), vim.log.levels.INFO)
    return
  end

  if finfo.type == 'file' then
    jump_to_file(abs_path, lnum, col)
    return
  elseif finfo.type == 'directory' then
    jump_to_dir(abs_path)
    return
  end

  vim.notify(string.format("try open file: '%s', it is not a file or dir", v_selected), vim.log.levels.INFO)
end

local M = {}

-- jump to <cword>
M.n_jump_cWORD = function() jump(vim.fn.expand('<cWORD>')) end

-- jump to VISUAL selected content
M.v_jump_selected = function() v_jump(vs.visual_selected(false)) end

return M
