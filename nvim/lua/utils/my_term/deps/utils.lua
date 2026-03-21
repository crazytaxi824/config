local M = {}

--- 自动滚动页面到底部
---
--- @param term MyTerm
--- @param term_bufnr integer
function M.buf_scroll_bottom(term, term_bufnr)
  if not term.auto_scroll() then
    return
  end

  --- 如果没有 window 正在显示该 buffer 则 nvim_buf_call() 会创建一个临时 "autocmd window" (不可见) 用来执行命令.
  if vim.fn.bufwinid(term_bufnr) > 0 then
    vim.api.nvim_buf_call(term_bufnr, function()
      --- 在 terminal insert mode ( mode()=='t' ) 时无法使用 `normal! G`. 在 terminal 模式下默认会滚动到最底部.
      local info = vim.api.nvim_get_mode()
      if info and (info.mode ~= "t") then
        vim.cmd.normal({ args = {'G'}, bang=true })  -- ':normal! G'
      end
    end)
  end
end

return M
