local M = {}

M.fn = function(win_id, stopinsert)
  return function()
    if stopinsert then
      vim.cmd('stopinsert')
    end

    local group_id = vim.api.nvim_create_augroup("my_back_to_prev_window",{clear=true})

    vim.api.nvim_create_autocmd("BufWipeout", {
      group = group_id,
      buffer = 0,
      callback = function(params)
        --- 如果 goto 的 win_id 不存在, 则会自动跳到别的 window.
        if vim.fn.win_gotoid(win_id) == 1 then
          --- VVI: 必须要, 因为这里无法触发 WinEnter, 导致 cursorline 无法设置.
          vim.wo[win_id].cursorline = true
        end

        --- 删除 augroup
        vim.api.nvim_del_augroup_by_id(group_id)
      end,
      desc = 'back to exec window',
    })
  end
end

return M
