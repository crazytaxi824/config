--- run `:LspRestart` after golang file saved.
--- NOTE: 如果添加/删除了 module 或者更新了 module 名字(filepath), 而不执行 `:LspRestart`,
--- gopls 无法找到新的 module, 也无法提供代码补全.
--- 目前只有 gopls 需要重新加载. tsserver 不需要重新加载就可以找到新 module, eg: tsx 文件.

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {"*.go"},
  command = "LspRestart",
})



