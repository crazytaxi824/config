local wbvar = require('utils.winbarline.win_buf_var')
local wb = require('utils.winbarline.winbar')


local gid = vim.api.nvim_create_augroup('my_winbarline', { clear = true })

vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  group = gid,
  callback = function(args)
    local curr_win = vim.api.nvim_get_current_win()

    --- floating window 不显示 WinBarLine
    local win_cfg = vim.api.nvim_win_get_config(curr_win)
    if win_cfg.relative ~= '' then
      return
    end

    wbvar.append_buf_to_win(curr_win, args.buf)
    wbvar.append_win_to_buf(args.buf, curr_win)

    wb.set_winbar(curr_win, true)
  end
})


--- buffer 所在的 windows 中清理 window-buffer list
vim.api.nvim_create_autocmd({"BufDelete", "BufWipeout"}, {
  group = gid,
  callback = function(args)
    local buf_wins = wbvar.get_buf_wins(args.buf)
    if not buf_wins then
      return
    end

    wbvar.delete_buf(args.buf)

    for win_id, _ in pairs(buf_wins) do
      wbvar.remove_buf_from_win(win_id, args.buf)
      wb.set_winbar(win_id, win_id == vim.api.nvim_get_current_win())
    end
  end
})


--- 从 window 的 buffers 中清理 buffer-window list
vim.api.nvim_create_autocmd({"WinClosed"}, {
  group = gid,
  callback = function(args)
    local win_id = tonumber(args.match)
    if not win_id then
      error("win_id error: " .. args.match)
    end

    local win_bufs = wbvar.get_win_bufs(win_id)
    if not win_bufs then
      return
    end

    wbvar.delete_win(win_id)

    for _, buf in ipairs(win_bufs) do
      wbvar.remove_win_from_buf(buf, win_id)
    end
  end
})


--- 需要更新当前 window winbar 的情况
-- vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
--   group = gid,
--   callback = function(args)
--     wb.set_winbar(vim.api.nvim_get_current_win(), true)
--   end
-- })


--- buffer 相关事件, 影响多个 window, 如果 buffer 被加入到多个 window 中
--- ModeChanged 可以影响 terminal
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP", "BufWritePost", "FileChangedShellPost", "DiagnosticChanged", "ModeChanged"}, {
  group = gid,
  callback = function(args)
    local buf_wins = wbvar.get_buf_wins(args.buf)
    if not buf_wins then
      return
    end

    for win_id, _ in pairs(buf_wins) do
      wb.set_winbar(win_id, win_id == vim.api.nvim_get_current_win())
    end
  end
})


--- window 修改后需要更新相关 winbar
vim.api.nvim_create_autocmd({"WinEnter", "WinLeave"}, {
  group = gid,
  callback = function(args)
    wb.set_winbar(vim.api.nvim_get_current_win(), args.event == 'WinEnter')
  end
})


--- Debug
function WinbarLine()
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    local win_bufs = wbvar.get_win_bufs(win_id)
    if win_bufs then
      print('win:', win_id, vim.inspect(win_bufs))
    end
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_wins = wbvar.get_buf_wins(buf)
    if buf_wins then
      print('buf:', buf, vim.inspect(vim.tbl_keys(buf_wins)))
    end
  end
end



