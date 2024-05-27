--- lspconfig 设置方法: require("lspconfig")["jsonls"].setup(opts), 设置后 jsonls 才会自动启动.
--- 通过 mason 安装 lsp 时需要对应名字. https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--- 要手动启动 lsp, 使用 `:LspStart xxx`

--- "neovim/nvim-lspconfig" 官方插件
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
  return
end

--- change `:LspInfo` border, `:help lspconfig-highlight`
require('lspconfig.ui.windows').default_options.border = Nerd_icons.border
vim.api.nvim_set_hl(0, 'LspInfoBorder', {link = 'FloatBorder'})

--- 需要设置的 lsp 列表.
local lsp_servers_map = require('lsp.svr_list').list

local function lspconfig_setup(lsp_svr)
  --- opts 必须包含 on_attach, capabilities 两个属性.
  --- 这里的 opts 获取到的是 require 文件中返回的 M.
  local opts = require("lsp.plugins.lsp_config.setup_opts")

  --- 加载 lsp 配置文件, "~/.config/nvim/lua/lsp/plugins/lsp_config/langs/..."
  --- 如果文件存在, 则加载自定义设置, 如果没有自定义设置则加载默认设置.
  --- NOTE: 单独 lsp 设置: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  --- VVI: 必须 after require("lsp.plugins.lsp_config.setup_opts").
  local lsp_custom_status_ok, lsp_custom_opts = pcall(require, "lsp.plugins.lsp_config.langs." .. lsp_svr)
  if lsp_custom_status_ok then
    opts = vim.tbl_deep_extend("force", opts, lsp_custom_opts)
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

        --- VVI: 第一次必须要手动 LspStart, 因为 lsp 是在 buffer 加载完成之后才执行 lspconfig[xxx].setup(),
        --- 所以触发 autocmd FileType 的 buffer 没有办法 attach lsp. 需要手动 `:LspStart` 进行 attach.
        --- 以下使用了 `:LspStart xxx` 的源代码. 也可以直接使用 vim.cmd('LspStart ' .. lsp_svr)
        local config = require('lspconfig.configs')[lsp_svr]
        if config then
          config.launch()  --- VVI: start & attach to buffer
        end

        --- DEBUG: 用. 每个 lsp 应该只打印一次.
        if __Debug_Neovim.lspconfig then
          Notify(":LspStart " .. lsp_svr, "DEBUG", {title="LSP"})
        end
      end)
    end,
    desc = "LSP: setup LSP based on FileType",
  })
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



