--- `:bdelete` 本质是 unlist buffer. 即: listed = 0

local M = {}

M.delete_all_other_buffers = function()
  local buf_list = {}

  --- NOTE: nvimtree, tagbar, terminal 不会被关闭, 因为他们是 unlisted.
  for _, bufinfo in ipairs(vim.fn.getbufinfo({buflisted = 1})) do  -- 获取 listed buffer
    if bufinfo.changed == 0    -- 没有修改后未保存的内容.
      and bufinfo.hidden == 1  -- 是隐藏状态的 buffer. 如果是 active 状态(即: 正在显示的 buffer, 例如当前 buffer), 不会被删除.
    then
      table.insert(buf_list, bufinfo.bufnr)
    end
  end

  if #buf_list > 0 then
    vim.cmd('bdelete ' .. table.concat(buf_list, ' '))
  end
end

return M
