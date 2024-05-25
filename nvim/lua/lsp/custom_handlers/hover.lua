vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
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



