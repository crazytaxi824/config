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
    header = "",
    source = false,
    -- prefix = "",
    -- suffix = "",
    format = function(diag)
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = diag.bufnr })) do
        local ns = vim.lsp.diagnostic.get_namespace(client.id)
        if ns == diag.namespace then
          return string.format("[%s: %s] %s", client.name, diag.source, diag.message)
        end
      end

      return string.format("[%s] %s", diag.source, diag.message)  -- 找不到 lsp client
    end,

    -- Extends: vim.lsp.util.open_floating_preview.Opts
    focusable = false,
    border = Nerd_icons.border,
    close_events = { "WinScrolled", "CursorMoved", "CursorMovedI", "InsertCharPre" },
    -- anchor_bias = 'above',  -- BUG: Invalid 'height': 如果报错的 line 上方的高度不够会报错
  },
}

-- VVI: 这里是加载配置的地方
vim.diagnostic.config(config)



