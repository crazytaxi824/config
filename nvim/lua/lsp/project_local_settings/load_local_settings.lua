local lsp_file = ".nvim/lsp.json"
local linter_file = ".nvim/linter.json"

--- read settings.json file
--- 如果 return {} 表示 settings.json 被清除, 需要 reload lsp settings. 包含两种情况:
---   1. settings.json 被删除
---   2. settings.json 为空
--- 如果 return nil 表示 settings.json 格式错误, 则不要 reload lsp settings.
local function read_local_settings(json_file)
  local local_settings_filepaths = vim.fs.find(json_file, {
    upward = true, -- 从 pwd 向上寻找 .nvim/settings.lua 文件.
    stop = vim.env.HOME,  -- 直到 $HOME 为止.
    type = "file",
    limit = 1, -- NOTE: 只找最近的一个文件.
  })

  if #local_settings_filepaths < 1 then
    return {} -- settings.json 为空, 或被删除, 需要更新 lsp settings
  end

  local lines = vim.fn.readfile(local_settings_filepaths[1])

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
    return {} -- settings.json 为空, 或被删除, 需要更新 lsp settings
  end

  --- parse json
  local ok, result = pcall(vim.json.decode, json_content)
  if ok then
    return result
  end
end

local function parse_local_lsp_settings(settings)
  if not settings then
    return nil
  end

  local s = {}
  for key, value in pairs(settings) do
    --- split 是为了分开 lsp_name 和 setting_name, eg: ["pyright:python"] = {...}
    --- eg: pyright 是 lsp tool name, python 是需要放在 settings{} 中的 name
    local r = vim.split(key, ':', {trimempty=true})
    if #r == 1 then
      s[key] = {[key] = settings[key]}
    elseif #r == 2 then
      s[r[1]] = {[r[2]] = settings[key]}
    else
      error("project local 'settings.json' format error")
      return {}
    end
  end
  return s
end

local M = {}

M.get_local_lsp_settings = function()
  local sf = read_local_settings(lsp_file)
  if not sf then
    error("project local '" .. lsp_file .. "' format error")
    return {}
  end
  return parse_local_lsp_settings(sf)
end

M.get_local_linter_settings = function()
  local sf = read_local_settings(linter_file)
  if not sf then
    error("project local '" .. linter_file .. "' format error")
    return {}
  end
  return sf
end

return M
