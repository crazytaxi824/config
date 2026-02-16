--- 缓存 dofile 读取到的 project local settings 数据. 用于 lspconfig && null-ls 使用.
--- 主要函数是 keep_extend('local_setting_name', {overwrite_settings_tbl})
--- VVI: dofile() vs require():
--    dofile()  - loads and executes a file every time being called.
--    require() - is more complicated; it keeps a table of modules
--                that have already been loaded and their return results,
--                to ensure that the same code isn't loaded twice.
local lsp_key = require("lsp.plugins.lsp_config.setup_opts").local_lspconfig_key

--- 全局变量
local M = {}

local function parse_local_settings(s)
  if not s or not s[lsp_key] then
    return s  -- 如果 s={} 则返回 s, 如果 s=nil 则返回 nil
  end

  for key, value in pairs(s[lsp_key]) do
    --- split 是为了分开 lsp_name 和 setting_name, eg: ["pyright:python"] = {...}
    local r = vim.split(key, ':', {trimempty=true})
    if #r == 1 then
      s[lsp_key][key] = {[key] = s[lsp_key][key]}
    elseif #r == 2 then
      s[lsp_key][r[1]] = {[r[2]] = s[lsp_key][key]}
      s[lsp_key][key] = nil
    else
      error("project local 'settings.json' format error")
      return {}
    end
  end
  return s
end

