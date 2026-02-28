# MyTerm

my_term buffer 是通过 `vim.api.nvim_create_buf(false, true)` 创建的 nobuflisted scratch buffer,
因为整个 buffer 是 nobuflisted 所以 :bdelete 不会有任何操作, 也不会触发 BufDelete event.
所以需要使用 `nvim_buf_delete(bufnr, {force=true})` 或者 `:bwipeout` 来删除整个 buffer.
