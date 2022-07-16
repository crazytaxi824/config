-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
return {
  settings = {
    Lua = {
      -- runtime = {
      --   version = 'LuaJIT',
      -- },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        --- NOTE: nvim_get_runtime_file() 列出所有 runtimepath ~/.local/share/nvim/site/pack/*/start/* 文件夹.
        --library = vim.api.nvim_get_runtime_file("", true),  -- VVI: DO NOT use this.
        library = {
          vim.fn.expand("$VIMRUNTIME/lua"),
          vim.fn.stdpath("config") .. "/lua",     -- ~/.config/nvim/lua/
          vim.fn.stdpath("config") .. "/after",   -- ~/.config/nvim/after/
          --vim.fn.stdpath("config") .. "/plugin",  -- ~/.config/nvim/plugin/
        },
      },
    },
  },
}
