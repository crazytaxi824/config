--- unnamed & unknown buffer && markdown && text filetype set wrap ---------------------------------
local function cursor_move_in_wrap(bufnr)
  local opt = {noremap = true, buffer = bufnr}  -- NOTE: 指定 buffer
  vim.keymap.set({'n','v'}, '<Down>', 'gj', opt)
  vim.keymap.set({'n','v'}, '<Up>',   'gk', opt)
  vim.keymap.set({'n','v'}, '<Home>', 'g0', opt)  -- g0 相当于 g<Home>
  vim.keymap.set({'n','v'}, '<End>',  'g$', opt)  -- g$ 相当于 g<End>

  vim.keymap.set('i', '<Down>', '<C-o>gj', opt)
  vim.keymap.set('i', '<Up>',   '<C-o>gk', opt)
  vim.keymap.set('i', '<Home>', '<C-o>g0', opt)  -- g0 相当于 g<Home>
  vim.keymap.set('i', '<End>',  '<C-o>g$', opt)  -- g$ 相当于 g<End>
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = {"*"},
  callback = function(params)
    local wrap_filetypes = {'', 'markdown', 'text'}  -- '' 表示 unnamed buffer 或者不认识的 filetype.
    if vim.tbl_contains(wrap_filetypes, vim.bo.filetype) then
      vim.wo.wrap = true
      cursor_move_in_wrap(params.buf)
    else
      vim.wo.wrap = false
    end
  end
})



