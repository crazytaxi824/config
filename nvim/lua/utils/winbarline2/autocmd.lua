local g = require('utils.winbarline2.global')
local wb_act = require('utils.winbarline2.winbar_actions')


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


--- autocmd ----------------------------------------------------------------------------------------
local gid = vim.api.nvim_create_augroup('my_winbarline', { clear = true })

vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  group = gid,
  callback = function(args)
    local curr_win = get_current_normal_win()
    if not curr_win then
      return
    end

    local w = wb_act.binding_win_buf(curr_win, args.buf)
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
    if not g.wins[curr_win] then
      local w = wb_act.binding_win_buf(curr_win, args.buf)
      w:set_winbar()
    end
  end
})

--- buffer 所在的 windows 中清理 window-buffer list
vim.api.nvim_create_autocmd({"BufDelete", "BufWipeout"}, {
  group = gid,
  callback = function(args)
    local buf = g.bufs[args.buf]
    if not buf then
      return
    end

    --- delete buf from all wins
    for _, win_id in ipairs(buf:list_wins()) do
      local w = g.wins[win_id]
      if w then
        w:remove_buf(args.buf)
        w:set_winbar()
      end
    end

    --- delete winbar_buf from cache
    g.bufs[args.buf] = nil
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

    local w = g.wins[win_id]
    if not w then
      return
    end

    --- 从每个 buf-window list 中删除 win
    for _, buf in ipairs(w:list_bufs()) do
      local b = g.bufs[buf]
      if b then
        b:remove_win(win_id)
      end
    end

    --- delete winbar_win from cache
    g.wins[win_id] = nil
  end
})

--- buffer 相关事件, 影响多个 window, 如果 buffer 被加入到多个 window 中
--- ModeChanged 可以影响 terminal
vim.api.nvim_create_autocmd({
  "TextChanged", "TextChangedI", "TextChangedP",
  "BufWritePost", "FileChangedShellPost", "DiagnosticChanged",
  "ModeChanged", "TabClosed",
}, {
  group = gid,
  callback = function(args)
    local b = g.bufs[args.buf]
    if not b then
      return
    end

    for _, win_id in ipairs(b:list_wins()) do
      local w = g.wins[win_id]
      if w then
        w:set_winbar()
      end
    end
  end
})

--- 更新相关 winbar
vim.api.nvim_create_autocmd({"WinEnter"}, {
  group = gid,
  callback = function(args)
    --- 修改 current window 的 winbar
    local curr_win = get_current_normal_win()
    if not curr_win then
      return
    end

    local cw = g.wins[curr_win]
    if cw then
      cw:set_winbar()
    end

    --- 修改 preview window 的 winbar
    local prev_winnr = vim.fn.winnr('#')
    if prev_winnr > 0 then
      local prev_win_id = vim.fn.win_getid(prev_winnr)
      local pw = g.wins[prev_win_id]
      if pw then
        pw:set_winbar()
      end
    end
  end
})



