-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
return {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        --- 所有 runtimepath 文件夹.
        -- library = vim.api.nvim_get_runtime_file("", true),  -- NOTE: this is a lot slower
        library = {
          --- NOTE: `:help $VIMRUNTIME` 是 vim 内置的 runtime 环境变量. 和 `:set runtimepath?` 不同.
          vim.env.VIMRUNTIME,  -- /usr/local/Cellar/neovim/0.xxx/share/nvim/runtime/
          vim.fn.stdpath("config"),  -- ~/.config/nvim/, NOTE: 包含以下所有路径.
          -- vim.fn.stdpath("config") .. "/init.lua",  -- ~/.config/nvim/init.lua
          -- vim.fn.stdpath("config") .. "/lua",     -- ~/.config/nvim/lua/
          -- vim.fn.stdpath("config") .. "/after",   -- ~/.config/nvim/after/
          --vim.fn.stdpath("config") .. "/plugin",  -- ~/.config/nvim/plugin/
        },
      },
    },
  },
}
