--- lspconfig 设置方法: require("lspconfig")["jsonls"].setup(opts), 设置后 jsonls 才会自动启动.
--- 通过 mason 安装 lsp 时需要对应名字. https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--- 要手动启动 lsp, 使用 `:LspStart xxx`

--- "neovim/nvim-lspconfig" 官方插件
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
  return
end

--- change `:LspInfo` border, `:help lspconfig-highlight`
require('lspconfig.ui.windows').default_options.border = {"▄","▄","▄","█","▀","▀","▀","█"}
vim.cmd('hi! link LspInfoBorder FloatBorder')

--- 以下命令行工具可以通过 mason.nvim 安装, 也可以通过 brew 安装到 $PATH 中.
--- filetypes: 可以通过 `:LspInfo` 查看. 用于 autocmd.
--- lspconfig_name: filetype
local lsp_servers_map = {
  lua_ls = {
    cmd = "lua-language-server",
    mason = "lua-language-server",
    filetypes = {'lua'}
  },
  tsserver = {
    cmd = "typescript-language-server",
    mason = "typescript-language-server",
    filetypes = {
      'javascript', 'javascriptreact', 'javascript.jsx',
      'typescript', 'typescriptreact', 'typescript.tsx',
    }
  },
  bashls = {
    cmd = "bash-language-server",
    mason = "bash-language-server",
    filetypes = {'sh'}
  },
  gopls = {
    cmd = "gopls",
    mason = "gopls",
    install = "go install golang.org/x/tools/gopls@latest",
    filetypes = {'go', 'gomod', 'gowork', 'gotmpl'}
  },
  pyright = {
    cmd = "pyright",
    mason = "pyright",
    filetypes = {'python'}
  },
  html = {
    cmd = "vscode-html-language-server",
    mason = "html-lsp",
    filetypes = {'html'}
  },
  cssls = {
    cmd = "vscode-css-language-server",
    mason = "css-lsp",
    filetypes = {'css', 'scss', 'less'}
  },
  jsonls = {
    cmd = "vscode-json-language-server",
    mason = "json-lsp",
    filetypes = {'json', 'jsonc'}
  },
  bufls = {  -- protobuf lsp
    cmd = "bufls",
    mason = "buf-language-server",
    filetypes = {'proto'},
  }
}

local function lspconfig_setup(lsp_svr)
  --- opts 必须包含 on_attach, capabilities 两个属性.
  --- 这里的 opts 获取到的是 require 文件中返回的 M.
  local opts = require("user.lsp.lsp_config.setup_opts")

  --- 加载 lsp 配置文件, "~/.config/nvim/lua/user/lsp/lsp_config/langs/..."
  --- 如果文件存在, 则加载自定义设置, 如果没有自定义设置则加载默认设置.
  --- NOTE: 单独 lsp 设置: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  local lsp_setting = vim.fn.stdpath('config') .. '/lua/user/lsp/lsp_config/langs/' .. lsp_svr .. '.lua'
  if vim.fn.filereadable(lsp_setting) == 1 then
    --- 使用 pcall() 是为了确保 xxx.lua 文件执行没有问题.
    local lsp_custom_status_ok, lsp_custom_opts = pcall(require, "user.lsp.lsp_config.langs." .. lsp_svr)
    if lsp_custom_status_ok then
      opts = vim.tbl_deep_extend("force", opts, lsp_custom_opts)
    end
  end

  --- VVI: 这里就是 lspconfig.xxx.setup() 针对不同的 lsp 进行加载.
  lspconfig[lsp_svr].setup(opts)
end

--- 官方设置 --------------------------------------------------------------------------------------- {{{
-- --- 检查 lsp tools 是否安装
-- Check_cmd_tools(vim.tbl_values(lsp_servers_map), {title="LSP_config"})
--
-- --- setup 所有 lsp
-- for lsp_svr, _ in pairs(lsp_servers_map) do
--   lspconfig_setup(lsp_svr)
-- end
--
-- --- VVI: 如果使用 lazyload vim.schedule() 方式加载 lspconfig[xxx].setup() 的情况下,
-- --- 启动 nvim 后需要手动 ":LspStart" 所有 lsp. 因为 lspconfig[xxx].setup() 在第一个加载的 buffer
-- --- 后面启动, 所以第一个 buffer 无法 attach lsp. ":LspStart" 可以让 lsp attach 该 buffer.
-- --- 如果 lsp 还没有被 setup 则不会启动. 所以这里可以放心 LspStart 所有 lsp.
-- vim.cmd('LspStart ' .. table.concat(vim.tbl_keys(lsp_servers_map), " "))
-- -- }}}

--- 以下设置是为了 autocmd 根据 FileType 手动加载/启动不同的 lsp -----------------------------------
for lsp_svr, v in pairs(lsp_servers_map) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = v.filetypes,
    once = true,  --- VVI: only need to start LSP server once.
    callback = function(params)
      --- NOTE: lazyload lspconfig
      vim.schedule(function()
        --- lspconfig[lsp_svr].setup(opt), 根据 filetype 设置 lsp
        lspconfig_setup(lsp_svr)

        --- VVI: 第一次必须要手动启动 lsp, 因为 vim.schedule() 会导致新 filetype 的 buffer 加载完成之后
        --- 才执行 lspconfig[xxx].setup(), 所以该 buffer 没有 attach lsp. 需要手动 `:LspStart` 进行 attach.
        vim.cmd('LspStart ' .. lsp_svr)

        --- DEBUG: 用. 每个 lsp 应该只打印一次.
        if __Debug_Neovim.lspconfig then
          Notify(":LspStart " .. lsp_svr, "DEBUG", {title="LSP"})
        end
      end)

      --- 检查 lsp tools 是否安装
      require('user.utils.check_tools').check(v, {title="LSP_config"})
    end,
    desc = "setup LSP based on FileType",
  })
end

--- `set filetype=xxx` 时 detach previous LSP.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    local lsp_clients = vim.lsp.get_active_clients({ bufnr = params.buf })
    for _, c in ipairs(lsp_clients) do
      --- `set filetype` 后, detach 所有不匹配该 buffer 新 filetype 的 lsp client.
      --- NOTE: 排除 null-ls 是因为 gitsigns 等工具是不分 filetype 的.
      if c.name ~= 'null-ls'
        and not vim.tbl_contains(c.config.filetypes, vim.bo[params.buf].filetype)
      then
        vim.lsp.buf_detach_client(params.buf, c.id)
      end
    end
  end,
  desc = "detach previous LSP when `set filetype=xxx`",
})



