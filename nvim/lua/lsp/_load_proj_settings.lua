--- 缓存 dofile 读取到的 project local settings 数据. 用于 lspconfig && null-ls 使用.
--- 主要函数是 keep_extend('local_setting_name', {overwrite_settings_tbl})
--- VVI: dofile() vs require():
--    dofile()  - loads and executes a file every time being called.
--    require() - is more complicated; it keeps a table of modules
--                that have already been loaded and their return results,
--                to ensure that the same code isn't loaded twice.

--- 全局变量
local M = {}

--- 从 pwd 向上寻找 .nvim/settings.lua 文件.
local function available_local_settings_file()
  --- 从 pwd 向上获取 dir 直到 root "/".
  for dir in vim.fs.parents(vim.api.nvim_buf_get_name(0)) do
    local local_settings_filepath
    if string.sub(dir, #dir)  == '/' then
      local_settings_filepath = dir .. '.nvim/settings.lua'
    else
      local_settings_filepath = dir .. '/.nvim/settings.lua'
    end
    if vim.fn.filereadable(local_settings_filepath) == 1 then
      return local_settings_filepath
    end
  end
end

local function get_local_settings_content()
  local local_settings_filepath = available_local_settings_file()
  if local_settings_filepath then
    --- 使用 pcall 确保 lua file 执行没有错误.
    local ok, result = pcall(dofile, local_settings_filepath)
    --- ok 文件执行 (dofile) 成功.
    --- result 是执行结果. 可能为 nil, 可能是执行失败的 error message.
    if not ok then
      Notify(vim.trim(result), "ERROR")
      return nil, "dofile_error"
    elseif result then
      --- '.nvim/settings.lua' 读取成功, 同时返回值不是 nil 的情况下缓存 settings 数据.
      return result
    end
  end
end

--- 缓存 file 内容.
--- VVI: 直接获取 content, 该段代码只会在第一次 require() 的时候运行一次, 以后再次 require() 的时候不会多次运行.
--- VVI: 这里不要使用 nil, 因为 nil 无法 index [lsp] / [null-ls].
local content = get_local_settings_content() or {}

--- extend project local settings if '.nvim/settings.lua' exists -----------------------------------
--- NOTE: 主要函数 keep_extend() 用 project local 设置覆盖 global 设置.
--- 使用 tbl_deep_extend('keep', xx, xx, ...)
M.keep_extend = function(section, tool, tbl, ...)
  --- 如果项目本地设置存在.
  if content[section] and content[section][tool] then
    return vim.tbl_deep_extend('keep', content[section][tool], tbl, ...)
  end

  --- 如果传入多个 tbl config
  if ... then
    return vim.tbl_deep_extend('keep', tbl, ...)
  end

  --- 如果只有一个 tbl config
  return tbl
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
    for tool, cfg in pairs(old_content[typ]) do
      if not new_content[typ][tool] or vim.fn.json_encode(cfg) ~= vim.fn.json_encode(new_content[typ][tool]) then
        callback(tool)
      end
    end

    --- NOTE: 这里不用再对比 json_encode(), 避免重复对比.
    for tool, _ in pairs(new_content[typ]) do
      if not old_content[typ][tool] then
        callback(tool)
      end
    end
  end
end

--- 如果找到不同的设置则重新加载 lsp/null-ls
local function reload_local_settings(old_content, new_content)
  local update_settings = {} -- cache tool name, 用于 notify.

  --- lsp = { gopls = { ... }, tsserver = { ... } }
  local lsp_typ = require("lsp.lsp_config.setup_opts").local_lspconfig_key
  compare_content_settings(old_content, new_content, lsp_typ, function(lsp_name)
    local clients = vim.lsp.get_active_clients({name = lsp_name})
    for _, c in ipairs(clients) do
      if new_content.lsp and new_content.lsp[lsp_name] then
        c.config.settings[lsp_name] = new_content.lsp[lsp_name]  -- 直接替换设置
      else
        c.config.settings[lsp_name] = nil
      end

      c.notify("workspace/didChangeConfiguration", { settings = c.config.settings })
    end

    table.insert(update_settings, lsp_name)
  end)

  --- linter = { golangci_lint = { ... }, eslint = { ... } }
  --- formatter = { prettier = { ... }, goimports = { ... } }
  --- code_actions = { eslint = { ... } }
  local s = require("lsp.null_ls.sources")
  local null_ls_tool_types = {s.local_linter_key, s.local_formatter_key, s.local_code_actions_key}
  for _, typ in ipairs(null_ls_tool_types) do
    compare_content_settings(old_content, new_content, typ, function(tool_name)
      local null_ls_status_ok, null_ls = pcall(require, "null-ls")
      if not null_ls_status_ok then
        Notify("`null-ls` is not loaded.", "INFO")
        return
      end

      --- 注销原设置, 注册新设置, 相当于关闭之前的服务, 然后开了一个新的服务.
      null_ls.disable(tool_name)  -- 清除 diagnostic messages & signs
      null_ls.deregister(tool_name)  -- 注销, 删除原服务.
      null_ls.register(s.sources[typ][tool_name]())  -- 重新注册. register 后, 自动 enable.

      table.insert(update_settings, tool_name)
    end)
  end

  if #update_settings > 0 then
    vim.notify('local settings changed: ' .. table.concat(update_settings, ' | '), vim.log.levels.INFO)
  end
end

--- command 手动重新加载 local settings
vim.api.nvim_create_user_command("LocalSettingsReload", function()
  --- lua 中 table 是 deep copy
  local old_content = content

  --- VVI: 给 content 重新赋值
  local new_content, err = get_local_settings_content()
  if err then  -- dofile error
    return
  end

  content = new_content or {}

  --- 重新加载 local settings.
  reload_local_settings(old_content, content)
end, { bang=true, bar=true, desc = 'reload "lsp" and "null-ls" after change ".nvim/settings.lua"' })

--- command 显示 project local settings 示例.
vim.api.nvim_create_user_command("LocalSettingsExample", function()
  --- NOTE: 主要保证 key 设置正确.
  local lsp_typ = require("lsp.lsp_config.setup_opts").local_lspconfig_key
  local s = require("lsp.null_ls.sources")

  local example = {
    [lsp_typ] = { gopls = { "..." }, tsserver = { "..." } },
    [s.local_linter_key] = {
      golangci_lint = { extra_args = {'-c', '/path/to/.golangci.yml'} },
      eslint = { extra_args = {'-c', '/path/to/.eslintrc.json'} }
    },
    [s.local_formatter_key] = { prettier = { "..." }, goimports = { "..." } },
    [s.local_code_actions_key] = { eslint = { "..." } },
  }

  vim.notify('".nvim/settings.lua" example:\n```lua\nreturn ' .. vim.inspect(example) .. '\n```', vim.log.levels.INFO)
end, { bang=true, bar=true, desc = '".nvim/settings.lua" example.' })

return M
