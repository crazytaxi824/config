--- 缓存 dofile 读取到的 project local settings 数据. 用于 lspconfig && null-ls 使用.
--- 主要函数是 keep_extend('local_setting_name', {overwrite_settings_tbl})
--- VVI: dofile() vs require():
--    dofile()  - loads and executes a file every time being called.
--    require() - is more complicated; it keeps a table of modules
--                that have already been loaded and their return results,
--                to ensure that the same code isn't loaded twice.

--- 全局变量
local M = {}

--- 从 pwd 向上获取 dir 直到 root "/".
local function local_settings_dir_filepaths_to_root()
  local absolute_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':p')
  local path_slice = vim.split(absolute_dir, '/')

  local t = {}
  for i = #path_slice-1, 1, -1 do
    table.insert(t, table.concat(path_slice, '/'))
    table.remove(path_slice, i)
  end

  return t
end

--- 从 pwd 向上寻找 .nvim/settings.lua 文件.
local function available_local_settings_file()
  local dirs = local_settings_dir_filepaths_to_root()
  for _, dir in ipairs(dirs) do
    local local_settings_filepath = dir .. '.nvim/settings.lua'
    if vim.fn.filereadable(local_settings_filepath) == 1 then
      return local_settings_filepath
    end
  end
end

M.get_local_settings_content = function()
  local local_settings_filepath = available_local_settings_file()
  if local_settings_filepath then
    --- 使用 pcall 确保 lua file 执行没有错误.
    local ok, result = pcall(dofile, local_settings_filepath)
    --- ok 文件执行 (dofile) 成功.
    --- result 是执行结果. 可能为 nil, 可能是执行失败的 error message.
    if ok then
      if result then
        --- '.nvim/settings.lua' 读取成功, 同时返回值不是 nil 的情况下缓存 settings 数据.
        return result
      else
        Notify('"' .. local_settings_filepath .. '" returns nil.', "INFO")
      end
    else
      Notify(vim.split(result, '\n', {trimempty=true}), "WARN")
    end
  end
end

--- 缓存 file 内容.
--- VVI: 直接获取 content, 该段代码只会在第一次 require() 的时候运行一次, 以后再次 require() 的时候不会多次运行.
--- VVI: 这里不要使用 nil, 因为 nil 无法 index [lsp] / [null-ls].
local content = M.get_local_settings_content() or {}

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

return M
