--- 缓存 dofile 读取到的 project local settings 数据. 用于 lspconfig && null-ls 使用.
--- 主要函数是 keep_extend('local_setting_name', {overwrite_settings_tbl})
--- VVI: dofile() vs require():
--    dofile()  - loads and executes a file every time being called.
--    require() - is more complicated; it keeps a table of modules
--                that have already been loaded and their return results,
--                to ensure that the same code isn't loaded twice.

--- 全局变量
local M = {}

local function parse_local_settings(s)
  if not s or not s.lsp then
    return s
  end

  for key, value in pairs(s.lsp) do
    local r = vim.split(key, ':', {trimempty=true})
    if #r == 1 then
      s.lsp[key] = {[key] = s.lsp[key]}
    elseif #r == 2 then
      s.lsp[r[1]] = {[r[2]] = s.lsp[key]}
      s.lsp[key] = nil
    else
      error('project local settings format error')
    end
  end
  return s
end

--- 返回2种情况:
---  1 - return {}    没有 local_settings, 或 local_settings 被删除 需要更新配置;
---  2 - return nil   local_settings 语法错误, 保持之前的配置;
local function get_local_settings_content()
  local local_settings_filepaths = vim.fs.find({'.nvim/settings.lua'}, {
    upward = true, -- 从 pwd 向上寻找 .nvim/settings.lua 文件.
    stop = vim.fn.getenv('HOME'),  -- 直到 $HOME 为止.
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),  -- 从当前文件所在目录开始查找.
    limit = 1, -- NOTE: 只找最近的一个文件.
  })

  if #local_settings_filepaths < 1 then
    return {}  -- 没有 local_settings, 或 local_settings 被删除, 需要更新配置
  end

  --- VVI: 直接获取 content, 该段代码只会在第一次 require() 的时候运行一次, 以后再次 require() 的时候不会多次运行.
  local ok, result = pcall(dofile, local_settings_filepaths[1])
  --- ok 文件执行 (dofile) 成功.
  --- result 是执行结果. 可能为 nil, 可能是执行失败的 error message.
  if not ok then
    error(vim.inspect(result)) -- local_settings 语法错误, 保持之前的配置
  end

  return parse_local_settings(result) or {}  -- local_settings 读取成功, result 可能为 nil. 这里需要更新配置.
end

--- 第一次获取 local_settings, 忽略 dofile 错误.
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
local function compare_content_settings(old_content, new_content, typ, callback)
  if not old_content[typ] and new_content[typ] then
    for tool, _ in pairs(new_content[typ]) do
      callback(tool)
    end
  elseif old_content[typ] and not new_content[typ] then
    for tool, _ in pairs(old_content[typ]) do
      callback(tool)
    end
  elseif old_content[typ] and new_content[typ] then
    local tool = deep_compare(old_content[typ], new_content[typ])
    if tool then
      callback(tool)
    end
  end
end

--- 如果找到不同的设置则重新加载 lsp/null-ls
local function reload_local_settings(old_content, new_content)
  local update_settings = {} -- cache tool name, 用于 notify.

  --- lsp = { gopls = { ... }, tsserver = { ... } }
  local lsp_typ = require("lsp.plugins.lsp_config.setup_opts").local_lspconfig_key
  local default_opts = require("lsp.plugins.lsp_config.setup_opts").default_config
  compare_content_settings(old_content, new_content, lsp_typ, function(lsp_name)
    local c = vim.lsp.get_clients({name = lsp_name})[1]
    if new_content[lsp_typ] and new_content[lsp_typ][lsp_name] then
      --- local settings 新添加或者改动的情况
      for key, value in pairs(new_content[lsp_typ][lsp_name]) do
        c.config.settings[key] = vim.tbl_deep_extend('force', default_opts[lsp_name][key], value)
      end
    else
      --- local settings 被删除的情况
      if default_opts[lsp_name] then
        for key, value in pairs(default_opts[lsp_name]) do
          c.config.settings[key] = value
        end
      end
    end

    --- NOTE: 暴力方案, `:LspRestart` 重启所有 lspconfig.setup() 的 lsp, null-ls 不是由 lspconfig.setup
    -- vim.cmd('LspRestart')
    c.notify("workspace/didChangeConfiguration", { settings = c.config.settings })

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

  --- 重新加载 local settings.
  reload_local_settings(old_content, M.content)
end, { bang=true, bar=true, desc = 'reload "lsp" and "null-ls" after change ".nvim/settings.lua"' })

--- command 显示 project local settings 示例.
vim.api.nvim_create_user_command("LocalSettingsExample", function()
  --- NOTE: 主要保证 key 设置正确.
  local lsp_typ = require("lsp.plugins.lsp_config.setup_opts").local_lspconfig_key
  local s = require("lsp.plugins.null_ls.sources")

  local example = {
    [lsp_typ] = { gopls = { "..." }, tsserver = { "..." } },
    [s.local_linter_key] = {
      golangci_lint = { extra_args = {'-c', '/path/to/.golangci.yml'} },
    },
  }

  vim.notify('".nvim/settings.lua" example:\n```lua\nreturn ' .. vim.inspect(example) .. '\n```', vim.log.levels.INFO)
end, { bang=true, bar=true, desc = '".nvim/settings.lua" example.' })

return M
