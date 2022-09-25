--- 缓存 dofile 读取到的 project local settings 数据. 用于 lspconfig && null-ls 使用.
--- 主要函数是 keep_extend('local_setting_name', {overwrite_settings_tbl})
--- VVI: dofile() vs require():
--    dofile()  - loads and executes a file every time being called.
--    require() - is more complicated; it keeps a table of modules
--                that have already been loaded and their return results,
--                to ensure that the same code isn't loaded twice.

--- 全局变量
local M = {
  _once = nil,   -- 是否已经读取过 file. true - 已经读取过, false|nil - 未读取 file.
  _content = {}  -- 缓存 file 内容. VVI: 这里不要使用 nil, 因为 nil 无法 index [lsp] / [null-ls].
}

--- 内部函数 lazyload() 保证只读取一次文件.
M._lazyload = function()
  --- 如果已经读取文件则不重复执行.
  if M._once then
    -- print('project local settings are already loaded (once)')
    return
  else
    -- print('load project local settings')
  end

  --- 第一次读取文件, NOTE: 使用 dofile 方法执行指定 lua 文件.
  --- 如果文件不存在, 或执行错误(语法错误), 则忽略.
  local ok, proj_settings = pcall(dofile, '.nvim/settings.lua')
  if ok and proj_settings then
    --- '.nvim/settings.lua' 读取成功, 同时返回值不是 nil 的情况下赋值给 _content
    M._content = proj_settings  -- 缓存数据.
  end

  M._once = true  -- 标记为已读.
end

--- 如果项目本地设置存在
M.exists = function(section, tool)
  M._lazyload()  -- VVI: 读取项目配置文件

  if M._content[section] and M._content[section][tool] then
    return true
  end

  return false
end

--- project local setting 存在的情况下 extend settings. VVI: 一定要配合 exists() 使用.
M.exists_keep_extend = function(section, tool, tbl, ...)
  --- M._lazyload()  -- VVI: exists() 中已经 lazyload()

  --- tbl_deep_extend() 会自动处理 ... 是否为 nil 的情况.
  return vim.tbl_deep_extend('keep', M._content[section][tool], tbl, ...)
end

--- NOTE: 主要函数 keep_extend() 用 project local 设置覆盖 global 设置.
--- 使用 tbl_deep_extend('keep', xx, xx, ...)
M.keep_extend = function(section, tool, tbl, ...)
  --- M._lazyload()  -- VVI: exists() 中已经 lazyload()

  --- 如果项目本地设置存在
  if M.exists(section, tool) then
    return M.exists_keep_extend(section, tool, tbl, ...)
  end

  --- 如果传入多个 tbl config
  if ... then
    return vim.tbl_deep_extend('keep', tbl, ...)
  end

  --- 如果只有一个 tbl config
  return tbl
end

return M
