--- README:
--- mason.nvim 是一个 tools 安装 & 管理插件. 用于下载 lsp/formatter/linter/dap-debug 工具, eg: gopls, prettier, delve
--- 这些工具可以不通过 mason 安装, 可以手动安装在 $PATH 中. eg: `brew install xxx`

--- Mason 安装 LSP 时使用的名字和 LSP 命令行工具的名字有区别. 其他命令行工具名字(formatter/linter/dap)没有变化.
--- 名字的对应 https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--- mason-lspconfig 对应文件 https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua
--------------+------------------------------------------------+---------------------------------------------
--- LSP       | "neovim/nvim-lspconfig" setup()                |  MasonInstall
--------------+------------------------------------------------+---------------------------------------------
--- jsonls    | require("lspconfig")["jsonls"].setup(opts)     | `:MasonInstall json-lsp`
--------------+------------------------------------------------+---------------------------------------------
--- tsserver  | require("lspconfig")["tsserver"].setup(opts)   | `:MasonInstall typescript-language-server`
--------------+------------------------------------------------+---------------------------------------------
local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  return
end

local mason_reg_ok, mason_reg = pcall(require, "mason-registry")
if not mason_reg_ok then
  return
end

mason.setup {
  --- NOTE: LSP server 下载位置默认在 "~/.local/share/nvim/mason/"
  install_root_dir = vim.fn.stdpath("data") .. "/mason_tools",

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

--- check necessary tools --------------------------------------------------------------------------
--- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua
local mason_tools_needed = {
  ["bash-language-server"] = "bashls",
  buf = "buf",
  ["css-lsp"] = "cssls",
  ["html-lsp"] = "html",
  ["json-lsp"] = "jsonls",
  ["lua-language-server"] = "sumneko_lua",
  pyright = "pyright",
  shfmt = "shfmt",
  stylua = "stylua",
  ["typescript-language-server"] = "tsserver",
}

vim.schedule(function()
  local uninstalled_mason_tools = {}
  for mason_name, _ in pairs(mason_tools_needed) do
    if not mason_reg.is_installed(mason_name) then
      table.insert(uninstalled_mason_tools, "  - " .. mason_name)
    end
  end

  if #uninstalled_mason_tools > 0 then
    Notify(vim.list_extend({"tools need to be installed by :Mason"}, uninstalled_mason_tools), "WARN")
  end
end)



