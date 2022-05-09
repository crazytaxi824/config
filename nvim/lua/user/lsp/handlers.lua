--- Overwrite handler 设置 -------------------------------------------------------------------------
--- NOTE: 使用 with() 方法. `:help lsp-handler-configuration`
---      `:help lsp-api` lsp-method 显示 textDocument/... 列表
--- VVI: `:help vim.lsp.util.open_floating_preview` 中的 {opts} 所有属性都可以在 with() 中设置.

--- 这里是修改 border 样式.
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers["textDocument/hover"],
  {
    border = {"▄","▄","▄","█","▀","▀","▀","█"},
    --- VVI: `set omnifunc?` 没有设置, 所以 <C-x><C-o> 不会触发 Completion.
    close_events = {"CompleteDone"},  -- event list, 什么情况下 close floating window
  }
)

--- signatureHelp 是用来显示函数入参出参的.
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers["textDocument/signatureHelp"],
  { border = {"▄","▄","▄","█","▀","▀","▀","█"} }
)

--- NOTE: 这里是修改输出到 location-list. 默认是 quickfix
-- vim.lsp.handlers["textDocument/references"] = vim.lsp.with(
--   vim.lsp.handlers["textDocument/references"], {
--     -- Use location list instead of quickfix list
--     loclist = true,  -- qflist | loclist
--   }
-- )

-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--   vim.lsp.handlers["textDocument/publishDiagnostics"], {
--     -- Enable underline, use default values
--     underline = true,
--
--     -- Enable virtual text, override spacing to 4
--     virtual_text = {
--       spacing = 4,
--       source = true,
--     },
--
--     -- Use a function to dynamically turn signs off
--     -- and on, using buffer local variables
--     signs = function(namespace, bufnr)
--       return vim.b[bufnr].show_signs == true
--     end,
--
--     -- Disable a feature
--     update_in_insert = false,
--   }
-- )


