--- `:help vim.lsp.set_log_level()`, 影响 `:LspLog`.
--- BUG: 默认为 "WARN", 但 vim.lsp 还未实现 sumneko_lua 中的 workspace/diagnostic/refresh handler, 会有大量 WARN log.
vim.lsp.set_log_level("ERROR")

--- 加载 LSP 相关自定义设置.
require("user.lsp.diagnostic")   -- 加载 diagnostic 设置
require("user.lsp.auto_format")  -- save(:w) 时 format
require("user.lsp.user_commands")  -- 自定义 lsp 相关 command



