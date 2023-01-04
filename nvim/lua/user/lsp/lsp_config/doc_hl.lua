local custom_lsp_req = require("user.lsp.custom_lsp_request")

--- 返回自定义 documentHighlight 处理方法 ----------------------------------------------------------
local M = {}

--- NOTE: 本函数需要在 buffer on_attach() 的时候执行,
--- 对可以执行 'textDocument/documentHighlight' 请求的 buffer 设置两个 autocmd.
M.fn = function(client, bufnr)
  if client.supports_method('textDocument/documentHighlight') then
    --- 这里必须使用 augroup, 否则在 `:LspRestart` 的情况下会叠加多个 autocmd.
    local group_id = vim.api.nvim_create_augroup("my_documentHighlight_"..bufnr, {clear=true})

    --- 手动 `set filetype=xxx` 时, 删除 previous documentHighlight augroup
    --- VVI: 本函数是在每次 lsp on_attach 的时候执行, 同时每次执行本函数的时候会生成一个新的 augroup.
    --- 而且 on_attach 会在 FileType event 之后执行, 所以下面的 autocmd FileType 只会在下一次 on_attach 时执行.
    --- 这时候删除的 group_id 是上一次 on_attach 时生成的 group_id, 所以是删除了上一次的 augroup.
    ---
    --- VVI: 步骤分析:
    ---   on_attach 生成一个 augroup_id1 和 autocmd FileType, 当触发 FileType event 时 nvim_del_augroup_by_id(augroup_id1)
    ---   `set filetype=xxx` 触发 FileType event.
    ---   FileType event 触发 nvim_del_augroup_by_id(augroup_id1), 同时触发 on_attach.
    ---   on_attach 生成一个新的 augroup_id2, 同时生成一个新的 autocmd FileType. nvim_del_augroup_by_id(augroup_id2)
    vim.api.nvim_create_autocmd("FileType", {
      group = group_id,
      once = true,  -- NOTE: 执行一次.
      buffer = bufnr,
      callback = function (params)
        --- VVI: 这里的 group_id 其实缓存的是上一次的 group_id.
        pcall(vim.api.nvim_del_augroup_by_id, group_id)
      end,
      desc = "delete documentHighlight augroup when changing FileType",
    })

    --- documentHighlight
    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
      group = group_id,
      buffer = bufnr,  -- NOTE: 本 autocmd 只对指定 buffer 有效.
      callback = function(params)
        custom_lsp_req.doc.highlight(params.buf)
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
