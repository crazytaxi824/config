local custom_lsp_req = require("user.lsp.custom_lsp_request")

--- 返回自定义 documentHighlight 处理方法 ----------------------------------------------------------
local M = {}

--- NOTE: 本函数只会在 buffer on_attach() 的时候执行一次,
--- 对可以执行 'textDocument/documentHighlight' 请求的 buffer 设置两个 autocmd.
M.highlight_references = function(client, bufnr)
  if client.supports_method('textDocument/documentHighlight') then
    --- VVI: 这里必须使用 augroup, 否则在 `:LspRestart` 的情况下会叠加多个 autocmd.
    local group_id = vim.api.nvim_create_augroup("my_documentHighlight_"..tostring(bufnr), {clear=true})

    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
      group = group_id,
      buffer = bufnr,  -- NOTE: 本 autocmd 只对指定 buffer 有效.
      callback = function(params)
        custom_lsp_req.doc.highlight(params.buf)
      end,
    })

    --- 清除 clear highlight
    --- WinLeave: 在 cursor 进入另外一个 window 前
    --- BufWinLeave: 在 window 显示其他的 buffer 前
    vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave"}, {
      group = group_id,
      buffer = bufnr,  -- NOTE: 本 autocmd 只对指定 buffer 有效.
      callback = function(params)
        custom_lsp_req.doc.clear(params.buf)
      end
    })

    --- delete augroup by group_id
    vim.api.nvim_create_autocmd('BufDelete', {
      group = group_id,
      buffer = bufnr,
      callback = function(params)
        vim.api.nvim_del_augroup_by_id(group_id)
      end
    })
  end
end

return M
