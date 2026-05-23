local g = require('myplugins.winbarline.global')
local wb_win = require("myplugins.winbarline.winbar_win")
local wb_buf = require("myplugins.winbarline.winbar_buf")


---@param bufnr integer
---@param win_id integer
---@return WinbarLineWindow|nil
local function binding_win_buf(win_id, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  -- floating window 不显示 WinBarLine
  local win_cfg = vim.api.nvim_win_get_config(win_id)
  if win_cfg.relative ~= '' then
    return
  end

  local win = g.get_win(win_id)
  if win then
    win:append_buf(bufnr)
  else
    win = wb_win.new(win_id, bufnr, win_cfg.width)
    g.set_win(win)
  end

  local buf = g.get_buf(bufnr)
  if buf then
    buf:append_win(win_id)
  else
    buf = wb_buf.new(bufnr, win_id)
    g.set_buf(buf)
  end

  return win
end


-- autocmd ----------------------------------------------------------------------------------------
local gid = vim.api.nvim_create_augroup('my_winbarline', { clear = true })


-- bind/unbind buffer & window 之间的关联
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  group = gid,
  callback = function(args)
    local curr_win = vim.api.nvim_get_current_win()
    local w = binding_win_buf(curr_win, args.buf)
    if w then
      w:set_winbar()
    end
  end,
  desc = "winbarline: binding window and buffer"
})


-- buffer 所在的 windows 中清理 window-buffer list
vim.api.nvim_create_autocmd({"BufDelete", "BufWipeout"}, {
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
        w:set_winbar()
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
-- BufModifiedSet, BufWritePost 更新 modified indicator 状态
-- DiagnosticChanged 更新 diagnostic number & level 状态
-- FileChangedShellPost 外部程序对文件进行了改动, 更新 modified indicator 状态
vim.api.nvim_create_autocmd({
  "BufModifiedSet", "BufWritePost", "FileChangedShellPost", "DiagnosticChanged",
}, {
  group = gid,
  callback = function(args)
    local b = g.get_buf(args.buf)
    if not b then
      -- 有些 buffer 可能从没有 BufWinEnter, 例如 lsp 会自动加载 pkg 中的文件.
      return
    end

    for _, win_id in ipairs(b:list_wins()) do
      local w = g.get_win(win_id)
      if w then
        w:set_winbar()
      end
    end
  end,
  desc = "winbarline: buffer modified status"
})


-- 根据 window 变动更新 winbar
-- WinEnter 主要为了切换 selected buffer highlight
-- NOTE: 在 'WinResized' 事件中获取 window width 是准确的, 但是在 'WinEnter' 事件中获取的 window width 不准确.
vim.api.nvim_create_autocmd({"WinEnter"}, {
  group = gid,
  callback = function(args)
    -- refresh current window active buffer
    local curr_win = vim.api.nvim_get_current_win()
    local cw = g.get_win(curr_win)
    if cw then
      cw:set_winbar()
    end

    -- refresh previous window active buffer
    local prev_win = vim.fn.win_getid(vim.fn.winnr('#'))
    local pw = g.get_win(prev_win)
    if pw then
      pw:set_winbar()
    end
  end,
  desc = "winbarline: redraw selected buffer"
})

-- 'WinResized' 时需要更新所有正在显示的 (tab 中的) winbar
-- NOTE: WinNew -> WinEnter -> BufEnter -> BufWinEnter -> WinResized
-- 所以 WinResized 时获取的 buffer 和 win width 都是准确的, WinNew/WinEnter 时获取的是临时的.
vim.api.nvim_create_autocmd({"WinResized"}, {
  group = gid,
  callback = function(args)
    for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local w = g.get_win(win_id)
      if w then
        -- window width 改变了才更新 winbar
        local win_width = vim.api.nvim_win_get_width(win_id)
        if w.width ~= win_width then
          w:set_winbar(win_width)
        end
      else
        -- NOTE: split window 中不会触发 BufWinEnter, 所以利用 WinResized 来解决
        -- WinResized 在 BufWinEnter 之后触发
        -- window 中一定会显示一个 buffer
        w = binding_win_buf(win_id, vim.api.nvim_win_get_buf(win_id))
        if w then
          w:set_winbar()
        end
      end
    end
  end,
  desc = "winbarline: redraw buffers"
})


-- debug ------------------------------------------------------------------------------------------
vim.api.nvim_create_user_command("DebugWinbarLine", function()
  g:debug()
end, {})
