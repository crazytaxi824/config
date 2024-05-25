--- Overwrite handler 设置
--- DOCS: `:help lsp-api` lsp-method 显示 textDocument/... 列表
--- DOCS: 使用 vim.lsp.with() 方法. `:help lsp-handler-configuration`
--- vim.lsp.handlers[...] 本质上是一个 `:help lsp-handlers`. function({_}, {result}, {ctx}, {config})
--- vim.lsp.with(override_config) 是 return handler(err, result, ctx, vim.tbl_deep_extend('force', config or {}, override_config))

--- 'textDocument/publishDiagnostics' settings ------------------------------------------------------
--- DOCS: `:help vim.lsp.diagnostic.on_publish_diagnostics()` & `:help vim.diagnostic.Opts`
--- VVI: vim.lsp.with(publishDiagnostics) 可以 Overwrite 的配置只有 `:help vim.diagnostic.Opts`,
--- 如果想要调整 'float' 的设置必须在 `vim.diagnostic.config()` 中设置, eg: 'anchor_bias', 'border', 'focusable' ...
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.handlers["textDocument/publishDiagnostics"], {
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



