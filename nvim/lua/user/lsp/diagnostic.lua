--- Diagnostic 设置 --------------------------------------------------------------------------------
--- README: 这里的设置都是和 neovim 编辑器显示效果相关的设置.
---         所有设置通过 vim.diagnostic.config() 函数加载.

--- 自定义 diagnostic sign 样式
local signs = {
  { name = "DiagnosticSignError", text = "❌" },
  { name = "DiagnosticSignWarn", text = "W>" },
  { name = "DiagnosticSignInfo", text = "I>" },
  { name = "DiagnosticSignHint", text = "H>" },
}
for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

--- diagnostic config
local config = {
  virtual_text = false,     -- VVI: 使用 virtual_text 显示 diagnostic_message
  --virtual_text = {source = true},     -- 使用 virtual_text 显示 diagnostic_message, 同时带上 linter 名字, 默认 false
  update_in_insert = false, -- 输入过程中 diagnostic. true - 体验更好 | false - 节省资源
  signs = true,             -- 默认 true
  underline = true,         -- 默认 true
  severity_sort = true,     -- 按照优先级显示 Error > Warn > Info > Hint

  --- NOTE: `:help vim.diagnostic.config()` 中说明 float 设置使用的 `:help vim.diagnostic.open_float()`
  --- 而 vim.diagnostic.open_float() 使用的是 `:help vim.lsp.util.open_floating_preview()` + 一些属性.
  --- 而 vim.lsp.util.open_floating_preview() 使用的是 `:help nvim_open_win()` + 一些属性.
  float = {
    focusable = false,
    style = "minimal",
    -- border = "single",  -- `:help nvim_open_win()`
    border = {"▄","▄","▄","█","▀","▀","▀","█"},
    source = true,   -- diagnostic message 中带 linter 名字
    header = "",
    prefix = "",
    --noautocmd = true,  -- float window 不加载 autocmd
  },
}

--- VVI: 这里是加载配置的地方
vim.diagnostic.config(config)



