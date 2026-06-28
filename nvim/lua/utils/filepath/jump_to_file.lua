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
---@param lnum? integer  -- 1-based index
---@param col? integer   -- 1-based index, 传入时是 1-based
local function jump_to_file(absolute_path, lnum, col)
  -- 加载文件但不显示在 window 中
  -- 如果 filepath 不存在会创建一个新的 buffer 指向 filepath
  -- 如果 filepath == '', 会创建一个 [No Name] buffer
  local buf = vim.fn.bufadd(absolute_path)
  vim.fn.bufload(buf)  -- 加载 buffer 内容
  vim.bo[buf].buflisted = true  -- 设置为 buflisted
  local lcount = vim.api.nvim_buf_line_count(buf)  -- line total count

  -- check range
  lnum = math.max(1, math.min(lnum or 1, lcount))  -- 1-based index
  col = math.max(1, col or 1)  -- 1-based index, col > max_col 不会报错

  -- 选择合适的 window 显示文件
  local win_id = find_win_to_jump(absolute_path)

  -- 进入 window
  if win_id and vim.fn.win_gotoid(win_id) == 1 then
    -- 如果 win_id 可以跳转, 则直接在该 window 中打开 buffer
    vim.api.nvim_win_set_buf(win_id, buf)
  else
    -- 如果 win_id 不能跳转, 则在 current window 上方创建一个新的 window 用于显示 buffer
    win_id = vim.api.nvim_open_win(buf, true, { win = vim.api.nvim_get_current_win(), split = 'above' })
  end

  -- nvim_win_set_cursor() 中 col 是 0-based index
  vim.api.nvim_win_set_cursor(win_id, { lnum, col-1 })  -- move cursor
end

-- 跳转到 directory
--
---@param dir string
local function jump_to_dir(dir)
  -- 寻找 tabpage 中是否有显示 netrw 的 window.
  local netrw_win = -1
  for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    if vim.bo[bufnr].filetype == 'netrw' then
      netrw_win = win_id
      break
    end
  end

  if vim.fn.win_gotoid(netrw_win) == 1 then
    -- 进入 netrw_win, 然后 `:edit dir`
    vim.cmd.edit({ args={ vim.fn.fnameescape(dir) }})
  else
    -- 在整个 editor 最左侧打开一个 window, nvim_open_win() 无法实现
    -- vim.cmd("topleft 36vsplit " .. vim.fn.fnameescape(dir))
    vim.cmd.vsplit({ mods={ split="topleft" }, range={ 36 }, args={ vim.fn.fnameescape(dir) }})
  end

  -- 如果使用 nvim-tree 插件则使用 change_root() 切换到 dir
  local status_ok, nt_api = pcall(require, "nvim-tree.api")
  if status_ok then
    nt_api.tree.change_root(dir)
  end
end

-- jump to file/directory
--
---@param content? string filepath:{lnum}:{col}
local function jump(content)
  if not content or vim.trim(content) == "" then
    return
  end

  -- 防止内容太长造成卡顿
  if #content > 512 then
    return
  end

  local fp_props = parser.parse_fp_from_str(content)
  if not fp_props then
    return
  end

  if fp_props.type == 'file' then
    jump_to_file(fp_props.absolute_fp, fp_props.lnum, fp_props.col)
    return
  elseif fp_props.type == 'directory' then
    jump_to_dir(fp_props.absolute_fp)
    return
  end

  Notify(string.format('cannot open: "%s"', content), "INFO", {timeout = 1500})
end

-- visual selected content
---@param v_selected? string  必须是 exact {filepath}:{lnum}:{col}
local function v_jump(v_selected)
  if not v_selected or vim.trim(v_selected) == "" then
    return
  end

  -- 防止内容太长造成卡顿
  if #v_selected > 512 then
    return
  end

  local splits = vim.split(v_selected, ':', { trimempty = false })
  if not splits[1] then
    return
  end

  local abs_path = vim.fs.abspath(splits[1])
  local lnum = tonumber(splits[2])  -- tonumber(nil) = nil
  local col = tonumber(splits[3])

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