--- parse settings.json 文件
--- 如果 return {} 表示 settings.json 被清除, 需要更新 lsp settings. 包含两种情况:
---   1. settings.json 被删除
---   2. settings.json 为空
--- 如果 return nil 表示 settings.json 格式错误, 则不要更新 lsp settings.
local function read_local_settings()
  local local_settings_filepaths = vim.fs.find({'.nvim/settings.json'}, {
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

local function get_local_settings_content()
  local r = read_local_settings()
  if not r then
    error("project local 'settings.json' format error")
    return {}
  end
  return parse_local_settings(r)
end

M.content = get_local_settings_content()

--- extend project local settings if '.nvim/settings.lua' exists -----------------------------------
--- NOTE: 主要函数 keep_extend() 用 project local 设置覆盖 global 设置.
--- 使用 tbl_deep_extend('keep', xx, xx, ...)
M.tools_keep_extend = function(section, tool, tbl, ...)
  --- 如果项目本地设置存在.
  if M.content[section] and M.content[section][tool] then
    if not tbl then
      return M.content[section][tool]
    end

    return vim.tbl_deep_extend('keep', M.content[section][tool], tbl, ...)
  end

  --- 如果传入多个 tbl config
  if ... then
    return vim.tbl_deep_extend('keep', tbl, ...)
  end

  --- 如果只有一个 tbl config
  return tbl
end

--- deep compare 2 tables
local function deep_compare(t1, t2)
  if t1 == t2 then return end

  if type(t1) ~= "table" or type(t2) ~= "table" then
    return true
  end

  for k, v in pairs(t1) do
    if deep_compare(v, t2[k]) then
      return k
    end
  end

  for k, v in pairs(t2) do
    if deep_compare(t1[k], v) then
      return k
    end
  end
end

--- set command for Reload local project settings --------------------------------------------------
--- compare content, 如果内容不同则执行 callback.
local function compare_content_settings(old_content, new_content, tool_typ, callback)
  if not old_content[tool_typ] and new_content[tool_typ] then
    for tool, _ in pairs(new_content[tool_typ]) do
      callback(tool)
    end
  elseif old_content[tool_typ] and not new_content[tool_typ] then
    for tool, _ in pairs(old_content[tool_typ]) do
      callback(tool)
    end
  elseif old_content[tool_typ] and new_content[tool_typ] then
    local tool = deep_compare(old_content[tool_typ], new_content[tool_typ])
    if tool then
      callback(tool)
    end
  end
end

--- 如果找到不同的设置则重新加载 lsp/null-ls
local function reload_local_settings(old_content, new_content)
  local update_settings = {} -- cache tool name, 用于 notify.

  --- lsp = { gopls = { ... }, tsserver = { ... } }
  compare_content_settings(old_content, new_content, lsp_key, function(lsp_name)
    local c = vim.lsp.get_clients({name = lsp_name})[1]
    if not c then
      return
    end

    if new_content[lsp_key] and new_content[lsp_key][lsp_name] then
      --- local settings 新添加或者改动的情况, 更新 settings
      c.config.settings = vim.tbl_deep_extend('force', c.config.settings or {}, new_content[lsp_key][lsp_name])
    else
      --- local settings 被删除的情况, 重新设置 settings 为初始设置
      --- lsp init settings could be: nil | {} | {lsp={...}}
      local lsp_init_cfg = vim.lsp.config[lsp_name].settings or {}
      c.config.settings = lsp_init_cfg
    end

    --- NOTE: 暴力方案, `:LspRestart` 重启所有 lspconfig.setup() 的 lsp, null-ls 不是由 lspconfig.setup
    -- vim.cmd('LspRestart ' .. lsp_name )
    vim.lsp.enable(lsp_name, false)
    vim.lsp.enable(lsp_name, true)
    --- NOTE: client:notify() is NOT WORKING if client.config.settings <Object> 被整个替换, 除非逐一给 settings 中的属性赋值
    -- local ms = vim.lsp.protocol.Methods
    -- c:notify(ms.workspace_didChangeConfiguration, { settings = c.config.settings })

    --- cache tool name, 用于 notify.
    table.insert(update_settings, lsp_name)
  end)

  --- linter = { golangci_lint = { ... }, eslint = { ... } }
  local s = require("lsp.plugins.null_ls.sources")
  compare_content_settings(old_content, new_content, s.local_linter_key, function(tool_name)
    local null_ls_status_ok, null_ls = pcall(require, "null-ls")
    if not null_ls_status_ok then
      Notify("`null-ls` is not loaded.", "INFO")
      return
    end

    --- 注销原设置, 注册新设置, 相当于关闭之前的服务, 然后开了一个新的服务.
    null_ls.disable(tool_name)  -- 清除 diagnostic messages & signs
    null_ls.deregister(tool_name)  -- 注销, 删除原服务.
    null_ls.register(s.sources[s.local_linter_key][tool_name]())  -- 重新注册. register 后, 自动 enable.

    --- cache tool name, 用于 notify.
    table.insert(update_settings, tool_name)
  end)

  if #update_settings > 0 then
    vim.notify('local settings changed: ' .. table.concat(update_settings, ' | '), vim.log.levels.INFO)
  end
end

--- command 手动重新加载 local settings
vim.api.nvim_create_user_command("LocalSettingsReload", function()
  --- lua 中 table 是 deep copy
  local old_content = M.content

  local new_content = get_local_settings_content()
  if not new_content then
    return  -- dofile error
  end

  --- 更新 local_settings
  M.content = new_content

  --- 重新加载 local settings
  reload_local_settings(old_content, M.content)
end, { bang=true, bar=true, desc = 'reload "lsp" and "null-ls" after change ".nvim/settings.lua"' })

--- command 显示 project local settings 示例.
vim.api.nvim_create_user_command("LocalSettingsExample", function()
  --- NOTE: 主要保证 key 设置正确.
  local linter_sources = require("lsp.plugins.null_ls.sources")

  local example = {
    [lsp_key] = {
      gopls = { "..." },
      -- sqls = {
      --   connections = {
      --     {
      --       driver = 'mysql',
      --       dataSourceName = 'root:root@tcp(127.0.0.1:13306)/world',
      --     },
      --     {
      --       driver = 'postgresql',
      --       dataSourceName = 'host=127.0.0.1 port=15432 user=postgres password=mysecretpassword1234 dbname=dvdrental sslmode=disable',
      --     },
      --   },
      -- },
      ["lua_ls:Lua"] = { "..." },
      ["pyright:python"] = { "..." },
    },
    [linter_sources.local_linter_key] = {
      golangci_lint = { extra_args = {'-c', '/path/to/.golangci.yml'} },
    },
  }

  vim.notify('".nvim/settings.lua" example:\n```lua\nreturn ' .. vim.inspect(example) .. '\n```', vim.log.levels.INFO)
end, { bang=true, bar=true, desc = '".nvim/settings.lua" example.' })

return M
