--- 根据不同情况设置不同的折叠方式.
--- VVI: 不要在打开代码前设置 foldmethod=syntax, 会严重拖慢文件切换速度. eg: jump to definition.
---
--- foldmethod     treesitter experimental function.
---
--- foldnestmax=1  只 fold 最外层(第一层). 默认 20, 最大值也是 20, 设置超过该值不生效.
---                BUG: 'foldnestmax' 需要放在 'foldlevel' 之前设置, 否则不生效.
---
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
      vim.opt_local.foldmethod = "marker"
      vim.opt_local.foldlevel = 0
    end
  end
})

--- VVI: 这里只是进行了 key mapping 而没有直接设置 foldmethod. 避免超大文件切换速度慢.
--- 在使用 \k1 之前无法使用 zo zc ... 等快捷键. NOTE: 每次执行 \k1 都会重新设置 foldnestmax.
--- BUG: 'foldnestmax' 需要放在 'foldlevel' 之前设置, 否则不生效.
-- vim.cmd([[
--   au Filetype go,javascript,javascriptreact,typescript,typescriptreact,vue,svelte,python,
--   \css,less,scss,html,json,jsonc,graphql,markdown,sh,bash
--   \ nnoremap <buffer> <silent> <leader>k0
--   \ :setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()
--   \ foldlevel=0<CR>
-- ]])

vim.api.nvim_create_autocmd("FileType", {
  pattern = {'go','javascript','javascriptreact','typescript','typescriptreact','vue',
    'svelte','python','css','less','scss','html','json','jsonc','graphql','markdown','sh','bash'},
  callback = function(params)
    vim.keymap.set('n', '<leader>k0', function()
      vim.opt_local.foldmethod='expr'
      vim.opt_local.foldexpr='nvim_treesitter#foldexpr()'
      vim.opt_local.foldlevel=0
    end, {buffer=params.buf, silent=true, noremap=true, desc='Close all folds'})

    vim.keymap.set('n', '<leader>k1', function()
      vim.opt_local.foldmethod='expr'
      vim.opt_local.foldexpr='nvim_treesitter#foldexpr()'
      vim.opt_local.foldlevel=0
      vim.cmd('silent! foldopen!')  -- NOTE: `:foldopen!` 相当于 `zO`
    end, {buffer=params.buf, silent=true, noremap=true, desc='Focus current text'})
  end
})

--- 非代码文件不使用 'foldnestmax', 打开文件时也不进行折叠. 但是设置了 foldmethod, 可以直接使用 zc zo ... 等快捷键.
--- NOTE: 因为 nvim-treesitter 是 lazyload 所以这里运行时 nvim_treesitter#foldexpr() 无法执行.
-- vim.cmd([[
--   au Filetype css,less,scss,html,json,jsonc,graphql,markdown
--   \ setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr() foldlevel=999
-- ]])

--- 'foldnestmax' 设置对 marker 不生效. 打开文件时自动按照 marker {{{xxx}}} 折叠.
vim.cmd([[au Filetype vim,zsh,yaml setlocal foldmethod=marker foldlevel=0]])

--- 切换 foldmethod
vim.api.nvim_create_user_command('FoldmethodToggle', function()
  if vim.wo.foldmethod == 'expr' then
    vim.opt_local.foldmethod='marker'
  else
    vim.opt_local.foldmethod='expr'
    vim.opt_local.foldexpr='nvim_treesitter#foldexpr()'
  end
end, {bang=true, bar=true})



