local g = require('utils.winbarline.global')
local wb_win = require("utils.winbarline.winbar_win")
local wb_buf = require("utils.winbarline.winbar_buf")


--- get current window id, floating window is excluded
---
--- @return integer|nil curr_win_id
local function get_current_normal_win()
  local curr_win = vim.api.nvim_get_current_win()

  --- floating window 不显示 WinBarLine
  local win_cfg = vim.api.nvim_win_get_config(curr_win)
  if win_cfg.relative == '' then
    return curr_win
  end
end


---@param bufnr integer
---@param win_id integer
---@return WinbarLineWindow
local function binding_win_buf(win_id, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  local win = g.get_win(win_id)
  if win then
    win:append_buf(bufnr)
  else
    win = wb_win.new(win_id, bufnr)
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


--- autocmd ----------------------------------------------------------------------------------------
local gid = vim.api.nvim_create_augroup('my_winbarline', { clear = true })


--- bind/unbind buffer & window 之间的关联
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  group = gid,
  callback = function(args)
    local curr_win = get_current_normal_win()
    if not curr_win then
      return
    end

    local w = binding_win_buf(curr_win, args.buf)
    w:set_winbar()
  end
})

--- split window 中不会触发 BufWinEnter, 所以利用 CursorMoved 来解决.
vim.api.nvim_create_autocmd({"CursorMoved"}, {
  group = gid,
  callback = function(args)
    local curr_win = get_current_normal_win()
    if not curr_win then
      return
    end

    --- window 中一定会显示一个 buffer
    if not g.get_win(curr_win) then
      local w = binding_win_buf(curr_win, args.buf)
      w:set_winbar()
    end
  end
})

--- buffer 所在的 windows 中清理 window-buffer list
vim.api.nvim_create_autocmd({"BufDelete", "BufWipeout"}, {
  group = gid,
  callback = function(args)
    local buf = g.get_buf(args.buf)
    if not buf then
      --- 有些 buffer 可能从没有 BufWinEnter, 例如 lsp 会自动加载 pkg 中的文件.
      return
    end

    --- delete buf from all wins
    for _, win_id in ipairs(buf:list_wins()) do
      local w = g.get_win(win_id)
      if w then
        w:remove_buf(args.buf)
        w:set_winbar()
      end
    end

    --- delete winbar_buf from cache
    g.delete_buf(args.buf)
  end
})

--- 从 window 的 buffers 中清理 buffer-window list
--- 'WinClosed' 包含了 'TabClosed' 情况
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

    --- 从每个 buf-window list 中删除 win
    for _, bufnr in ipairs(w:list_bufs()) do
      local b = g.get_buf(bufnr)
      if not b then
        error('buffer: '.. bufnr .. ' is not exist')
      end
      b:remove_win(win_id)
    end

    --- delete winbar_win from cache
    g.delete_win(win_id)
  end
})


--- 更新 winbar 显示 -------------------------------------------------------------------------------
--- 根据 buffer 变动更新 winbar 显示
--- 如果 buffer 被加入到多个 window 中, 则影响多个 window
--- 'ModeChanged' 可以影响 terminal
vim.api.nvim_create_autocmd({
  "BufModifiedSet", "ModeChanged",
  "BufWritePost", "FileChangedShellPost", "DiagnosticChanged",
}, {
  group = gid,
  callback = function(args)
    local b = g.get_buf(args.buf)
    if not b then
      --- 有些 buffer 可能从没有 BufWinEnter, 例如 lsp 会自动加载 pkg 中的文件.
      return
    end

    for _, win_id in ipairs(b:list_wins()) do
      local w = g.get_win(win_id)
      if w then
        w:set_winbar()
      end
    end
  end
})


--- 根据 window 变动更新 winbar
vim.api.nvim_create_autocmd({"WinEnter"}, {
  group = gid,
  callback = function(args)
    --- 修改 current window 的 winbar
    local curr_win = get_current_normal_win()
    if not curr_win then
      return
    end

    local cw = g.get_win(curr_win)
    if cw then
      cw:set_winbar()
    end

    --- 修改 preview window 的 winbar
    local prev_winnr = vim.fn.winnr('#')
    if prev_winnr > 0 then
      local prev_win_id = vim.fn.win_getid(prev_winnr)
      local pw = g.get_win(prev_win_id)
      if pw then
        pw:set_winbar()
      end
    end
  end
})

--- 根据 window 变动更新 winbar
--- 'WinResized' 时需要更新所有正在显示的 (tab 中的) window, 因为 event 只会返回一个 window 的 id
vim.api.nvim_create_autocmd({"WinResized"}, {
  group = gid,
  callback = function(args)
    for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local w = g.get_win(win_id)
      if w then
        w:set_winbar()
      end
    end
  end
})


--- debug ------------------------------------------------------------------------------------------
function Get_WinbarLine()
  g:debug()
end
