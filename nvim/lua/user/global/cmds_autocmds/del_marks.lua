--- `:help marks`
---  'a - 'z   lowercase marks, valid within one file.
---  'A - 'Z   uppercase marks, also called file marks, valid between files
---  '0 - '9   numbered marks, set from .shada file

--- delmakrs! 删除 buffer 中所有 marks, 除了 A-Z0-9
vim.cmd('command -bar DelAllMarks delmarks! | delmarks A-Z0-9')

--- BufLeave 切换窗口时触发.
--- BufHidden 同一个窗口切换(load)不同 buffer 时触发.
--- BufDelete :bdelete / :bwipeout 时触发.
-- vim.api.nvim_create_autocmd({"BufDelete"},{
--   pattern = {"*"},
--   callback = function(params)
--     --- NOTE: 这里不能用 vim.cmd('delmarks! | delmarks A-Z0-9'), 因为 bnext | bd#
--     --- vim.api.nvim_buf_del_mark(params.buf, 'a')  -- a-z, local to buffer
--     --- vim.api.nvim_del_mark('A') A-Z0-9
--     for i=97,122,1 do
--       vim.api.nvim_buf_del_mark(params.buf, string.char(i))
--     end
--     for i=65,90,1 do
--       vim.api.nvim_del_mark(string.char(i))
--     end
--     for i=0,9,1 do
--       vim.api.nvim_del_mark(tostring(i))
--     end
--   end
-- })



