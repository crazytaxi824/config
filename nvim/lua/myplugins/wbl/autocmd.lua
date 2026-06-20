local wb_act = require('myplugins.wbl.actions')
local bimap = require('myplugins.wbl.bimap')

-- cache previous window id & tabpage
local prev_win_id = -1
local prev_tabpage = -1

-- 更新整个 current tabpage windows
local function update_current_tabpage_wins()
  for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- NOTE: split window 中不会触发 BufWinEnter, 所以利用 WinResized 来解决.
    -- NOTE: "a buffer with read errors" 时所有的后续 events 都不会被触发, 同时会重置 setlocal winbar=''
    -- eg: [Permission Denied], LSP error ...
    -- window 中一定会显示一个 buffer
    if wb_act.binding_win_buf({ win_id=win_id, bufnr=vim.api.nvim_win_get_buf(win_id) }) then
      wb_act.set_winbar(win_id, 'auto')
    end
  end
end

-- autocmd ----------------------------------------------------------------------------------------
local gid = vim.api.nvim_create_augroup('my_winbarline', { clear = true })

-- WinLeave 主要为了切换 selected buffer highlight
vim.api.nvim_create_autocmd("WinLeave", {
  group = gid,
  callback = function(args)
    prev_win_id = vim.api.nvim_get_current_win()
    prev_tabpage = vim.api.nvim_get_current_tabpage()
  end,
  desc = "winbarline: cache win_id & tabpage when leave window"
})


vim.api.nvim_create_autocmd("WinEnter", {
  group = gid,
  callback = function(args)
    local curr_win = vim.api.nvim_get_current_win()
    local curr_tabpage = vim.api.nvim_get_current_tabpage()

    if prev_tabpage > 0 and prev_tabpage ~= curr_tabpage then
      -- 从 another tabpage 跳转过来 (prev_tabpage 可能已经关闭)
      -- 更新整个 current tabpage windows, 主要是为了显示 tabpage
      update_current_tabpage_wins()
    else
      -- 从 current tabpage & another window 跳转过来 (prev_win 可能已经关闭)
      -- 更新 previous winow
      if vim.api.nvim_win_is_valid(prev_win_id) then
        if wb_act.binding_win_buf({ win_id=prev_win_id, bufnr=vim.api.nvim_win_get_buf(prev_win_id) }) then
          wb_act.set_winbar(prev_win_id)
        end
      end

      -- 更新 current window
      -- NOTE: DONOT binding_win_buf, WinEnter 中 args.buf 是 previous window 中的 buffer
      wb_act.set_winbar(curr_win, 'focused')
    end

    -- NOTE: 重置 cache. 防止没有切换 window, 只是 `:e foo.txt` 加载文件时更新 previous window
    prev_win_id = -1
    prev_tabpage = -1
  end,
  desc = "winbarline: binding window and buffer"
})


-- bind buffer & window
-- "BufEnter" event 在每次 cursor enter buffer(window) 时触发, 可以用于更新 selected buffer highlight
-- nvim_win_set_buf() DOCS: As a side-effect, this executes |BufEnter| and |BufLeave|
vim.api.nvim_create_autocmd("BufEnter", {
  group = gid,
  callback = function(args)
    local curr_win = vim.api.nvim_get_current_win()
    if wb_act.binding_win_buf({ win_id=curr_win, bufnr=args.buf }) then
      wb_act.set_winbar(curr_win, 'focused')
    end
  end,
  desc = "winbarline: binding current window and buffer"
})


-- buffer 所在的 windows 中清理 window-buffer list
vim.api.nvim_create_autocmd({"BufUnload", "BufDelete", "BufWipeout"}, {
  group = gid,
  callback = function(args)
    if not bimap.buf_is_valid(args.buf) then
      return
    end

    local affected_win_dict = bimap.remove_buf(args.buf)
    if affected_win_dict then
      for win_id, _ in pairs(affected_win_dict) do
        wb_act.set_winbar(win_id, 'auto')
      end
    end
  end,
  desc = "winbarline: remove buffer from all windows"
})

-- 从 window 的 buffers 中清理 buffer-window list
-- 'WinClosed' 包含了 'TabClosed' 情况
vim.api.nvim_create_autocmd({"WinClosed"}, {
  group = gid,
  callback = function(args)
    local win_id = tonumber(args.match)
    if not win_id then
      error("win_id error: " .. args.match)
    end

    bimap.remove_win(win_id)
  end,
  desc = "winbarline: remove window from all buffers"
})


-- 更新 winbar 显示 -------------------------------------------------------------------------------
-- 根据 buffer 变动更新 winbar 显示
-- 如果 buffer 被加入到多个 window 中, 则影响多个 window

---@param bufnr integer
local function buf_update_winbar(bufnr)
  local win_dict = bimap.buf_get_win_dict(bufnr)
  if not win_dict then
    return
  end

  -- 更新所有加载该 buffer 的 window winbarline
  for win_id, _ in pairs(win_dict) do
    wb_act.set_winbar(win_id, 'auto')
  end
end


-- "BufModifiedSet" 更新 modified indicator 状态
-- NOTE: v0.13+ 中 "BufModifiedSet" 被舍弃了, https://github.com/nvim-tree/nvim-tree.lua/issues/3324
-- 在 v0.13+ 中只有输入第一个字符时才会触发一次 OptionSet modified. 后续继续输入字符, 不会重复触发.
local update_events = {"BufWritePost", "FileChangedShellPost", "BufModifiedSet"}
if vim.fn.has("nvim-0.13") == 1 then
  update_events = {"BufWritePost", "FileChangedShellPost"}
end

vim.api.nvim_create_autocmd('OptionSet', {
  group = gid,
  pattern = "modified",
  callback = function(args)
    -- opt 没有变的情况
    if vim.v.option_old == vim.v.option_new then
      return
    end

    -- NOTE: OptionSet 中 args.buf 没有用
    buf_update_winbar(vim.api.nvim_get_current_buf())
  end,
  desc = "winbarline: update buffer modified status",
})


-- BufWritePost 更新 modified indicator 状态
-- DiagnosticChanged 更新 diagnostic number & level 状态
-- FileChangedShellPost 外部程序对文件进行了改动, 更新 modified indicator 状态
vim.api.nvim_create_autocmd(update_events, {
  group = gid,
  callback = function(args)
    buf_update_winbar(args.buf)
  end,
  desc = "winbarline: update buffer modified status",
})


-- DiagnosticChanged 会多次触发，直接更新所有显示该 buffer 的窗口
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = gid,
  callback = function(args)
    local win_dict = bimap.buf_get_win_dict(args.buf)
    if not win_dict then
      return
    end

    -- 更新所有加载该 buffer 的 window winbarline
    for win_id, _ in pairs(win_dict) do
      wb_act.set_winbar(win_id, 'auto')
    end
  end,
  desc = "winbarline: update buffer diagnostic status",
})


-- 'WinResized' 时需要更新所有正在显示的 (tab 中的) winbar
-- NOTE: WinNew -> WinEnter -> BufEnter -> BufWinEnter -> WinResized
-- 所以 WinResized 时获取的 buffer 和 win width 都是准确的, WinNew/WinEnter 时获取的是临时的.
vim.api.nvim_create_autocmd({"WinResized"}, {
  group = gid,
  callback = function(args)
    -- 更新整个 current tabpage windows
    update_current_tabpage_wins()
  end,
  desc = "winbarline: refresh all wins when window resized"
})



