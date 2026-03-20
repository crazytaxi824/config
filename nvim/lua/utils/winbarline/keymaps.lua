local wbvar = require('utils.winbarline.win_buf_var')
local wb = require('utils.winbarline.winbar')
local utils = require('utils.winbarline.utils')


--- 相当于 :[N]buf
---
--- @param idx integer
local function goto(idx)
  local curr_win = vim.api.nvim_get_current_win()
  local win_bufs = wbvar.get_win_bufs(curr_win)
  if not win_bufs then
    return
  end

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
local function cycle(move)
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_win_get_buf(curr_win)

  local win_bufs = wbvar.get_win_bufs(curr_win)
  if not win_bufs then
    return
  end

  local idx = utils.list_index_value(win_bufs, curr_buf)
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
local function delete_buffers(opt)
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_win_get_buf(curr_win)

  local win_bufs = wbvar.get_win_bufs(curr_win)
  if not win_bufs then
    return
  end

  local idx = utils.list_index_value(win_bufs, curr_buf)
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
  wbvar.set_win_bufs(curr_win, new_win_bufs)

  --- set buf_wins
  for _, d_buf in ipairs(delete_bufs) do
    wbvar.remove_win_from_buf(d_buf, curr_win)
  end

  wb.set_winbar(curr_win)
end


local function delete_current_buf()
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_win_get_buf(curr_win)

  if vim.bo[curr_buf].modified then
    Notify("cannot delete modified buffer")
    return
  end

  local win_bufs = wbvar.get_win_bufs(curr_win)
  if not win_bufs then
    --- floating window
    vim.api.nvim_win_close(curr_win, false)
    return
  end

  --- 如果 window 中只有最后一个 buffer 则. 创建一个新的 buffer.
  if #win_bufs <= 1 then
    local new_bufnr = vim.api.nvim_create_buf(true, false)

    --- nvim_win_set_buf() 不会触发 BufWinEnter
    vim.api.nvim_win_set_buf(curr_win, new_bufnr)

    wbvar.set_win_bufs(curr_win, { new_bufnr })
    wbvar.append_win_to_buf(new_bufnr, curr_win)
    wbvar.remove_win_from_buf(curr_buf, curr_win)

    wb.set_winbar(curr_win)
    return
  end

  --- 如果有多个 buffer, 则跳到另一个 buffer 后, 删除当前 buffer.
  local idx = utils.list_index_value(win_bufs, curr_buf)
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

  wbvar.remove_buf_from_win(curr_win, curr_buf)
  wbvar.remove_win_from_buf(curr_buf, curr_win)
  wb.set_winbar(curr_win)
end


--- set keymaps ------------------------------------------------------------------------------------
local opt = { silent = true }
local winbar_keymaps = {
  {'n', '<leader>\\', function() goto(vim.v.count1) end , opt, 'which_key_ignore'},
  {'n', '<S-D-[>', function() cycle('prev') end, opt, 'buffer: go to Prev buffer'},
  {'n', '<S-D-]>', function() cycle('next')  end, opt, 'buffer: go to Next buffer'},
  {'n', '<leader>d', function() delete_current_buf() end, opt, 'buffer: Close Current Buffer/Tab'},
  {'n', '<leader>D<Left>', function() delete_buffers('left') end, opt, 'buffer: Close Left Side Buffers'},
  {'n', '<leader>D<Right>', function() delete_buffers('right') end, opt, 'buffer: Close Right Side Buffers'},
  {'n', '<leader>Da', function() delete_buffers('others') end, opt, 'buffer: Close all other buffers'},
}

require('utils.keymaps').set(winbar_keymaps)

