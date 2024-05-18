--- Overwrite handler 设置
--- DOCS: 使用 with() 方法. `:help lsp-handler-configuration`
--- `:help vim.diagnostic.Opts`
--- `:help vim.lsp.util.open_floating_preview()`
--- `:help vim.lsp.util.make_floating_popup_options()`
--- `:help nvim_open_win()`
--- DOCS: `:help lsp-api` lsp-method 显示 textDocument/... 列表

--- 'textDocument/publishDiagnostics' settings ------------------------------------------------------
--- `:help vim.lsp.diagnostic.on_publish_diagnostics()`
--- NOTE: 会影响 vim.diagnostic.config() 设置.
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.handlers["textDocument/publishDiagnostics"], {
    --- `:help vim.diagnostic.Opts`
    --- 使用 virtual_text 显示 diagnostic message.
    virtual_text = false,
    -- virtual_text = {
    --   spacing = 4,  -- Enable virtual text, override spacing to 4
    --   prefix = function(diag, index, total)
    --     if diag.severity == vim.diagnostic.severity.ERROR then
    --       return Nerd_icons.diag.error
    --     elseif diag.severity == vim.diagnostic.severity.WARN then
    --       return Nerd_icons.diag.warn
    --     elseif diag.severity == vim.diagnostic.severity.INFO then
    --       return Nerd_icons.diag.info
    --     elseif diag.severity == vim.diagnostic.severity.HINT then
    --       return Nerd_icons.diag.hint
    --     end
    --   end,
    -- },

    --- 是否显示 diagnostic signs.
    signs = true,
    -- Use a function to dynamically turn signs off
    -- and on, using buffer local variables
    --signs = function(namespace, bufnr) end,

    --- 输入时实时更新 diagnostic, 比较耗资源.
    update_in_insert = false,
  }
)

--- 'textDocument/hover' handler 的 border 样式 ----------------------------------------------------
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers["textDocument/hover"],
  {
    --- `:help vim.lsp.util.open_floating_preview()`
    --- `:help vim.lsp.util.make_floating_popup_options()`
    --- `:help nvim_open_win()`
    focusable = false,  -- false: 重复执行 vim.lsp.buf.hover() 时不会进入 floating window.
    border = Nerd_icons.border,
    anchor_bias = 'above',  -- popup window 优先向上弹出

    --- events, to trigger close floating window
    --- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/util.lua
    close_events = {"WinScrolled"},  -- 默认 {"CursorMoved", "CursorMovedI", "InsertCharPre"}
  }
)



