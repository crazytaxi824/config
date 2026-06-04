-- vim Diagnostic 设置
-- 这里的设置都是和 neovim 编辑器显示效果相关的设置.
-- 所有设置通过 vim.diagnostic.config() 函数加载.

-- NOTE: test diagnostic sign
-- local function foo(a)
--   f=1
--   foo=1
--   bar
-- end

-- Highlights
vim.api.nvim_set_hl(0, 'my_diagnostic_linehl', {
  ctermbg=Colors.red_bg.c, bg=Colors.red_bg.g,
})

-- `:help vim.diagnostic.config()`
-- `:help diagnostic-signs`
local config = {
  signs = {
    text = Nerd_icons.diag,
    -- linehl = {
    --   [vim.diagnostic.severity.ERROR] = 'my_diagnostic_linehl',
    --   [vim.diagnostic.severity.WARN]  = 'my_diagnostic_linehl',
    -- },
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

  -- `:help vim.diagnostic.Opts.Float` extends `:help vim.lsp.util.open_floating_preview.Opts`
  float = {
    focusable = false,
    style = "minimal",
    border = Nerd_icons.border,
    source = true,   -- diagnostic message 中带 linter 名字
    header = "",
    prefix = "",
    -- noautocmd = true,  -- float window 不加载 Buf* 相关 autocmd. VVI: 不要设置为 true.
    close_events = { "WinScrolled", "CursorMoved", "CursorMovedI", "InsertCharPre" },

    -- BUG: Invalid 'height': expected positive Integer, 如果报错的 line 上方的高度不够就会报这个错误
    -- anchor_bias = 'above',
  },
}

-- VVI: 这里是加载配置的地方
vim.diagnostic.config(config)



