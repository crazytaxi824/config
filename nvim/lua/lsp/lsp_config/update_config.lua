-- 加载 local settings
local project_local_settings = require("lsp.project_local_settings")
local common_config = require("lsp.lsp_config.client_config")

-- 获取 lsp 列表
local lsp_servers_map = require('lsp.svr_list').list

-- cache local lsp settings
local local_lsp_settings = nil

-- 获取全局和本地 lsp 设置
--
---@param lsp_tool string  lsp_name
---@return table lsp_config
local function load_lsp_configs(lsp_tool)
  -- 1. 如果文件存在, 则加载自定义设置, 如果没有自定义设置则加载默认设置.
  local status_ok, lsp_config = pcall(require, "lsp.lsp_config.tools." .. lsp_tool)
  if not status_ok then
    lsp_config = {}
  end

  -- 2. 加载项目本地设置, 覆盖 global settings.
  local local_settings = nil
  if local_lsp_settings and local_lsp_settings[lsp_tool] then
    local_settings = local_lsp_settings[lsp_tool]
  end

  -- 3. merge settings
  if local_settings then
    return vim.tbl_deep_extend('force', lsp_config, {settings = local_settings})
  end

  return lsp_config
end

local M = {}

-- 重新读取 project local settings 文件
function M.reload_local_settings()
  local settings = project_local_settings.get_local_lsp_settings()
  if settings == nil then
    return false
  end

  local_lsp_settings = settings
  return true
end

-- 返回当前本地 lsp 设置
--
---@return table|nil
function M.exist_local_settings()
  return local_lsp_settings
end

-- 设置单个 lsp
--
---@param lsp_tool string
function M.lspconfig_setup(lsp_tool)
  local lsp_tool_conf = load_lsp_configs(lsp_tool)

  local on_init = common_config.on_init  ---@cast on_init fun(client: vim.lsp.Client, init_result: lsp.InitializeResult)?
  local on_exit = common_config.on_exit  ---@cast on_exit fun(code: integer, signal: integer, client_id: integer)?
  local on_attach = common_config.on_attach  ---@cast on_attach fun(client: vim.lsp.Client, bufnr: integer)?

  local cache_fns = {
    ---@type fun(client: vim.lsp.Client, init_result: lsp.InitializeResult)[]
    on_init = { on_init },

    ---@type fun(code: integer, signal: integer, client_id: integer)[]
    on_exit = { on_exit },

    ---@type fun(client: vim.lsp.Client, bufnr: integer)[]
    on_attach = { on_attach },
  }

  -- cache functions
  for fn_key, _ in pairs(cache_fns) do
    table.insert(cache_fns[fn_key], lsp_tool_conf[fn_key])
  end

  -- 将 function list 赋值
  -- VVI: common_config 是一个 package 不能直接赋值, 否则会改变后续 lsp 的设置
  local lsp_config = vim.tbl_deep_extend('force', common_config, lsp_tool_conf)
  for fn_key, _ in pairs(cache_fns) do
    lsp_config[fn_key] = cache_fns[fn_key]
  end

  vim.lsp.config(lsp_tool, lsp_config)
end

-- 重启 lsp
--
---@param lsp_tools string[]
function M.restart_lsps(lsp_tools)
  ---@type string[]
  local tools = {}

  for _, lsp_tool in ipairs(lsp_tools) do
    if lsp_servers_map[lsp_tool] then
      M.lspconfig_setup(lsp_tool)  -- 重新配置 lsp config
      table.insert(tools, lsp_tool)
    end
  end

  -- restart lsps
  if #tools > 0 then
    vim.lsp.enable(tools, false)
    vim.lsp.enable(tools)
    vim.notify("restart lsp: " .. table.concat(tools, ", "))
  end
end

return M
