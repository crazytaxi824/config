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

--- 加载 autocmd
require("lsp.project_local_settings.auto_restart_tools")

---read json file
---
---如果 return vim.empty_dict() 需要 reload lsp settings. 包含以下几种情况:
---  1. json 文件被删除
---  2. json 文件为空
---  3. json 文件为 {}
---如果 return nil 表示 json 格式错误, 则不要 reload lsp settings.
---
---@param json_file string (file path)
---@return table|nil
local function read_local_settings(json_file)
  local local_settings_filepath = utils.find_local_settings_file(json_file)

  if not local_settings_filepath then
    return vim.empty_dict() -- json 为空, 或被删除, 需要 reload lsp settings
  end

  local lines = vim.fn.readfile(local_settings_filepath)

  --- 移除 jsonc 中的 comments, 全部转成 ""
  local strip_lines = {}

  --- 逐行处理单行注释 //...
  for _, line in ipairs(lines) do
    line = vim.trim(line)
    -- 匹配 //，但前提是它不在引号内（简单启发式判断）
    -- 寻找第一个 //，且它之前没有奇数个引号
    local code_part = line:match("^(.-)//")
    if code_part then
        -- 检查引号数量，如果是偶数，说明 // 在字符串外
        local _, quote_count = code_part:gsub('"', "")
        if quote_count % 2 == 0 then
            line = code_part
        end
    end
    table.insert(strip_lines, line)
  end

  --- 移除多行注释 /* ... */
  --- 使用 [-1][^1] 技巧在 Lua 中匹配包含换行符的所有字符
  local json_content = vim.trim(table.concat(strip_lines, ""):gsub("/%*.-%*/", ""))
  if json_content == "" then
    return vim.empty_dict() -- json 为空, 或被删除, 需要 reload lsp settings
  end

  --- parse json
  local ok, result = pcall(vim.json.decode, json_content)
  if ok then
    return result -- json 不为空, 需要 reload lsp settings
  end
  return nil -- json 格式错误, 不需要 reload lsp settings
end

---解析 lsp settings
---
---{ pyright:python = { ... } } 转成 { pyright = python = { ... } }
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

---获取本地 lsp 设置
function M.get_local_lsp_settings()
  local sf = read_local_settings(utils.lsp_file)
  if not sf then
    error("project local '" .. utils.lsp_file .. "' format error")
    return nil
  end
  return parse_local_lsp_settings(sf)
end

---获取本地 none-ls linter 设置
function M.get_local_linter_settings()
  local sf = read_local_settings(utils.linter_file)
  if not sf then
    error("project local '" .. utils.linter_file .. "' format error")
    return nil
  end
  return sf
end

return M
