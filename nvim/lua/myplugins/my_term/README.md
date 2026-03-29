# MyTerm

my_term buffer 是通过 `vim.api.nvim_create_buf(false, true)` 创建的 nobuflisted scratch buffer,
因为整个 buffer 是 nobuflisted 所以 :bdelete 不会有任何操作, 也不会触发 BufDelete event.
所以需要使用 `nvim_buf_delete(bufnr, {force=true})` 或者 `:bwipeout` 来删除整个 buffer.

## 区别

### vim.fn.jobstart(cmd, {term=true})

使用当前 buffer 执行命令, 当前 buffer 显示的文件被 wipeout.

eg: 在 bufnr = 1 的 buffer 中执行 `ls`, 执行后 bufnr 还是 1.

所以不会触发 `BufEnter`, `BufWinEnter` 两个 events.

#### events 顺序

BufFilePre, BufFilePost, TermOpen

TermRequest (shell mode)  `termopen('zsh')` 进入 shell mode
TermEnter   (insert mode)
TermLeave   (normal mode)  退出 insert mode `<C-\><C-n>`
TermClose   (jobdone)


### edit term://{cmd}

创建一个新的 buffer 执行 cmd. 所以会触发 `BufEnter`, `BufWinEnter` 两个 events.

#### events 顺序

BufFilePre, BufFilePost, TermOpen, BufEnter, BufWinEnter


