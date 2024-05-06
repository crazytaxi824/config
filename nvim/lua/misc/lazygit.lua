--- 在 vim 中使用 lazygit

local function lazygit()
  local scratch = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(scratch, true, {
    relative = 'editor',
    row = 1,
    col = math.ceil(vim.o.columns / 20),
    height = vim.o.lines - vim.o.cmdheight - 3,  -- minus lazygit_border_width=2(上下 border) & buffer_line=1
    width = math.floor(vim.o.columns / 20 * 18),
    style = "minimal", -- Window border style
    border = Nerd_icons.border,
    -- noautocmd = true,
  })

  vim.api.nvim_buf_call(scratch, function()
    vim.fn.termopen('lazygit', {
      --- lazygit 快捷键 q 会退出程序, 触发 on_exit, 从而 delete buffer.
      on_exit = function() vim.api.nvim_buf_delete(scratch, {force=true}) end
    })
    --- unmap <ESC>, 否则会导致很多问题. 需要退出 terminal insert 模式, 使用 <C-\><C-N>
    vim.cmd('startinsert | silent! tunmap <buffer> <ESC>')
  end)
end

vim.api.nvim_create_user_command('Lg', function()
  lazygit()
end, { bang=true, bar=true, desc = 'lazygit' })



