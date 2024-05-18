--- vim Diagnostic 设置
--- 这里的设置都是和 neovim 编辑器显示效果相关的设置.
--- 所有设置通过 vim.diagnostic.config() 函数加载.

--- NOTE: test diagnostic sign
-- foo=1
-- local function foo(a)
--   bar
-- end

--- 自定义 diagnostic sign 样式
local signs = {
  { name = "DiagnosticSignError", text = Nerd_icons.diag.error },
  { name = "DiagnosticSignWarn",  text = Nerd_icons.diag.warn },
  { name = "DiagnosticSignInfo",  text = Nerd_icons.diag.info },
  { name = "DiagnosticSignHint",  text = Nerd_icons.diag.hint },
}
for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "", linehl="" })
end

--- `:help vim.diagnostic.config()`
local config = {
  --- NOTE: signs & underline & virtual_text 默认 true, 也可以使用 table.
  signs = true,  -- 显示 sign DiagnosticSignError/Warn/Info/Hint.
                 -- 可以为 table: { severity, priority }
                 -- severity: Only show signs for diagnostics matching the given severity,
                 -- priority: 默认值 10. NOTE: DiagnosticSignError/Warn/Info/Hint use the same priority, unless:
                 -- 如果 severity_sort = false, 则所有 priority 都是 10;
                 -- 如果 severity_sort = true, 则:
                 --   - DiagnosticSignHint  priority=priority
                 --   - DiagnosticSignInfo  priority=priority + 1
                 --   - DiagnosticSignWarn  priority=priority + 2
                 --   - DiagnosticSignError priority=priority + 3

  severity_sort = true,  -- DiagnosticSignError > Warn > Info > Hint 优先级 (priority) 设置.

  underline = true,  -- 给错误的源代码使用 `hi DiagnosticUnderlineError/Warn/Info/Hint`
                     -- {severity}: Only underline diagnostics matching the given severity.

  virtual_text = false,  -- 使用 virtual_text 显示 diagnostic_message.
                         -- {severity, source, spacing, prefix, format}
                         -- {source = true}, 使用 virtual_text 显示 diagnostic_message 时带上 linter 名字.

  update_in_insert = false,  -- 输入过程中 diagnostic. true - 体验更好 | false - 节省资源

  --- NOTE: `:help vim.diagnostic.config()` 中说明 float 设置使用的 `:help vim.diagnostic.open_float()`
  --- 而 vim.diagnostic.open_float() 使用的是 `:help vim.lsp.util.open_floating_preview()` + 一些属性.
  --- 而 vim.lsp.util.open_floating_preview() 使用的是 `:help nvim_open_win()` + 一些属性.
  float = {
    focusable = false,
    style = "minimal",
    border = Nerd_icons.border,
    source = true,   -- diagnostic message 中带 linter 名字
    header = "",
    prefix = "",
    anchor_bias = 'above',  -- popup window 优先向上弹出
    --noautocmd = true,  -- float window 不加载 Buf* 相关 autocmd. VVI: 不要设置为 true.
  },
}

--- VVI: 这里是加载配置的地方
vim.diagnostic.config(config)



