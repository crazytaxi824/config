--- NOTE: lsp 设置: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

--- 获取 lsp 列表.
local lsp_servers_map = require('lsp.svr_list').list

--- 加载 local settings
local local_lsp_settings = require("lsp.project_local_settings.load_local_settings").get_local_lsp_settings()

--- 加载 lsp 配置文件, "~/.config/nvim/lua/lsp/lsp_config/tools/..."
--- 如果文件存在, 则加载自定义设置, 如果没有自定义设置则加载默认设置.
local function lsp_global_opts(lsp_tool, opts)
  local status_ok, global_opts = pcall(require, "lsp.lsp_config.tools." .. lsp_tool)
  if not status_ok then
    return opts
  end
  return vim.tbl_deep_extend("force", opts, global_opts)
end

--- 加载项目本地设置, 覆盖 global settings.
local function lsp_local_opts(lsp_tool, opts)
  if not local_lsp_settings then
    return opts
  end

  local local_opts = local_lsp_settings[lsp_tool]
  if not local_opts then
    return opts
  end

  --- 如果原本没有设置 settings, 则设置 settings.
  if not opts.settings then
    opts.settings = local_opts
    return opts
  end

  --- 如果原本设置了 settings, 则修改 settings 设置.
  for key, value in pairs(local_opts) do
    local settings = opts.settings[key]
    if settings then
      --- key 存在
      opts.settings[key] = vim.tbl_deep_extend('force', settings, value)
    else
      --- key 不存在
      opts.settings[key] = value
    end
  end
  return opts
end

--- 设置 & 启动单个 lsp
local function lspconfig_setup(lsp_tool)
  --- NOTE: opts 必须包含 on_attach, capabilities 两个属性.
  local opts = require("lsp.lsp_config.client_config")
  opts = vim.tbl_deep_extend('force', opts, {})  -- deep copy table

  --- 先加载 global_opts, 再加载 project_local_settings
  opts = lsp_global_opts(lsp_tool, opts)
  opts = lsp_local_opts(lsp_tool, opts)

  --- VVI: 启动 lsp
  vim.lsp.config(lsp_tool, opts)
  vim.lsp.enable(lsp_tool)
end

--- setup 所有 lsp
for lsp_tool, _ in pairs(lsp_servers_map) do
  lspconfig_setup(lsp_tool)
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



