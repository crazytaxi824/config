--- lazy load opt plugins, loader() 名字可以查看 packer_compiled.lua
--- NOTE: 这里使用 auto BufEnter 是为了避免在多个 neovim 中重复打开同一个文件的时候出现 vim.schedule() 运行错误.
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = {"*"},
  once = true,
  callback = function(params)
    --- VVI: 加载顺序很重要
    vim.schedule(function()
      --- TreeSitter
      require('packer').loader('nvim-treesitter')

      --- Auto Completion
      require('packer').loader('nvim-cmp')

      --- LSP
      --- VVI: 如果要 lazyload lspconfig 时需要手动 `:LspStart`, 否则当前 buffer 的 autocmd 不会被执行.
      --- 使用 `:LspInfo` 查看会发现当前 bufnr 不在 LSP attach 中.
      --require('packer').loader('nvim-lspconfig')  -- NOTE: 目前没有使用 lazyload lspconfig, 会引起一些 bug.
      require('packer').loader('null-ls.nvim')  -- null-ls 和 lspconfig 没有依赖关系.

      --- Appearance
      --require('packer').loader('nvim-tree.lua')  -- NOTE: 不推荐使用 lazyload,
                                                   -- 会导致 `$ nvim dir` 直接打开文件夹的时候出现问题.
      require('packer').loader('lualine.nvim')
      require('packer').loader('bufferline.nvim')  -- NOTE: 需要先设置 showtabline=2 (always show tabline),
                                                   -- 否则在加载 bufferline 后屏幕会向下移动一行.

      --- Other useful tools
      require('packer').loader('nvim-autopairs')
      require('packer').loader('toggleterm.nvim')
      require('packer').loader('gitsigns.nvim')
      require('packer').loader('tagbar')

      --- VVI: 以下插件使用 lazyload 时, 需要设置 bufread=false. 否则会多次触发 FileType event.
      require('packer').loader('telescope.nvim')
      require('packer').loader('LuaSnip')  -- BUG: 目前 LuaSnip 使用 use({opt=true}) 时, 无法加载内置 jsregexp 插件.
    end)
  end
})



