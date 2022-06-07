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

--- 读取项目本地设置
local ok = pcall(require, "user.lsp.load_proj_settings")
if not ok then
  return
end

--- VVI: 需要启用的 LSP server --------------------------------------------------------------------- {{{
--- 这里的 lsp server 都是通过 lsp-installer 安装的, 所以使用其提供的函数获取已安装列表.
--- get_available_servers()  -- 所有可以安装的 lsp server.
--- get_installed_servers()  -- 所有已安装的 lsp server.

--- 获取所有通过 lsp-installer 安装的 lsp server.
--- BUG: 第一次打开文件的时候 lsp_installer.get_installed_servers() 无法找到 gopls. 不知道为什么. 暂时警用该方法.
-- local function get_installed_server_names()
--   local svr_list = {}
--   for _, svr in ipairs(lsp_installer.get_installed_servers()) do
--     print(svr.name)
--     table.insert(svr_list, svr.name)  -- table.insert() 没有返回值.
--   end
--   return svr_list
-- end
--
-- local LSP_servers = get_installed_server_names()
-- print(vim.inspect(LSP_servers))
-- -- }}}
--- 手动指定需要启用的 lsp server.
--- 如果 lsp 已安装, 但是不在列表中也不会启动. 因为 lspconfig[LSP_server].setup() 也需要用到该 list.
local LSP_servers = { "jsonls", "sumneko_lua", "gopls", "tsserver", "pyright", "html", "cssls", "bashls" }

--- nvim-lsp-installer settings --------------------------------------------------------------------
lsp_installer.setup {
  -- NOTE: 其实这里不需要通过 lsp-installer 安装 gopls, 因为 gopls 在 $PATH 中,
  -- 所以 lspconfig 可以直接使用 gopls;
  -- 如果 gopls 不在 $PATH 中, 则使用 lsp-installer 下载的 gopls.
  ensure_installed = LSP_servers,   -- list 中设置的 LSP 如果没有安装, 则自动安装.

  -- LSP server 安装下载位置. 默认在 "~/.local/share/nvim/lsp_servers/..."
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

  log_level = vim.log.levels.WARN,  -- `:help vim.log.levels` 影响 `:LspInstallLog`
}

--- lspconfig setup() ------------------------------------------------------------------------------
vim.lsp.set_log_level("WARN")  -- `:help vim.lsp.set_log_level` 影响 `:LspLog`

for _, LSP_server in pairs(LSP_servers) do
  --- NOTE: opts 必须包含 on_attach, capabilities 两个属性.
  ---      这里的 opts 获取到的是 require 文件中返回的 M.
  local opts = require("user.lsp.setup_opts")

  --- NOTE: 加载 lsp 配置文件, "~/.config/nvim/lua/user/lsp/langs/..."
  --- 如果文件存在, 则加载自定义设置, 如果没有自定义设置则加载默认设置.
  local has_custom_opts, server_custom_opts = pcall(require, "user.lsp.langs." .. LSP_server)
  if has_custom_opts then
    -- tbl_deep_extend() 合并两个 table.
    opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
  end

  --- 加载项目本地设置
  opts = __Proj_local_settings.keep_extend("lsp", opts)

  --- VVI: 这里就是 lspconfig.xxx.setup() 针对不同的 lsp 进行加载.
  lspconfig[LSP_server].setup(opts)
end

--- 其他 LSP 相关设置 ------------------------------------------------------------------------------
--- VVI: 必须放在 lspconfig 加载之后, 因为有些函数需要用到 lspconfig 设置值.
require("user.lsp.handlers")    -- overwrite 默认 handlers 设置
require("user.lsp.diagnostic")  -- 加载 diagnostic 设置
require("user.lsp.null-ls")     -- 启动 null-ls
require("user.lsp.auto_format") -- save 时 format
require("user.lsp.user_command")  -- 自定义 lsp 相关 command



