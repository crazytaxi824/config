local wb_act = require('myplugins.wbl.actions')
local bimap = require('myplugins.wbl.bimap')


local M = {}

-- 相当于 :[N]buf
--
---@param idx integer
local function goto(idx)
  local curr_win = vim.api.nvim_get_current_win()
  local win_bufs = bimap.win_get_buf_list(curr_win)
  if not win_bufs then
    return
  end

  -- index 超出范围
  if idx < 1 or idx > #win_bufs then
    return
  end

  local bufnr = win_bufs[idx]
  if not vim.api.nvim_buf_is_valid(bufnr) then
    vim.notify('buffer is not valid', vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_win_set_buf(curr_win, win_bufs[idx])
end


---@param direction 'next'|'prev'
local function cycle(direction)
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_win_get_buf(curr_win)

  local win_bufs = bimap.win_get_buf_list(curr_win)
  if not win_bufs or #win_bufs <= 1 then
    return
  end

  local idx = bimap.win_index_buf(curr_win, curr_buf)
  if not idx then
    vim.notify("current buffer is not register to current window", vim.log.levels.ERROR)
    return
  end

  -- 根据 'prev' | 'next' 计算 buffer index
  local cycle_idx = idx < #win_bufs and idx+1 or 1
  if direction == 'prev' then
    cycle_idx = idx > 1 and idx-1 or #win_bufs
  end

  local bufnr = win_bufs[cycle_idx]
  vim.api.nvim_win_set_buf(curr_win, bufnr)
end


---@param opt 'left'|'right'|'others'
local function delete_buffers(opt)
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_win_get_buf(curr_win)

  local win_bufs = bimap.win_get_buf_list(curr_win)
  if not win_bufs then
    return
  end

  local idx = bimap.win_index_buf(curr_win, curr_buf)
  if not idx then
    vim.notify("current buffer is not register to current window", vim.log.levels.ERROR)
    return
  end

  local function _should_delete(i)
    if opt == 'left' then
      return i < idx
    elseif opt == 'right' then
      return i > idx
    end
    -- 'others'
    return i ~= idx
  end

  -- VVI: 必须倒序 unbind, 否则会造成 w.buf_list 删除不正确
  for i = #win_bufs, 1, -1 do
    local bufnr = win_bufs[i]
    if _should_delete(i) and not vim.bo[bufnr].modified then
      bimap.unbind_buf_idx({ win_id=curr_win, buf_idx=i })
    end
  end

  wb_act.set_winbar(curr_win, 'focused')
end


local function delete_current_buf()
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_win_get_buf(curr_win)

  if vim.bo[curr_buf].modified then
    vim.notify("cannot delete modified buffer", vim.log.levels.WARN)
    return
  end

  if not bimap.win_is_valid(curr_win) then
    -- floating window
    vim.api.nvim_win_close(curr_win, false)
    return
  end

  local win_bufs = bimap.win_get_buf_list(curr_win)
  if not win_bufs then
    return
  end

  if #win_bufs < 1 then
    vim.notify(string.format("current_win(%d) has no buffer", curr_win), vim.log.levels.ERROR)
    return
  elseif #win_bufs == 1 then
    if win_bufs[1] ~= curr_buf then
      vim.notify("win_bufs records error", vim.log.levels.ERROR)
      return
    end

    -- 如果 neovim 中有另一个 buflisted & buftype == '' 的 window 则 close window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if win ~= curr_win and vim.bo[buf].buflisted and vim.bo[buf].buftype == '' then
        vim.api.nvim_win_close(curr_win, false)
        return
      end
    end

    -- 如果 current window 是 neovim 中最后一个 buflisted window
    vim.notify("Cannot delete last 'buflisted' 'normal' buffer", vim.log.levels.WARN)
    return
  end

  -- 如果有多个 buffer, 则跳到另一个 buffer, 然后删除当前 buffer
  local prev_bufnr = vim.fn.bufnr('#')
  if prev_bufnr > 0 and vim.list_contains(win_bufs, prev_bufnr) then
    -- '#' buffer 在当前 window buffers list 中
    vim.api.nvim_win_set_buf(curr_win, prev_bufnr)
  else
    -- '#' buffer 不在当前 window buffers list 中
    local idx = bimap.win_index_buf(curr_win, curr_buf)
    if not idx then
      vim.notify("current buffer is not register to current window", vim.log.levels.ERROR)
      return
    end

    if idx == 1 then
      local next = idx < #win_bufs and idx+1 or 1
      vim.api.nvim_win_set_buf(curr_win, win_bufs[next])
    else
      local prev = idx > 1 and idx-1 or #win_bufs
      vim.api.nvim_win_set_buf(curr_win, win_bufs[prev])
    end
  end

  bimap.unbind({ win_id=curr_win, bufnr=curr_buf })

  wb_act.set_winbar(curr_win, 'focused')
end


-- list current window 中所有 win_buffers
local function list_win_buffers()
  local curr_win = vim.api.nvim_get_current_win()
  local win_bufs = bimap.win_get_buf_list(curr_win)
  if not win_bufs then
    return
  end

  -- 选择 buffer 进行跳转
  vim.ui.select(vim.fn.range(1, #win_bufs), {
    prompt = 'WinbarLine buffers',
    format_item = function(item)
      -- item is win_bufs index
      local bufnr = win_bufs[item]
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return '[Invalid Buffer]'
      end
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")
    end,
  }, function(choice)
    -- choice is win_bufs index
    if choice then
      local bufnr = win_bufs[choice]
      if not vim.api.nvim_buf_is_valid(bufnr) then
        vim.notify('buffer is not valid', vim.log.levels.ERROR)
        return
      end
      vim.api.nvim_win_set_buf(curr_win, bufnr)
    end
  end)
end


function M.set()
  local opt = { silent = true }
  local winbar_keymaps = {
    {'n', '<S-D-[>', function() cycle('prev') end, opt, 'buffer: go to Prev buffer'},
    {'n', '<S-D-]>', function() cycle('next')  end, opt, 'buffer: go to Next buffer'},
    {'n', '<S-D-w>', function()
      for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        -- NOTE: split window 中不会触发 BufWinEnter, 所以利用 WinResized 来解决.
        -- NOTE: "a buffer with read errors" 时所有的 buf events 都不会被触发, 同时会重置 setlocal winbar=''
        -- eg: [Permission Denied], LSP error ...
        -- window 中一定会显示一个 buffer
        wb_act.binding_win_buf({ win_id=win_id, bufnr=vim.api.nvim_win_get_buf(win_id) })
        wb_act.set_winbar(win_id, 'auto')
      end
    end, opt, 'win: refresh all winbarline'},

    {'n', '<leader>d', function() delete_current_buf() end, opt, 'buffer: Close Current Buffer/Tab'},
    {'n', '<leader>D<Left>', function() delete_buffers('left') end, opt, 'buffer: Close Left Side Buffers'},
    {'n', '<leader>D<Right>', function() delete_buffers('right') end, opt, 'buffer: Close Right Side Buffers'},
    {'n', '<leader>Da', function() delete_buffers('others') end, opt, 'buffer: Close all other buffers'},
    {'n', '<leader>\\', function()
      if vim.v.count == 0 then
        list_win_buffers()
      else
        goto(vim.v.count)
      end
    end , opt, 'win: show all buffers in current window'},
  }

  require('utils.keymaps').set(winbar_keymaps)
end

return M
