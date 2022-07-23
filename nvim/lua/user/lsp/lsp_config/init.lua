--- "neovim/nvim-lspconfig" 官方插件
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
  return
end

--- "nvim-lsp-installer" 插件
local lsp_installer_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not lsp_installer_ok then
  return
end

--- 手动指定需要启用的 lsp server.
--- 如果 lsp 已安装, 但是不在列表中也不会启动. 因为 lspconfig[LSP_server].setup() 也需要用到该 list.
local lsp_servers = { "jsonls", "sumneko_lua", "gopls", "tsserver", "pyright", "html", "cssls", "bashls" }

--- nvim-lsp-installer setup() ---------------------------------------------------------------------
lsp_installer.setup {
  -- NOTE: 其实这里不需要通过 lsp-installer 安装 gopls, 因为 gopls 在 $PATH 中,
  -- 所以 lspconfig 可以直接使用 gopls;
  -- 如果 gopls 不在 $PATH 中, 则使用 lsp-installer 下载的 gopls.
  ensure_installed = lsp_servers,   -- list 中设置的 LSP 如果没有安装, 则自动安装.

  -- NOTE: LSP server 下载位置默认在 "~/.local/share/nvim/lsp_servers/..."
  --install_root_dir = vim.fn.stdpath("data") .. "/lsp_servers",

  automatic_installation = false, -- 在 lspconfig.xxx.setup() 的 LSP 自动安装.
  max_concurrent_installers = 4,  -- 并发安装数量.

  ui = {
    check_outdated_servers_on_open = true,  -- 打开面板时检查 outdated lsp
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗"
    },
    keymaps = {
      toggle_server_expand = "<CR>",  -- expand a server in the UI
      install_server = "i",           -- install a server
      check_server_version = "c",     -- check LSP version under the cursor
      check_outdated_servers = "C",   -- check all LSP version
      update_server = "u",            -- reinstall/update a server
      update_all_servers = "U",       -- update all installed servers
      uninstall_server = "D",         -- uninstall a server
    },
  },

  log_level = vim.log.levels.WARN,  -- 影响 `:LspInstallLog`
}

--- lspconfig setup() ------------------------------------------------------------------------------
for _, lsp_svr in pairs(lsp_servers) do
  --- NOTE: opts 必须包含 on_attach, capabilities 两个属性.
  ---       这里的 opts 获取到的是 require 文件中返回的 M.
  local opts = require("user.lsp.lsp_config.setup_opts")

  --- NOTE: 加载 lsp 配置文件, "~/.config/nvim/lua/user/lsp/lsp_config/langs/..."
  --- 如果文件存在, 则加载自定义设置, 如果没有自定义设置则加载默认设置.
  if vim.fn.filereadable(vim.fn.stdpath('config') .. '/lua/user/lsp/lsp_config/langs/' .. lsp_svr .. '.lua') == 1 then
    --- NOTE: 这里使用 pcall() 是为了确保 xxx.lua 文件执行没有问题.
    local lsp_custom_status_ok, lsp_custom_opts = pcall(require, "user.lsp.lsp_config.langs." .. lsp_svr)
    if lsp_custom_status_ok then
      opts = vim.tbl_deep_extend("force", opts, lsp_custom_opts)
    end
  end

  --- VVI: 这里就是 lspconfig.xxx.setup() 针对不同的 lsp 进行加载.
  lspconfig[lsp_svr].setup(opts)
end

--- 其他 LSP 相关设置 ------------------------------------------------------------------------------
--- VVI: 必须放在 lspconfig 加载之后, 因为有些函数需要用到 lspconfig 设置值.
require("user.lsp.lsp_config.handlers")    -- overwrite 默认 handlers 设置



