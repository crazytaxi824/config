-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
return {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc')) then
        return
      end
    end

    --- 这里是在没有 .luarc.json 的情况下向 settings 中插入设置.
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT'
      },
      diagnostics = {
        globals = { "vim" },  -- Recognize 'vim' as a global variable
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          --- NOTE: `:help $VIMRUNTIME` 是 vim 内置的 runtime 环境变量. 和 `:set runtimepath?` 不同.
          vim.env.VIMRUNTIME,  -- /usr/local/Cellar/neovim/0.xxx/share/nvim/runtime/
          vim.fn.stdpath("config"),  -- ~/.config/nvim/ 目录下的 global function
          "${3rd}/luv/library",  -- Luv 是基于 libuv 的 Lua 库提供异步 I/O 操作, eg: vim.vu
          -- "${3rd}/busted/library", -- Busted 是一个 Lua 的单元测试框架
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,

  --- 这里是在有 .luarc.json 的情况下不设置任何属性.
  settings = {
    Lua = {}  -- VVI: 必须为 {}, 否则在上面 tbl_deep_extend() 时会报错.
  }
}
