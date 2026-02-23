local g = require('utils.my_term.deps.global')

local M = {}

--- 寻找已有的最后 (last) my_term window ID, 不包括 normal terminal window.
---
---@return integer win_id
local function find_exist_term_win()
  local win_id = -1

  for _, term_obj in pairs(g.global_my_term_cache) do
    if vim.api.nvim_buf_is_valid(term_obj.bufnr) then
      local term_wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
      for _, w in ipairs(term_wins) do
        if w > win_id then
          win_id = w
        end
      end
    end
  end

  return win_id
end

--- create/re-use, enter `win_gotoid(win_id)` 一个 window 用于 jobstart() 运行.
---
---@param bufnr integer
---@return integer win_id
function M.create_term_win(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    error("bufnr is not exist")
  end

  local exist_win_id = find_exist_term_win()

  if vim.fn.win_gotoid(exist_win_id)==1 then
    --- at least 1 terminal window exist, 在该 my_term win 右边创建一个新的 my_term window
    return vim.api.nvim_open_win(bufnr, true, { win = exist_win_id, split = 'right' })
  else
    --- no terminal window exist, create a botright window for terminals.
    return vim.api.nvim_open_win(bufnr, true, { height = g.win_height, split = 'below' })
  end
end

--- 打开/创建, 并且进入(win_gotoid) terminal window 用于 jobstart()
---
--- NOTE: buffer 一旦运行过 jobstart() 就不能再次运行 jobstart() 了, Can only call this function in an unmodified buffer.
--- 所以需要删除旧的 bufnr 然后重新创建一个新的 scratch bufnr 给 jobstart() 使用.
---
---@param curr_term_bufnr integer
---@param old_term_bufnr? integer
---@return integer win_id
function M.enter_term_win(curr_term_bufnr, old_term_bufnr)
  --- 如果 old_term_bufnr 不存在: 创建一个新的 term window 用于加载 new term.bufnr
  if not old_term_bufnr or not vim.api.nvim_buf_is_valid(old_term_bufnr) then
    return M.create_term_win(curr_term_bufnr)
  end

  --- 这里是为了 re-use term window
  ---@type integer
  local win_id

  --- 获取 old_term_bufnr 所在的 windows id.
  local old_term_wins = vim.fn.getbufinfo(old_term_bufnr)[1].windows

  if #old_term_wins > 0 then
    --- 如果 old term buffer 存在, 同时 window 存在: 使用该 window 中加载 new term.bufnr
    win_id = old_term_wins[1]

    if vim.fn.win_gotoid(win_id) == 1 then
      vim.api.nvim_win_set_buf(win_id, curr_term_bufnr)  -- 将 bufnr 加载到指定 win_id.
    else
      error("term_win_id: " .. win_id .. " is not exist")
    end

  else
    --- 如果 old term buffer 存在, 但是 window 不存在: 创建一个新的 term window 加载 new term.bufnr.
    win_id = M.create_term_win(curr_term_bufnr)
  end

  --- NOTE: 放在最后避免 delete(old_term_bufnr) 时关闭了 old_term_wins.
  vim.api.nvim_buf_delete(old_term_bufnr, {force=true})

  return win_id
end

return M
