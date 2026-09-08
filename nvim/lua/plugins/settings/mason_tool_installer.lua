-- DOCS:
-- mason.nvim 是一个 tools 安装 & 管理插件. 用于下载 lsp/formatter/linter/dap-debug 工具, eg: gopls, prettier, delve
-- 这些工具可以不通过 mason 安装, 可以手动安装在 $PATH 中. eg: `brew install xxx`
-- 可以使用 require("mason-registry").is_installed("json-lsp") 来判断工具是否被 mason 安装.
-- require("mason-registry").get_installed_packages()

-- mason 安装 LSP 时使用的名字和 "nvim-lspconfig" setup() 的名字有区别.
-- mason 安装的 tools 的名字可能和命令行工具的名字也不一样. eg: "delve" 的命令行工具文件名是 "dlv"
-- mason-lspconfig 对应名字 https://github.com/mason-org/mason-registry
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| cmd_line_tool Name          |  Mason Name                                | "neovim/nvim-lspconfig" setup() Name           |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| gopls                       | `:MasonInstall gopls`                      | require("lspconfig")["gopls"].setup(opts)      |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| vscode-json-language-server | `:MasonInstall json-lsp`                   | require("lspconfig")["jsonls"].setup(opts)     |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| vscode-html-language-server | `:MasonInstall html-lsp`                   | require("lspconfig")["html"].setup(opts)       |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| dlv                         | `:MasonInstall delve`                      |                                                |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  return
end

mason.setup {
  -- NOTE: LSP server 下载位置默认在 "~/.local/share/nvim/mason/"
  install_root_dir = vim.fn.stdpath("data") .. "/mason_tools",

  -- Where Mason should put its bin location in your PATH. Can be one of:
  -- - "prepend" (default, Mason's bin location is put first in PATH), 优先找到 Mason 的命令行工具.
  -- - "append" (Mason's bin location is put at the end of PATH)
  -- - "skip" (doesn't modify PATH)
  PATH = "prepend",

  max_concurrent_installers = 4,  -- 并发安装数量.

  -- 使用 Socket.dev firewall, 防止依赖被投毒
  -- firewall = {
  --   enabled = true,
  --   auto_managed = true,  -- true: 使用 Mason 自己下载的 sfw | false: 使用 $PATH 中的 sfw
  -- },

  pip = {
    -- VVI: 只允许安装 wheel, 防止供应链投毒.
    install_args = { "--only-binary=:all:" },
  },

  npm = {
    -- VVI: 禁止 npm install 时执行 package.json 中的 preinstall/postinstall shell 命令. 防止供应链投毒.
    install_args = { "--ignore-scripts" },
  },

  ui = {
    check_outdated_packages_on_open = true,  -- 打开面板时检查 outdated lsp
    border = Nerd_icons.border,
    backdrop = 100,  -- 会造成底层 window 颜色变深
    width = 0.6,  -- mason/lazy 尽量设置为相同
    -- height = 0.75,

    icons = {
      package_installed = Nerd_icons.check,
      package_pending = Nerd_icons.arrows.right,
      package_uninstalled = Nerd_icons.dot_h,
    },

    keymaps = {
      uninstall_package = "D",        -- uninstall a lsp server
      toggle_help = "?",
    },
  },

  log_level = vim.log.levels.WARN,  -- 影响 `:MasonLog`
}

-- NOTE: 必须在 mason.setup() 之后才能获取到 pkgs
-- local reg = require("mason-registry")
-- for _, pkg in ipairs(reg.get_installed_package_names()) do
--   print(pkg)
-- end



