--- 通过 mason 安装 lsp 时需要对应名字. https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--- 要手动启动 lsp, 使用 `:LspStart xxx`

--- 获取 lsp 列表.
local lsp_servers_map = require('lsp.svr_list').list

--- 设置 & 启动单个 lsp
local function lspconfig_setup(lsp_svr)
  --- opts 必须包含 on_attach, capabilities 两个属性.
  --- 这里的 opts 获取到的是 require 文件中返回的 M.
  local opts = require("lsp.plugins.lsp_config.setup_opts")

  --- 加载 lsp 配置文件, "~/.config/nvim/lua/lsp/plugins/lsp_config/langs/..."
  --- 如果文件存在, 则加载自定义设置, 如果没有自定义设置则加载默认设置.
  --- NOTE: 单独 lsp 设置: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
  --- VVI: 必须 after require("lsp.plugins.lsp_config.setup_opts").
  local lsp_custom_status_ok, lsp_custom_opts = pcall(require, "lsp.plugins.lsp_config.langs." .. lsp_svr)
  if lsp_custom_status_ok then
    --- lsp_custom_opts: 初始设置
    opts = vim.tbl_deep_extend("force", opts, lsp_custom_opts)
  end

  --- VVI: 启动 lsp
  vim.lsp.config(lsp_svr, opts)
  vim.lsp.enable(lsp_svr)
end

--- setup 所有 lsp
for lsp_svr, _ in pairs(lsp_servers_map) do
  lspconfig_setup(lsp_svr)
end

--- `set filetype=xxx` 时 detach previous LSP.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    local lsp_clients = vim.lsp.get_clients({ bufnr = params.buf })
    for _, c in ipairs(lsp_clients) do
      --- `set filetype` 后, detach 所有不匹配该 buffer 新 filetype 的 lsp client.
      --- NOTE: 排除 null-ls
      if c.name ~= 'null-ls'
        and not vim.tbl_contains(c.config['filetypes'], vim.bo[params.buf].filetype)
      then
        vim.lsp.buf_detach_client(params.buf, c.id)
      end
    end
  end,
  desc = "LSP: detach previous LSP when `set filetype=xxx`",
})



