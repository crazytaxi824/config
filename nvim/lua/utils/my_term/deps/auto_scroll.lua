local M = {}

M.buf_scroll_bottom = function(term_obj)
  if not term_obj.auto_scroll then
    return
  end

  vim.api.nvim_buf_call(term_obj.bufnr, function()
    --- 在 terminal insert mode ( mode()=='t' ) 时无法使用 `normal! G`. 在 terminal 模式下默认会滚动到最底部.
    local info = vim.api.nvim_get_mode()
    if info and (info.mode ~= "t") then vim.cmd("normal! G") end
  end)
end

return M
