local utils = require('utils.winbarline.utils')


--- autocmd ----------------------------------------------------------------------------------------
local gid = vim.api.nvim_create_augroup(utils.winvar, { clear = true })

vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  group = gid,
  callback = function(args)
    local win_id = vim.api.nvim_get_current_win()

    --- floating window 不显示 WinBarLine
    local win_cfg = vim.api.nvim_win_get_config(win_id)
    if win_cfg.relative ~= '' then
      return
    end

    local win_bufs = vim.w[win_id][utils.winvar] or {}
    if not vim.list_contains(win_bufs, args.buf) then
      table.insert(win_bufs, args.buf)
    end
    vim.w[win_id][utils.winvar] = win_bufs

    --- 如果 bufname 存在则直接渲染.
    --- 如果 bufname == '' 则延迟用于获取准确的 bufname.
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname ~= '' then
      utils.set_winbar(win_id, true)
    else
      vim.schedule(function() utils.set_winbar(win_id, true) end)
    end
  end
})


--- 从所有的 window buffer list 中删除 buf
vim.api.nvim_create_autocmd({"BufDelete"}, {
  group = gid,
  callback = function(args)
    local current_win = vim.api.nvim_get_current_win()
    local wins = vim.api.nvim_list_wins()
    for _, win_id in ipairs(wins) do
      local win_bufs = vim.w[win_id][utils.winvar] or {}  --- @type integer[]
      utils.list_remove_value(win_bufs, args.buf)
      vim.w[win_id][utils.winvar] = win_bufs
      utils.set_winbar(win_id, win_id == current_win)
    end
  end
})


--- 更新 winbar
vim.api.nvim_create_autocmd({"WinEnter", "WinLeave"}, {
  group = gid,
  callback = function(args)
    local win_id = vim.api.nvim_get_current_win()
    utils.set_winbar(win_id, args.event == 'WinEnter')
  end
})


--- 更新 winbar
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP", "BufWritePost"}, {
  group = gid,
  callback = function(args)
    local current_win = vim.api.nvim_get_current_win()
    local wins = vim.api.nvim_list_wins()
    for _, win_id in ipairs(wins) do
      utils.set_winbar(win_id, win_id == current_win)
    end
  end
})


--- Debug
function WinbarLine()
  local wins = vim.api.nvim_list_wins()
  for _, win_id in ipairs(wins) do
    print(win_id, vim.inspect(vim.w[win_id][utils.winvar]))
  end
end



