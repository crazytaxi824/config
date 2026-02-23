local M = {}

--- 自动滚动页面到底部.
---
---@param term_opts MyTermOpts
---@param term_bufnr integer
function M.buf_scroll_bottom(term_opts, term_bufnr)
  if not term_opts.auto_scroll then
    return
  end

  vim.api.nvim_buf_call(term_bufnr, function()
    --- 在 terminal insert mode ( mode()=='t' ) 时无法使用 `normal! G`. 在 terminal 模式下默认会滚动到最底部.
    local info = vim.api.nvim_get_mode()
    if info and (info.mode ~= "t") then
      vim.cmd.normal({ args = {'G'}, bang=true })  -- ':normal! G'
    end
  end)
end

return M
