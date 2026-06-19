-- 按照 nvim_win_set/get_buf() 设计

-- buf_list: 记录 bufnr 顺序
---@alias WBLWindow { win_id: integer, buf_list: integer[] }

-- win_dict: 记录 wins
---@alias WBLBuffer { bufnr: integer, win_dict: table<integer, boolean> }


local M = {}

---@type table<integer, WBLBuffer>
local bufs = {}

---@type table<integer, WBLWindow>
local wins = {}


-- 找出 value 在 list 中的 index
--
---@generic T
---@param list T[]
---@param val T
---@return integer|nil
local function list_index_value(list, val)
  for i, v in ipairs(list) do
    if v == val then
      return i
    end
  end
end

---@param w WBLWindow
---@param bufnr integer
local function win_remove_buf(w, bufnr)
  local buf_idx = list_index_value(w.buf_list, bufnr)
  if buf_idx then
    table.remove(w.buf_list, buf_idx)
  end
end

---@param b WBLBuffer
---@param win_id integer
local function buf_remove_win(b, win_id)
  b.win_dict[win_id] = nil
  -- remove buf from cache if win_dict is empty
  if vim.tbl_isempty(b.win_dict) then
    bufs[b.bufnr] = nil
  end
end

---@param opts { win_id: integer, bufnr: integer }
function M.bind(opts)
  local w = wins[opts.win_id]  ---@type WBLWindow
  if w then
    if not list_index_value(w.buf_list, opts.bufnr) then
      table.insert(w.buf_list, opts.bufnr)
    end
  else
    w = {
      win_id = opts.win_id,
      buf_list = { opts.bufnr },
    }
    wins[opts.win_id] = w
  end

  local b = bufs[opts.bufnr]  ---@type WBLBuffer
  if b then
    b.win_dict[opts.win_id] = true
  else
    b = {
      bufnr = opts.bufnr,
      win_dict = { [opts.win_id] = true },
    }
    bufs[opts.bufnr] = b
  end
end

-- unbind from buf index in win
-- 节省 list_index_value() 计算
--
---@param opts { win_id: integer, buf_idx: integer }
function M.unbind_buf_idx(opts)
  -- NOTE: 确保双向都存在的情况下再 unbind
  local w = wins[opts.win_id]  ---@type WBLWindow
  if not w then
    return
  end

  local bufnr = w.buf_list[opts.buf_idx]
  if not bufnr then
    return
  end

  local b = bufs[bufnr]
  if not b then
    vim.notify(string.format("bufnr(%s) is not cached in WinbarLine", bufnr), vim.log.levels.ERROR)
    return
  end

  -- 节省 list_index_value 计算
  table.remove(w.buf_list, opts.buf_idx)
  buf_remove_win(b, opts.win_id)
end

-- NOTE: 确保双向都存在的情况下再 unbind
--
---@param opts { win_id: integer, bufnr: integer }
function M.unbind(opts)
  local w = wins[opts.win_id]  ---@type WBLWindow
  local b = bufs[opts.bufnr]   ---@type WBLBuffer
  if not w or not b then
    return
  end

  win_remove_buf(w, opts.bufnr)
  buf_remove_win(b, opts.win_id)
end

---@param win_id integer
---@param bufnr integer
---@return integer|nil index
function M.win_index_buf(win_id, bufnr)
  local w = wins[win_id]  ---@type WBLWindow
  if w then
    return list_index_value(w.buf_list, bufnr)
  end
end

---@param win_id integer
---@return integer[]|nil buf_list
function M.win_get_buf_list(win_id)
  local w = wins[win_id]  ---@type WBLWindow
  if w then
    return w.buf_list
  end
end

---@param bufnr integer
---@return table<integer, boolean>|nil win_dict
function M.buf_get_win_dict(bufnr)
  local b = bufs[bufnr]   ---@type WBLBuffer
  if b then
    return b.win_dict
  end
end

---@param win_id integer
---@return integer[]|nil affected_buf_list
function M.remove_win(win_id)
  local w = wins[win_id]  ---@type WBLWindow
  if not w then
    return
  end

  -- remove win_id from all buffer
  for _, bufnr in ipairs(w.buf_list) do
    local b = bufs[bufnr]   ---@type WBLBuffer
    if b then
      buf_remove_win(b, win_id)
    else
      vim.notify(string.format("buffer:(%s) is not cached", bufnr), vim.log.levels.ERROR)
    end
  end

  -- remove win from cache
  wins[win_id] = nil
  return w.buf_list
end

---@param bufnr integer
---@return table<integer, boolean>|nil affected_win_dict
function M.remove_buf(bufnr)
  local b = bufs[bufnr]   ---@type WBLBuffer
  if not b then
    return
  end

  -- remove bufnr from all win
  for win_id, _ in pairs(b.win_dict) do
    local w = wins[win_id]  ---@type WBLWindow
    if w then
      win_remove_buf(w, bufnr)
    else
      vim.notify(string.format("win(%s) is not cached", win_id), vim.log.levels.ERROR)
    end
  end

  -- remove buf from cache
  bufs[bufnr] = nil
  return b.win_dict
end

---@param win_id integer
---@return boolean|nil valid
function M.win_is_valid(win_id)
  if wins[win_id] then
    return true
  end
end

---@param bufnr integer
---@return boolean|nil valid
function M.buf_is_valid(bufnr)
  if bufs[bufnr] then
    return true
  end
end

-- debug ------------------------------------------------------------------------------------------
__Debug.WBL = function()
  for win_id, _ in pairs(wins) do
    print('win:', win_id, vim.inspect(wins[win_id].buf_list))
  end

  for bufnr, _ in pairs(bufs) do
    print('buf:', bufnr, vim.inspect(vim.tbl_keys(bufs[bufnr].win_dict)))
  end
end


vim.api.nvim_create_user_command("DebugWBL", function()
  -- params.args: string
  -- params.fargs: string[]
  __Debug.WBL()
end,
{
  nargs = 0,
  bang = true,
  bar = true,
  desc = 'show WinbarLine cached wins and bufs',
})


return M
