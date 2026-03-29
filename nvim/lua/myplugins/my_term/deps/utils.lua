local M = {}

--- 自动滚动页面到底部
---
--- @param term MyTerm
--- @param term_bufnr integer
function M.buf_scroll_bottom(term, term_bufnr)
  if not term:auto_scroll() then
    return
  end

  local win_id = vim.fn.bufwinid(term_bufnr)
  if win_id > 0 then
    vim.api.nvim_win_call(win_id, function()
      --- 在 terminal insert mode ( mode()=='t' ) 时无法使用 `normal! G`. 在 terminal 模式下默认会滚动到最底部.
      local info = vim.api.nvim_get_mode()
      if info and (info.mode ~= "t") then
        vim.cmd.normal({ args = {'G'}, bang=true })  -- ':normal! G'
      end
    end)
  end
end

return M
