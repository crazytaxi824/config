--- lazy load opt plugins, loader() 名字可以查看 packer_compiled.lua
--- NOTE: 这里使用 auto BufEnter 是为了避免在多个 neovim 中重复打开同一个文件的时候出现 vim.schedule() 运行错误.
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = {"*"},
  once = true,
  callback = function()
    --- VVI: 加载顺序很重要
    vim.schedule(function()
      --- TreeSitter 一系列插件 lazy load
      require('packer').loader('nvim-treesitter')

      --- Auto Completion 一系列插件 lazy load
      require('packer').loader('nvim-cmp')

      --- LSP 一系列插件 lazy load
      require('packer').loader('nvim-lspconfig')
      --require('packer').loader('null-ls.nvim')  -- NOTE: 使用 after = "nvim-lspconfig" 加载

      --- Appearance plugins
      require('packer').loader('nvim-tree.lua')
      require('packer').loader('lualine.nvim')
      require('packer').loader('bufferline.nvim')  -- NOTE: 需要先设置 showtabline=2 (always show tabline),
                                                   -- 否则在加载 bufferline 后屏幕会向下移动一行.

      --- Other useful tools
      require('packer').loader('nvim-autopairs')
      require('packer').loader('telescope.nvim')
      require('packer').loader('toggleterm.nvim')
      require('packer').loader('gitsigns.nvim')
      require('packer').loader('tagbar')
    end)
  end
})



