--- 使用 autocmd "CursorHold", "CursorHoldI" 使用自定义的 doc_highlight.lua 设置.
--- autocmd "BufLeave" (cursor 离开该 buffer 的时候) 清除 clear documentHighlight.

local doc_hl = require("lsp.custom_lsp_request.doc_highlight")

--- 返回自定义 documentHighlight 处理方法 ----------------------------------------------------------
local M = {}

--- 本函数需要在 buffer on_attach() 的时候执行针对 bufnr 设置 autocmd.
M.fn = function(client, bufnr)
  --- 如果 lsp client 支持 documentHighlight 则设置 autocmd.
  if client.supports_method('textDocument/documentHighlight') then
    --- VVI: 这里必须使用 augroup, 否则在 `:LspRestart` 的情况下会叠加多个 autocmd.
    local group_id = vim.api.nvim_create_augroup("my_documentHighlight_"..bufnr, {clear=true})

    --- documentHighlight
    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
      group = group_id,
      buffer = bufnr,  -- 对指定 buffer 有效
      callback = function(params)
        --- VVI: 在 change filetype (`set filetype=xxx`) 的过程中,
        --- 如果先 LspAttach new_lsp, 然后再 LspDetach old_lsp, 或 async 执行 LspAttach 和 LspDetach, 则需要用到以下代码.
        --- 如果先 LspDetach old_lsp, 然后再 LspAttach new_lsp, 则不需要修改. 默认在 LspDetach 的时候 del_augroup.
        vim.lsp.buf.document_highlight()
      end,
      desc = "LSP: documentHighlight",
    })

    --- 清除 clear documentHighlight
    --- BufLeave: cursor 离开该 buffer 的 event. eg:
    ---  - window load 其他 buffer.
    ---  - cursor 进入其他 window.
    vim.api.nvim_create_autocmd("BufLeave", {
      group = group_id,
      buffer = bufnr,  -- 对指定 buffer 有效
      callback = function(params)
        doc_hl.doc_clear(params.buf)
      end,
      desc = "LSP: clear documentHighlight",
    })

    --- delete documentHighlight augroup
    --- NOTE: 这里必须使用 BufDelete, 否则 buffer 如果更改了 filetype 只能使用 :bwipeout 来删除 documentHighlight
    vim.api.nvim_create_autocmd({'LspDetach', 'BufDelete', 'BufWipeout'}, {
      group = group_id,
      buffer = bufnr,  -- 对指定 buffer 有效
      callback = function(params)
        vim.api.nvim_del_augroup_by_id(group_id)
      end,
      desc = "LSP: delete documentHighlight augroup",
    })
  end
end

return M
