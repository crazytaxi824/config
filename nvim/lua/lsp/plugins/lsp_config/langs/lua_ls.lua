-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
return {
  --- will overwrite previous settings because
  on_init = function(client)
    if client.server_capabilities then
      client.server_capabilities.semanticTokensProvider = nil
    end

    --- if the root_dir cannot be found, then workspace_folders will be nil.
    local workspace_folders = client.workspace_folders
    if workspace_folders then
      local path = workspace_folders[1].name
      if vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc') then
        return
      end
    end

    --- 这里是在没有 .luarc.json 的情况下向 settings 中插入设置.
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT'
      },
      diagnostics = {
        globals = { "vim" },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          --- NOTE: `:help $VIMRUNTIME` 是 vim 内置的 runtime 环境变量. 和 `:set runtimepath?` 不同.
          vim.env.VIMRUNTIME,  -- /usr/local/Cellar/neovim/0.xxx/share/nvim/runtime/
          vim.fn.stdpath("config"),  -- ~/.config/nvim/ 目录下的 global function
          "${3rd}/luv/library",  -- vim.vu function
          -- "${3rd}/busted/library",
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
