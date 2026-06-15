local g = require('myplugins.winbarline.global')
local wb_act = require('myplugins.winbarline.winbar_actions')


-- autocmd ----------------------------------------------------------------------------------------
local gid = vim.api.nvim_create_augroup('my_winbarline', { clear = true })

-- bind buffer & window
-- "BufEnter" event 在每次 cursor enter buffer(window) 时触发, 可以用于更新 selected buffer highlight
-- nvim_win_set_buf() DOCS: As a side-effect, this executes |BufEnter| and |BufLeave|
vim.api.nvim_create_autocmd("BufEnter", {
  group = gid,
  callback = function(args)
    local curr_win = vim.api.nvim_get_current_win()
    local w = wb_act.binding_win_buf(curr_win, args.buf)
    if w then
      w:set_winbar('focused')
    end
  end,
  desc = "winbarline: binding window and buffer"
})


-- WinLeave 主要为了切换 selected buffer highlight
vim.api.nvim_create_autocmd("WinLeave", {
  group = gid,
  callback = function(args)
    local curr_win = vim.api.nvim_get_current_win()
    local w = wb_act.binding_win_buf(curr_win, args.buf)
    if w then
      -- WinLeave, BufLeave 时不是 focused window
      w:set_winbar()
    end
  end,
  desc = "winbarline: binding window and buffer"
})


-- buffer 所在的 windows 中清理 window-buffer list
vim.api.nvim_create_autocmd({"BufUnload", "BufDelete", "BufWipeout"}, {
  group = gid,
  callback = function(args)
    local buf = g.get_buf(args.buf)
    if not buf then
      -- 有些 buffer 可能从没有 BufWinEnter, 例如 lsp 会自动加载 pkg 中的文件.
      return
    end

    -- delete buf from all wins
    for _, win_id in ipairs(buf:list_wins()) do
      local w = g.get_win(win_id)
      if w then
        w:remove_buf(args.buf)
        w:set_winbar('auto')
      end
    end

    -- delete winbar_buf from cache
    g.delete_buf(args.buf)
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

    local w = g.get_win(win_id)
    if not w then
      return
    end

    -- 从每个 buf-window list 中删除 win
    for _, bufnr in ipairs(w:list_bufs()) do
      local b = g.get_buf(bufnr)
      if b then
        b:remove_win(win_id)
      else
        vim.notify(string.format('buffer: %d is not exist', bufnr), vim.log.levels.ERROR)
      end
    end

    -- delete winbar_win from cache
    g.delete_win(win_id)
  end,
  desc = "winbarline: remove window from all buffers"
})


-- 更新 winbar 显示 -------------------------------------------------------------------------------
-- 根据 buffer 变动更新 winbar 显示
-- 如果 buffer 被加入到多个 window 中, 则影响多个 window

---@param bufnr integer
local function buf_update_winbar(bufnr)
  local b = g.get_buf(bufnr)
  if not b then
    -- 有些 buffer 可能从没有 BufWinEnter, 例如 lsp 会自动加载 pkg 中的文件.
    return
  end

  -- 更新所有加载该 buffer 的 window winbarline
  for _, win_id in ipairs(b:list_wins()) do
    local w = g.get_win(win_id)
    if w then
      w:set_winbar('auto')
    end
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

-- "DiagnosticChanged" 会多次触发
-- 优化为: 使用防抖函数, 所有 diagnostic 执行完之后再更新整个 winbar 状态
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = gid,
  callback = function(args)
    local b = g.get_buf(args.buf)
    if not b then
      -- 有些 buffer 可能从没有 BufWinEnter, 例如 lsp 会自动加载 pkg 中的文件.
      return
    end

    -- 更新所有加载该 buffer 的 window winbarline
    for _, win_id in ipairs(b:list_wins()) do
      local w = g.get_win(win_id)
      if w then
        w:set_winbar_debounce('auto')
      end
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
    for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      -- NOTE: split window 中不会触发 BufWinEnter, 所以利用 WinResized 来解决.
      -- NOTE: "a buffer with read errors" 时所有的 buf events 都不会被触发, 同时会重置 setlocal winbar=''
      -- eg: [Permission Denied], LSP error ...
      -- window 中一定会显示一个 buffer
      local w = wb_act.binding_win_buf(win_id, vim.api.nvim_win_get_buf(win_id))
      if w then
        w:set_winbar('auto')
      end
    end
  end,
  desc = "winbarline: redraw buffers"
})



