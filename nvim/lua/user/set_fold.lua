--- BUG: treesitter foldmethod bug
---      tab indent 的折叠显示不正确. \t 被当作是一个字符, 导致折叠后的代码前面只空一格.
---      space indent 的折叠显示正确.
---      这里通过设置 foldnestmax=1 来确保只折叠最外层代码.

--- 根据不同情况设置不同的折叠方式.
--- VVI: 不要在打开代码前设置 foldmethod=syntax, 会严重拖慢文件切换速度. eg: jump to definition.
--- VVI: foldmethod -- treesitter experimental function.
--- foldnestmax=1  只 fold function 最外层.
---                VVI: 需要放在 foldlevel 之前设置, 否则可能不生效.
---                每次执行 <leader>k1 都会重新设置该值.
--- foldlevel=n    从 level > n 的层开始折叠. 最外层 level=1, 越内部 level 越高.
---                0 代表从最外层开始 fold.
---                999 表示从 1000 层开始 fold, 即不进行 fold.

--- VVI: 必须放在最上面, 因为如果 stdpath('config') 路径下有 json ... 等文件, 可以通过下面的 autocmd 覆盖这里的设置.
--- 这里不能使用 'BufEnter' 否则每次切换窗口或者文件的时候都会重新设置.
--- "~/.config/nvim/*" 中的所有 file 都使用 marker {{{xxx}}} 折叠.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    if string.match(vim.fn.fnamemodify(params.file, ":p"), '^'..vim.fn.stdpath('config')) then
      vim.wo.foldmethod = "marker"
      vim.wo.foldlevel = 0
    end
  end
})

--- VVI: 这里只是进行了 key mapping 而没有直接设置 foldmethod. 避免超大文件切换速度慢.
--- 在使用 \k1 之前无法使用 zo zc ... 等快捷键.
vim.cmd([[
  au Filetype go,javascript,javascriptreact,typescript,typescriptreact,vue,svelte,python
  \ nnoremap <buffer> <leader>k1 :setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()
  \ foldnestmax=1 foldlevel=0<CR>
]])

--- 非代码文件不使用 'foldnestmax', 打开文件时也不进行折叠. 但是设置了 foldmethod, 可以直接使用 zc zo ... 等快捷键.
vim.cmd([[
  au Filetype css,less,scss,html,json,jsonc,graphql
  \ setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr() foldlevel=999
]])

--- 'foldnestmax' 设置对 marker 不生效. 打开文件时自动按照 marker {{{xxx}}} 折叠.
vim.cmd [[au Filetype vim,zsh,yaml setlocal foldmethod=marker foldlevel=0]]



