--- DOCS: lsp.json linter.json 配置 ---------------------------------------------------------------- {{{
--- .nvim/lsp.json
-- {
--   "gopls": {
--     "semanticTokens": true,
--     "usePlaceholders": false,
--     "buildFlags": ["-tags=!prod"]
--   },
--   "pyright:python": {
--     "analysis": {
--       "autoSearchPaths": false,
--       "diagnosticMode": "openFilesOnly",
--       "useLibraryCodeForTypes": true
--     }
--   },
--   "lua_ls:Lua": {
--     "codeLens": {
--       "enable": true
--     }
--   }
-- }

--- .nvim/linter.json
-- {
--   "golangci_lint": {
--     "extra_args": ["-c", "./.golangci.yml"]
--   }
-- }
-- }}}

local utils = require("lsp.project_local_settings.utils")

--- read json file
---
--- 如果 return vim.empty_dict() 需要 tbl_deep_extend to default settings. 包含以下几种情况:
---   1. json 文件不存在
---   2. json 文件为空 ""
--- 如果 return nil 表示 json 格式错误, 则不要 tbl_deep_extend to default settings.
---
---@param json_file string  -- (file path)
---@return table|nil
local function read_local_settings(json_file)
  local local_settings_filepath = utils.find_local_settings_file(json_file)

  if not local_settings_filepath then
    return vim.empty_dict() -- file 不存在, 当作 {}, 需要 tbl_deep_extend to default settings
  end

  local lines = vim.fn.readfile(local_settings_filepath)
  local json_content = table.concat(lines, "\n")

  if vim.trim(json_content) == "" then
    return vim.empty_dict() -- file 为空, 当作 {}, 需要 tbl_deep_extend to default settings
  end

  local ok, result = pcall(vim.json.decode, json_content, { skip_comments = true })
  if ok then
    return result -- json 不为空, 需要 tbl_deep_extend to default settings
  end
  return nil -- json 格式错误, 不需要 tbl_deep_extend
end

--- 解析 lsp settings
---
--- { pyright:python = { ... } } 转成 { pyright = python = { ... } }
---
---@param settings table
---@return table|nil
local function parse_local_lsp_settings(settings)
  if vim.tbl_isempty(settings) then
    return vim.empty_dict() -- json 为空, 或被删除, 需要 reload lsp settings
  end

  local s = {}
  for key, value in pairs(settings) do
    --- split 是为了分开 lsp_name 和 setting_name, eg: ["pyright:python"] = {...}
    --- eg: pyright 是 lsp tool name, python 是需要放在 settings{} 中的 name
    local r = vim.split(key, ':', {trimempty=true})
    if #r == 1 then
      s = vim.tbl_deep_extend('force', s, {[key] = {[key] = value}})
    elseif #r == 2 then
      s = vim.tbl_deep_extend('force', s, {[r[1]] = {[r[2]] = value}})
    else
      error("project local '" .. utils.lsp_file .. "' format error")
      return nil
    end
  end
  return s
end

local M = {}

--- 获取本地 lsp 设置
function M.get_local_lsp_settings()
  local sf = read_local_settings(utils.lsp_file)
  if not sf then
    Notify({"`" .. utils.lsp_file .. "` format error"}, vim.log.levels.ERROR, { title = "project_local_settings" })
    return nil
  end
  return parse_local_lsp_settings(sf)
end

--- 获取本地 none-ls linter 设置
function M.get_local_linter_settings()
  local sf = read_local_settings(utils.linter_file)
  if not sf then
    Notify({"`" .. utils.linter_file .. "` format error"}, vim.log.levels.ERROR, { title = "project_local_settings" })
    return nil
  end
  return sf
end

return M
