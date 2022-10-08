--- 缓存 dofile 读取到的 project local settings 数据. 用于 lspconfig && null-ls 使用.
--- 主要函数是 keep_extend('local_setting_name', {overwrite_settings_tbl})
--- VVI: dofile() vs require():
--    dofile()  - loads and executes a file every time being called.
--    require() - is more complicated; it keeps a table of modules
--                that have already been loaded and their return results,
--                to ensure that the same code isn't loaded twice.

--- 全局变量
local M = {}

local once = nil    -- 是否已经读取过 file. true - 已经读取过, false|nil - 未读取 file.
local content = {}  -- 缓存 file 内容. VVI: 这里不要使用 nil, 因为 nil 无法 index [lsp] / [null-ls].

--- 内部函数 lazyload() 保证只读取一次文件.
local function lazyload_local_settings()
  --- 如果已经读取文件则不重复执行.
  if once then
    -- print('project local settings are already loaded (once)')
    return
  end
  -- print('load project local settings')

  --- 第一次读取文件, NOTE: 使用 dofile 方法执行指定 lua 文件.
  --- 如果文件不存在, 或执行错误(语法错误), 则忽略.
  local ok, local_settings = pcall(dofile, '.nvim/settings.lua')
  if ok and local_settings then
    --- '.nvim/settings.lua' 读取成功, 同时返回值不是 nil 的情况下缓存数据
    content = local_settings  -- 缓存数据.
  end

  once = true  -- 标记为已读.
end

--- NOTE: 主要函数 keep_extend() 用 project local 设置覆盖 global 设置.
--- 使用 tbl_deep_extend('keep', xx, xx, ...)
M.keep_extend = function(section, tool, tbl, ...)
  lazyload_local_settings()

  --- 如果项目本地设置存在.
  if content[section] and content[section][tool] then
    --- VVI: 这里第二个出参返回 'true' 表明 local setting 加载成功.
    --- 这里只能放在第二个出参上, 否则会影响本函数在 null-ls 中的使用.
    return vim.tbl_deep_extend('keep', content[section][tool], tbl, ...), true
  end

  --- 如果传入多个 tbl config
  if ... then
    return vim.tbl_deep_extend('keep', tbl, ...)
  end

  --- 如果只有一个 tbl config
  return tbl
end

return M
