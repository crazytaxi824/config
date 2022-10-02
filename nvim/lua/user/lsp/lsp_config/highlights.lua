local custom_lsp_req = require("user.lsp.custom_lsp_request")

--- 返回自定义 documentHighlight 处理方法 ----------------------------------------------------------
local M = {}

--- NOTE: 本函数只会在 buffer on_attach() 的时候执行一次,
--- 对可以执行 'textDocument/documentHighlight' 请求的 buffer 设置两个 autocmd.
M.highlight_references = function(client, bufnr)
  if client.supports_method('textDocument/documentHighlight') then
    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
      buffer = bufnr,  -- NOTE: 本 autocmd 只对指定 buffer 有效.
      callback = function(params)
        custom_lsp_req.doc.highlight(params.buf)
      end,
    })

    --- 清除 clear highlight
    --- WinLeave: 在 cursor 进入另外一个 window 前
    --- BufWinLeave: 在 window 显示其他的 buffer 前
    vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave"}, {
      buffer = bufnr,  -- NOTE: 本 autocmd 只对指定 buffer 有效.
      callback = function(params)
        custom_lsp_req.doc.clear(params.buf)
      end
    })
  end
end

return M
