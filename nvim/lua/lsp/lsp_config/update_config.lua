--- 加载 local settings
local project_local_settings = require("lsp.project_local_settings")

--- cache local lsp settings
local local_lsp_settings = nil

--- 加载 lsp 配置文件, "~/.config/nvim/lua/lsp/lsp_config/tools/..."
--- 如果文件存在, 则加载自定义设置, 如果没有自定义设置则加载默认设置.
local function lsp_global_opts(lsp_tool, config)
  local status_ok, global_config = pcall(require, "lsp.lsp_config.tools." .. lsp_tool)
  if not status_ok then
    return config
  end
  global_config = vim.deepcopy(global_config) -- VVI: deep copy 防止 require() 的内容后续被修改
  return vim.tbl_deep_extend("force", config, global_config)
end

--- 加载项目本地设置, 覆盖 global settings.
local function lsp_local_opts(lsp_tool, config)
  if not local_lsp_settings then
    return config
  end

  local local_settings = local_lsp_settings[lsp_tool]
  if not local_settings then
    return config
  end

  --- 如果原本没有设置 settings, 则设置 settings.
  if not config.settings then
    config.settings = local_settings
    return config
  end

  --- 如果原本设置了 settings, 则修改 settings 设置.
  for key, value in pairs(local_settings) do
    local cfg_settings = config.settings[key]
    if cfg_settings then
      --- key 存在
      config.settings[key] = vim.tbl_deep_extend('force', cfg_settings, value)
    else
      --- key 不存在
      config.settings[key] = value
    end
  end
  return config
end

local M = {}

--- 重新读取 project local settings 文件
M.reload_local_settings = function()
  local_lsp_settings = project_local_settings.get_local_lsp_settings()
end

M.exist_settings = function()
  return local_lsp_settings
end

--- 设置 & 启动单个 lsp
--- @param lsp_tool string
M.lspconfig_setup = function(lsp_tool)
  --- config 必须包含 on_attach, capabilities 两个属性.
  local config = require("lsp.lsp_config.client_config")
  config = vim.deepcopy(config)  -- VVI: deep copy 防止 require() 的内容后续被修改

  --- 先加载 global_opts
  config = lsp_global_opts(lsp_tool, config)
  config = lsp_local_opts(lsp_tool, config)

  vim.lsp.config(lsp_tool, config)
end

--- @param lsp_tools string[]
M.restart_lsps = function(lsp_tools)
  vim.lsp.enable(lsp_tools, false) -- disable
  for _, lsp_tool in ipairs(lsp_tools) do
    M.lspconfig_setup(lsp_tool)  -- 重新配置
  end

  --- VVI: 在 schedule() 中等待 lspconfig_setup() 配置完成后再启动, 否则可能导致 lsp config 配置无法更新.
  vim.schedule(function()
    vim.lsp.enable(lsp_tools)  -- enable
  end)
end

return M
