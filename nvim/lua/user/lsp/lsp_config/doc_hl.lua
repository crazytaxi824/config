local custom_lsp_req = require("user.lsp.custom_lsp_request")

--- 返回自定义 documentHighlight 处理方法 ----------------------------------------------------------
local M = {}

--- NOTE: 本函数需要在 buffer on_attach() 的时候执行,
--- 对可以执行 'textDocument/documentHighlight' 请求的 buffer 设置两个 autocmd.
M.fn = function(client, bufnr)
  if client.supports_method('textDocument/documentHighlight') then
    --- 这里必须使用 augroup, 否则在 `:LspRestart` 的情况下会叠加多个 autocmd.
    local group_id = vim.api.nvim_create_augroup("my_documentHighlight_"..bufnr, {clear=true})

    --- documentHighlight
    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
      group = group_id,
      buffer = bufnr,  -- NOTE: 本 autocmd 只对指定 buffer 有效.
      callback = function(params)
        local lsp_clients = vim.lsp.get_active_clients({ bufnr = params.buf })

        local doc_hl_mark
        for _, c in ipairs(lsp_clients) do
          if c.supports_method('textDocument/documentHighlight') then
            doc_hl_mark = true
          end
        end

        if doc_hl_mark then
          --- 如果有任何一个 attached lsp 能够 documentHighlight, 则发送请求.
          custom_lsp_req.doc.highlight(params.buf)
        else
          --- 清除之前的 documentHighlight
          custom_lsp_req.doc.clear(params.buf)
          --- 如果没有任何一个 attached lsp 能够 documentHighlight, 则删除 augroup.
          vim.api.nvim_del_augroup_by_id(group_id)
        end
      end,

      desc = "documentHighlight",
    })

    --- 清除 clear documentHighlight
    --- BufLeave: cursor 离开该 buffer 的 event. eg:
    ---  - window load 其他 buffer.
    ---  - cursor 进入其他 window.
    vim.api.nvim_create_autocmd("BufLeave", {
      group = group_id,
      buffer = bufnr,  -- NOTE: 本 autocmd 只对指定 buffer 有效.
      callback = function(params)
        custom_lsp_req.doc.clear(params.buf)
      end,
      desc = "clear documentHighlight",
    })

    --- delete documentHighlight augroup
    --- NOTE: 这里必须使用 BufDelete, 否则 buffer 如果更改了 filetype 只能使用 :bwipeout 来删除 documentHighlight
    vim.api.nvim_create_autocmd({'BufWipeout', 'BufDelete'}, {
      group = group_id,
      buffer = bufnr,
      callback = function(params)
        vim.api.nvim_del_augroup_by_id(group_id)
      end,
      desc = "delete documentHighlight augroup",
    })
  end
end

return M
