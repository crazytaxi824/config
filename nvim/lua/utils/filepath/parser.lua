---@class FilePathHighLightPos
--
-- highlight start column `vim.hl.range()`
---@field hl_start_col integer
--
-- highlight end column `vim.hl.range()`
---@field hl_end_col integer
--
-- highlight line number (start & end same line) `vim.hl.range()`
---@field hl_lnum integer


---@class FilePathProperty
--
-- uv.fs_stat.result.type
---@field type 'file'|'directory'
--
-- prefix: file://, url:// ...
---@field fp_prefix string
--
-- filepath
---@field original_fp string
--
-- absolute_filepath `vim.fs.abspath()`
---@field absolute_fp string
--
-- filepath:[lnum]
---@field lnum? integer
--
-- filepath:lum:[col]
---@field col? integer


local M = {}

---@param str string
---@return string prefix  file://, url:// ...
---@return string data  potential filepath
local function trim_brackets(str)
  local sep = '://'
  local prefix = ""
  local data = ""

  -- NOTE: 根据 RFC 3986, URI 的结构是: scheme ":" hier-part [ "?" query ] [ "#" fragment ]
  -- string 出现多个 "scheme://" 的情况下, 第二个 sheme:// 是 data
  -- scheme1://scheme2://xxx 不是一个合法的嵌套结构
  -- 第二个 scheme2:// 只是路径中的普通字符, 并没有"双层 scheme"的语义
  local idx = string.find(str, sep, 1, true)
  if idx then
    prefix = string.sub(str, 1, idx - 1)
    local rest = string.sub(str, idx + #sep)

    -- 获取 (file):// (url):// ...
    prefix = prefix:match('([%w]+)$')

    -- remove trailing { . , : / ? ! - " ' ` } ] ) > } ...
    data = rest:match('(.-)[%p%)%]%}>]*$')
  else
    -- remove heading  { { [ ( < ' " ` } ...
    -- remove trailing { . , : / ? ! - " ' ` } ] ) > } ...
    data = str:match('^["\'`%(%[%{<]*(.-)[%p%)%]%}>]*$')
  end

  return prefix, data
end


-- 从 str 中获取 filepath or dir, eg: /a/b/c:12:3
--
---@param str string
---@return FilePathProperty|nil
local function filepath_with_lnum_col(str)
  local prefix, data = trim_brackets(str)

  -- split filename:lnum:col
  -- NOTE: 这里不能使用 {trimempty=true}, 否则 highlight pos 位置计算会出错.
  local splits = vim.split(data, ':', { trimempty=false })
  if not splits[1] or splits[1] == "" then
    return
  end

  local absolute_fp = vim.fs.abspath(splits[1])
  local finfo = vim.uv.fs_stat(absolute_fp)
  if not finfo then
    return
  end

  ---@type FilePathProperty
  local fp_props = {
    fp_prefix   = prefix,
    original_fp = splits[1],
    absolute_fp = absolute_fp,
    type        = finfo.type,
  }

  -- file
  if finfo.type == 'file' then
    fp_props.lnum = tonumber(splits[2])  -- tonumber(nil) = nil
    fp_props.col = tonumber(splits[3])
    return fp_props
  elseif finfo.type == 'directory' then
    return fp_props
  end

  vim.notify(string.format("try open file: '%s', it is not a file or dir", fp_props.absolute_fp), vim.log.levels.INFO)
end


-- hl 不存在则只需要分析 absolute filepath 可用于 jump to path, 不需要分析 highlight start_col & end_col.
-- hl 存在则使用 string.find() & nvim_buf_add_highlight() 可用于 highlight.
--
---@param str string
---@return FilePathProperty|nil
M.parse_fp_current_line = function(str)
  -- 如果 trimmed 不是一个 filepath, 则返回 nil
  return filepath_with_lnum_col(str)
end

---@param ori_str string
---@param fp_props FilePathProperty
---@return integer|nil start_col
---@return integer|nil end_col
local function find_filepath_pos(ori_str, fp_props)
  local fp_lnum_col = fp_props.original_fp
  if fp_props.fp_prefix ~= '' then
    fp_lnum_col = fp_props.fp_prefix .. '://' .. fp_lnum_col
  end

  if fp_props.lnum then
    fp_lnum_col = string.format("%s:%d", fp_lnum_col, fp_props.lnum)
    if fp_props.col then
      fp_lnum_col = string.format("%s:%d", fp_lnum_col, fp_props.col)
    end
  end

  local start_col, end_col = string.find(ori_str, fp_lnum_col, 1, true)
  if not start_col then
    vim.notify(string.format("filepath parse error: ori_str: '%s' fp_lnum_col: '%s'", ori_str, fp_lnum_col), vim.log.levels.ERROR)
    return
  end

  return start_col-1, end_col
end

-- 获取所有需要 highlight 的 filepaths
---@return {bufnr: integer, pos: FilePathHighLightPos[]}|nil hl_params
M.parse_hl_current_line = function()
  local line = vim.api.nvim_get_current_line()
  if vim.trim(line) == '' then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]  -- vim.fn.line('.')

  ---@type { bufnr: integer, pos: FilePathHighLightPos[] }
  local buf_hl_pos = {
    bufnr = bufnr,
    pos = {},
  }

  -- VVI: 获取每段 string 的内容和起始位置
  for start_col, partial_str in line:gmatch('()(%S+)') do
    local fp_props = filepath_with_lnum_col(partial_str)

    if fp_props then
      -- position of the partial string
      local ps, pe = find_filepath_pos(partial_str, fp_props)
      if ps and pe then
        ---@type FilePathHighLightPos
        local hl_pos = {
          hl_lnum      = lnum -1,  -- vim.hl.range 中 lnum 是 0-indexed
          hl_start_col = start_col + ps -1,
          hl_end_col   = start_col + pe -1,
        }

        table.insert(buf_hl_pos.pos, hl_pos)
      end
    end
  end

  if #buf_hl_pos.pos > 0 then
    return buf_hl_pos
  end
end


return M
