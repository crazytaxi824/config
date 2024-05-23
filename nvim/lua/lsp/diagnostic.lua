--- vim Diagnostic 设置
--- 这里的设置都是和 neovim 编辑器显示效果相关的设置.
--- 所有设置通过 vim.diagnostic.config() 函数加载.

--- NOTE: test diagnostic sign
-- foo=1
-- local function foo(a)
--   bar
-- end

--- Highlights
vim.api.nvim_set_hl(0, 'my_diagnostic_linehl', {
  -- ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
  ctermbg=Colors.bg_red.c, bg=Colors.bg_red.g,
})

--- `:help vim.diagnostic.config()`
local config = {
  --- `:help diagnostic-signs`
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = Nerd_icons.diag.error,
      [vim.diagnostic.severity.WARN]  = Nerd_icons.diag.warn,
      [vim.diagnostic.severity.INFO]  = Nerd_icons.diag.info,
      [vim.diagnostic.severity.HINT]  = Nerd_icons.diag.hint,
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = 'my_diagnostic_linehl',
      [vim.diagnostic.severity.WARN]  = 'my_diagnostic_linehl',
    },
    -- numhl = {
    --   [vim.diagnostic.severity.ERROR] = 'my_diagnostic_linehl',
    --   [vim.diagnostic.severity.WARN]  = 'my_diagnostic_linehl',
    -- },
  },

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
    -- noautocmd = true,  -- float window 不加载 Buf* 相关 autocmd. VVI: 不要设置为 true.
    close_events = {"WinScrolled", "CursorMoved", "CursorMovedI", "InsertCharPre"},
  },
}

--- VVI: 这里是加载配置的地方
vim.diagnostic.config(config)



