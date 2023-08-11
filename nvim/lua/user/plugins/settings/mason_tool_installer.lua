--- README:
--- mason.nvim 是一个 tools 安装 & 管理插件. 用于下载 lsp/formatter/linter/dap-debug 工具, eg: gopls, prettier, delve
--- 这些工具可以不通过 mason 安装, 可以手动安装在 $PATH 中. eg: `brew install xxx`
--- 可以使用 require("mason-registry").is_installed("json-lsp") 来判断工具是否被 mason 安装.

--- mason 安装 LSP 时使用的名字和 "nvim-lspconfig" setup() 的名字有区别.
--- mason 安装的 tools 的名字可能和命令行工具的名字也不一样. eg: "delve" 的命令行工具文件名是 "dlv"
--- 名字的对应 https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--- mason-lspconfig 对应文件 https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| cmd_line_tool Name          |  Mason Name                                | "neovim/nvim-lspconfig" setup() Name           |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| gopls                       | `:MasonInstall gopls`                      | require("lspconfig")["gopls"].setup(opts)      |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| vscode-json-language-server | `:MasonInstall json-lsp`                   | require("lspconfig")["jsonls"].setup(opts)     |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| typescript-language-server  | `:MasonInstall typescript-language-server` | require("lspconfig")["tsserver"].setup(opts)   |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
---| dlv                         | `:MasonInstall delve`                      |                                                |
---+-----------------------------+--------------------------------------------+------------------------------------------------+
local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  return
end

mason.setup {
  --- NOTE: LSP server 下载位置默认在 "~/.local/share/nvim/mason/"
  install_root_dir = vim.fn.stdpath("data") .. "/mason_tools",

  --- Where Mason should put its bin location in your PATH. Can be one of:
  --- - "prepend" (default, Mason's bin location is put first in PATH), 优先找到 Mason 的命令行工具.
  --- - "append" (Mason's bin location is put at the end of PATH)
  --- - "skip" (doesn't modify PATH)
  PATH = "prepend",

  max_concurrent_installers = 4,  -- 并发安装数量.

  ui = {
    check_outdated_packages_on_open = true,  -- 打开面板时检查 outdated lsp
    --border = {"▄","▄","▄","█","▀","▀","▀","█"},  -- 默认为: 'none'
    icons = {
      package_installed = "✓", -- ✓✔︎
      package_pending = "➜",
      package_uninstalled = "⛌", -- ❌✕✖︎✗✘⛌
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



