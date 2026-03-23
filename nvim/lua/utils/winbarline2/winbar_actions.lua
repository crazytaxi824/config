local wb_win = require("utils.winbarline2.winbar_win")
local wb_buf = require("utils.winbarline2.winbar_buf")
local g = require('utils.winbarline2.global')
local u = require('utils.winbarline2.utils')



local M = {}

---@param bufnr integer
---@param win_id integer
---@return WinbarLineWindow
function M.binding_win_buf(win_id, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  local win = g.wins[win_id]
  if win then
    win:append_buf(bufnr)
  else
    win = wb_win.new(win_id, bufnr)
    g.wins[win_id] = win
  end

  local buf = g.bufs[bufnr]
  if buf then
    buf:append_win(win_id)
  else
    buf = wb_buf.new(bufnr, win_id)
    g.bufs[bufnr] = buf
  end

  return win
end


---@param bufnr integer
---@param win_id integer
---@return WinbarLineWindow
function M.unbind_win_buf(win_id, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  local win = g.wins[win_id]
  if not win then
    error("win: " .. win_id .. " is not exist")
  end

  local buf = g.bufs[bufnr]
  if not buf then
    error("buffer: " .. bufnr .. " is not exist")
  end

  buf:remove_win(win_id)
  win:remove_buf(bufnr)

  return win
end


--- 相当于 :[N]buf
---
--- @param idx integer
function M.goto(idx)
  local curr_win = vim.api.nvim_get_current_win()
  local w = g.wins[curr_win]
  if not w then
    return
  end

  local win_bufs = w:list_bufs()
  local bufnr = win_bufs[idx]
  if not bufnr then
    return
  end

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_win_set_buf(curr_win, win_bufs[idx])
end

--- @param move 'next'|'prev'
function M.cycle(move)
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_win_get_buf(curr_win)

  local w = g.wins[curr_win]
  if not w then
    return
  end

  local win_bufs = w:list_bufs()
  local idx = u.list_index_value(win_bufs, curr_buf)
  if not idx then
    error("current buffer is not register to current window")
  end

  if move == 'next' then
    local next = idx < #win_bufs and idx+1 or 1
    if vim.api.nvim_buf_is_valid(win_bufs[next]) then
      vim.api.nvim_win_set_buf(curr_win, win_bufs[next])
    else
      error('buffer is not valid')
    end
  elseif move == 'prev' then
    local prev = idx > 1 and idx-1 or #win_bufs
    if vim.api.nvim_buf_is_valid(win_bufs[prev]) then
      vim.api.nvim_win_set_buf(curr_win, win_bufs[prev])
    else
      error('buffer is not valid')
    end
  else
    error('move error: ' .. move)
  end
end


--- @param opt 'left'|'right'|'others'
function M.delete_buffers(opt)
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_win_get_buf(curr_win)

  local w = g.wins[curr_win]
  if not w then
    return
  end

  local win_bufs = w:list_bufs()
  local idx = u.list_index_value(win_bufs, curr_buf)
  if not idx then
    error("current buffer is not in the win_bufs")
  end

  local delete_bufs = {}
  local new_win_bufs = {}

  if opt == 'left' then
    for i, buf in ipairs(win_bufs) do
      if i < idx then
        table.insert(delete_bufs, buf)
      else
        table.insert(new_win_bufs, buf)
      end
    end
  elseif opt == 'right' then
    for i, buf in ipairs(win_bufs) do
      if i <= idx then
        table.insert(new_win_bufs, buf)
      else
        table.insert(delete_bufs, buf)
      end
    end
  elseif opt == 'others' then
    new_win_bufs = { curr_buf }
    for i, buf in ipairs(win_bufs) do
      if i ~= idx then
        table.insert(delete_bufs, buf)
      end
    end
  else
    error('opt value error: ' .. opt)
  end

  --- set win_bufs
  w:set_bufs(new_win_bufs)

  --- set buf_wins
  for _, d_buf in ipairs(delete_bufs) do
    local b = g.bufs[d_buf]
    b:remove_win(curr_win)
  end

  w:set_winbar()
end


function M.delete_current_buf()
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_win_get_buf(curr_win)

  if vim.bo[curr_buf].modified then
    Notify("cannot delete modified buffer")
    return
  end

  local w = g.wins[curr_win]
  if not w then
    --- floating window
    vim.api.nvim_win_close(curr_win, false)
    return
  end

  local win_bufs = w:list_bufs()
  if #win_bufs <= 1 then
    if win_bufs[1] ~= curr_buf then
      error("win_bufs records error")
    end

    --- 如果 neovim 中有另一个 buflisted & buftype == '' 的 window 则 close window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if win ~= curr_win and vim.bo[buf].buflisted and vim.bo[buf].buftype == '' then
        vim.api.nvim_win_close(curr_win, false)
        return
      end
    end

    --- 如果 current window 是 neovim 中最后一个 buflisted window
    Notify("Cannot delete last 'buflisted' 'normal' buffer", "WARN")
    return
  end

  --- 如果有多个 buffer, 则跳到另一个 buffer 后, 删除当前 buffer
  local idx = u.list_index_value(win_bufs, curr_buf)
  if not idx then
    error("current buffer is not register to current  window")
  end

  if idx == 1 then
    local next = idx < #win_bufs and idx+1 or 1
    if vim.api.nvim_buf_is_valid(win_bufs[next]) then
      vim.api.nvim_win_set_buf(curr_win, win_bufs[next])
    else
      error('buffer is not valid')
    end
  else
    local prev = idx > 1 and idx-1 or #win_bufs
    if vim.api.nvim_buf_is_valid(win_bufs[prev]) then
      vim.api.nvim_win_set_buf(curr_win, win_bufs[prev])
    else
      error('buffer is not valid')
    end
  end


  local b = g.bufs[curr_buf]
  if not b then
    error("buffer: ".. curr_buf .. ' is not exist')
  end

  b:remove_win(curr_win)
  w:remove_buf(curr_buf)

  w:set_winbar()
end

return M
