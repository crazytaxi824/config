--- lazy load opt plugins, loader() 名字可以查看 packer_compiled.lua
--- 这里使用 BufEnter 是为了避免在多个 neovim 中重复打开同一个文件的时候出现 vim.schedule() 运行错误.
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
      --- NOTE: 加载 "__Proj_local_settings". 用于读取项目本地 lsp/linter 设置.
      local proj_settings_status_ok = pcall(require, "user.lsp.util.load_proj_settings")
      if proj_settings_status_ok then
        require('packer').loader('nvim-lspconfig')
        --require('packer').loader('null-ls.nvim')  -- NOTE: 使用 after = "nvim-lspconfig" 加载
      end

      require('packer').loader('nvim-autopairs')
      require('packer').loader('telescope.nvim')
      require('packer').loader('toggleterm.nvim')
      require('packer').loader('tagbar')
    end)
  end
})

