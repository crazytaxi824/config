local M = {}

--- cache all opened floating preview window ID.
--- map[win_id: boolen]
local floating_preview_windows = {}

M.close_all_hover_floating_windows = function()
  local win_closed = false
  for win_id, _ in pairs(floating_preview_windows) do
    if vim.api.nvim_win_is_valid(win_id) then
      win_closed = true
      vim.api.nvim_win_close(win_id, true)
    end

    --- delete win_id after closing or not valid.
    floating_preview_windows[win_id] = nil
  end

  --- all floating window have been closed.
  return win_closed
end

M.hover_with = function(handler, override_config)
  return function(err, result, ctx, config)
    local bufnr, win_id = handler(err, result, ctx, vim.tbl_deep_extend('force', config or {}, override_config))
      --- VVI: 如果没有 result 则, bufnr 和 win_id 都是 nil
      if win_id then
        --- cache hover floating preview windows
        floating_preview_windows[win_id] = true
      end
    return bufnr, win_id
  end
end

vim.lsp.handlers["textDocument/hover"] = M.hover_with(
  vim.lsp.handlers["textDocument/hover"],
  {
    --- `:help vim.lsp.util.open_floating_preview()`
    --- `:help vim.lsp.util.make_floating_popup_options()`
    --- `:help nvim_open_win()`
    focusable = false,  -- false: 重复执行 vim.lsp.buf.hover() 时不会进入 floating window.
    border = {"","","","█","▀","▀","▀","█"},
    anchor_bias = 'above',  -- popup window 优先向上弹出
    max_width = math.floor(vim.go.columns * 0.8),

    --- events, to trigger close floating window
    --- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/util.lua
    close_events = {"WinScrolled"},  -- 默认 {"CursorMoved", "CursorMovedI", "InsertCharPre"}
  }
)

return M
