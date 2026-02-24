--- 加载 local settings
local project_local_settings = require("lsp.project_local_settings")

--- 获取 lsp 列表
local lsp_servers_map = require('lsp.svr_list').list

--- cache local lsp settings
local local_lsp_settings = nil

--- 获取全局和本地 lsp 设置
---
--- @param lsp_tool string (lsp_name)
--- @return table lsp_config
local function load_lsp_configs(lsp_tool)
  --- 1. 如果文件存在, 则加载自定义设置, 如果没有自定义设置则加载默认设置.
  local status_ok, lsp_config = pcall(require, "lsp.lsp_config.tools." .. lsp_tool)
  if not status_ok then
    lsp_config = {}
  end

  --- 2. 加载项目本地设置, 覆盖 global settings.
  local local_settings = nil
  if local_lsp_settings and local_lsp_settings[lsp_tool] then
    local_settings = local_lsp_settings[lsp_tool]
  end

  --- 3. merge settings
  if local_settings then
    return vim.tbl_deep_extend('force', lsp_config, {settings = local_settings})
  end

  return lsp_config
end

local M = {}

--- 重新读取 project local settings 文件
function M.reload_local_settings()
  local_lsp_settings = project_local_settings.get_local_lsp_settings()
end

--- 返回当前本地 lsp 设置
---
--- @return table|nil
function M.exist_local_settings()
  return local_lsp_settings
end

--- 设置 & 启动单个 lsp
---
--- @param lsp_tool string
function M.lspconfig_setup(lsp_tool)
  --- config 必须包含 on_attach, capabilities 两个属性.
  local common_config = require("lsp.lsp_config.client_config")
  local lsp_config = vim.tbl_deep_extend('force', common_config, load_lsp_configs(lsp_tool))
  vim.lsp.config(lsp_tool, lsp_config)
end

--- 重启 lsp
--- @param lsp_tools string[]
function M.restart_lsps(lsp_tools)
  local tools = {}

  for _, lsp_tool in ipairs(lsp_tools) do
    if lsp_servers_map[lsp_tool] then
      M.lspconfig_setup(lsp_tool)  -- 重新配置 lsp config
      table.insert(tools, lsp_tool)
    end
  end

  --- restart lsps
  if #tools > 0 then
    vim.lsp.enable(tools, false)
    vim.lsp.enable(tools)
    vim.notify("restart lsp: " .. table.concat(tools, ", "))
  end
end

return M
