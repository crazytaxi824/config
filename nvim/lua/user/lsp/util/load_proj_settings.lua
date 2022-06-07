--- 缓存 dofile 读取到的 project local settings 数据. 用于 lspconfig && null-ls 使用.
--- 主要函数是 keep_extend('local_setting_name', {overwrite_settings_tbl})

--- 全局变量
__Proj_local_settings = {
  _once = nil,   -- 是否已经读取过 file. true - 已经读取过, false|nil - 未读取 file.
  _content = {}  -- 缓存 file 内容. VVI: 这里不要使用 nil, 因为 nil 无法 index [lsp] / [null-ls].
}

--- 内部函数 lazyload() 保证只读取一次文件.
__Proj_local_settings._lazyload = function()
  --- 如果已经读取文件则不重复执行.
  if __Proj_local_settings._once then
    return
  end

  --- 第一次读取文件
  local ok, proj_settings = pcall(dofile, '.nvim/settings.lua')
  __Proj_local_settings._once = true  -- NOTE: 标记为已读.

  -- '.nvim/settings.lua' 读取成功, 同时返回值不是 nil 的情况下赋值给 _content
  if ok and proj_settings then
    __Proj_local_settings._content = proj_settings  -- NOTE: 缓存数据.
  end
end

--- VVI: 主要函数 keep_extend() 用 project 设置覆盖 global 设置.
--- 使用 tbl_deep_extend('keep', xx, xx, ...)
__Proj_local_settings.keep_extend = function(section, tool, tbl, ...)
  __Proj_local_settings._lazyload()  -- 读取项目配置文件

  -- 如果项目本地设置存在
  if __Proj_local_settings._content[section] and __Proj_local_settings._content[section][tool] then
    return vim.tbl_deep_extend('keep', __Proj_local_settings._content[section][tool], tbl, ...)
  end

  -- 如果传入多个 tbl config
  if ... then
    return vim.tbl_deep_extend('keep', tbl, ...)
  end

  -- 如果只有一个 tbl config
  return tbl
end
