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
  --- NOTE: 单独 lsp 设置: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
  --- VVI: 必须 after require("lsp.plugins.lsp_config.setup_opts").
  local lsp_custom_status_ok, lsp_custom_opts = pcall(require, "lsp.plugins.lsp_config.langs." .. lsp_svr)
  if lsp_custom_status_ok then
    opts = vim.tbl_deep_extend("force", opts, lsp_custom_opts)
  end

  --- cache settings, local project 都是在 default settings 上面做修改, 不是和上一次作比较.
  opts.default_config[lsp_svr] = opts.settings or {}

  --- VVI: 这里就是 lspconfig.xxx.setup() 针对不同的 lsp 进行加载.
  lspconfig[lsp_svr].setup(opts)

  --- return config for launch()
  return lspconfig[lsp_svr]
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
--- lspconfig[lsp].setup() 只能够执行一次, 如果重复执行 setup() 会重新生成一个新的 lsp_client, 同时删除之前的 lsp_client.
--- 所以必须要记录已经 setup 的 lsp.
local cache_setup_lsp = {}

--- 这里使用 autocmd FileType 来执行 setup() once, 但是问题是 setup() 并不能启动 lsp, 还需要 :LspStart 来启动.
--- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs.lua, 源代码中表明:
--- M.launch() 函数是在 M.setup() 函数中定义的, 所以只有 setup() 之后才能够使用 launch().
for lsp_svr, v in pairs(lsp_servers_map) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = v.filetypes,
    once = true,  --- VVI: LSP should only setup once. 虽然是 once 但不同的 filetype 都会运行一次.
    callback = function(params)
      --- setup lsp config. VVI: 每次 setup() 都会重新创建一个新的 lsp.
      if not vim.tbl_contains(cache_setup_lsp, lsp_svr) then
        local lsp_cfg = lspconfig_setup(lsp_svr)
        table.insert(cache_setup_lsp, lsp_svr)

        --- 以下使用了 `:LspStart xxx` 的源代码. 也可以直接使用 vim.cmd('LspStart ' .. lsp_svr)
        --- https://github.com/neovim/nvim-lspconfig/blob/master/plugin/lspconfig.lua
        lsp_cfg.launch()
      end
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



