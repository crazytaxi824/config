--- README:
--- mason.nvim 是一个 tools 安装 & 管理插件. 用于下载 lsp/formatter/linter/debug 工具, eg: gopls, prettier ...
--- 这些工具可以不通过 mason 安装, 可以手动安装在 $PATH 中. eg: `brew install xxx`
local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  return
end

mason.setup {
  --- NOTE: LSP server 下载位置默认在 "~/.local/share/nvim/mason_lsp_servers/..."
  install_root_dir = vim.fn.stdpath("data") .. "/mason_lsp_servers",

  max_concurrent_installers = 4,  -- 并发安装数量.

  ui = {
    check_outdated_packages_on_open = true,  -- 打开面板时检查 outdated lsp

    border = {"▄","▄","▄","█","▀","▀","▀","█"},  -- 默认为: 'none'

    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    },

    keymaps = {
      toggle_package_expand = "<CR>", -- expand a server in the UI
      install_package = "i",          -- install a server
      check_package_version = "c",    -- check LSP version under the cursor
      check_outdated_packages = "C",  -- check all LSP version
      update_package = "u",           -- reinstall/update a server
      update_all_packages = "U",      -- update all installed servers
      uninstall_package = "D",        -- uninstall a lsp server
    },
  },

  log_level = vim.log.levels.WARN,  -- 影响 `:MasonLog`
}



