---@class HighLightPos
--
-- uv.fs_stat.result.type
---@field type 'file'|'directory'
--
-- filepath
---@field original_fp string
--
-- absolute_filepath `vim.fs.abspath()`
---@field absolute_fp string
--
-- highlight start column `vim.hl.range()`
---@field hl_start_col integer
--
-- highlight end column `vim.hl.range()`
---@field hl_end_col integer
--
-- highlight line number (start & end same line) `vim.hl.range()`
---@field hl_lnum integer


local M = {}

-- index elem of a list
--
---@param list string[]
---@param v string
---@return integer|nil
local function index_of(list, v)
  for index, value in ipairs(list) do
    if value == v then
      return index
    end
  end
end

-- clear { '`', '"', "'", '(', '[', '{', '<'}
--
---@param str string
---@return string
local function clear_brackets(str)
  local start_brackets = { '`', '"', "'", '(', '[', '{', '<'}
  local end_brackets   = { '`', '"', "'", ')', ']', '}', '>'}

  local b_index = index_of(start_brackets, string.sub(str,1,1))
  if b_index and string.sub(str,-1,-1) == end_brackets[b_index] then
    str = string.sub(str, 2, -2)
  end

  return str
end

-- 去掉所有常用符号
--
---@param str string
---@return string
local function normalize_str(str)
  str = str:match('(.-)[,;!?]*$') or str  -- 去掉结尾的 , ; ! ? 符号
  str = clear_brackets(str)  -- 去掉第外层 () [] <> {} ...
  str = str:match('[%w_]+://(.*)') or str  -- 去掉 file://(...)
  str = clear_brackets(str)  -- 去掉第内层 () [] <> {} ...
  return str
end

-- 从 str 中获取 filepath or dir, eg: /a/b/c:12:3
--
---@param str string
---@return table|nil
local function filepath_with_lnum_col(str)
  -- str:gsub(str, '%z', '󰟢')  -- lua 中 %z 表示 Null(\0)

  -- split filename:lnum:col
  local splits = vim.split(str, ':', { trimempty=false })
  if not splits[1] then
    return
  end

  local absolute_fp = vim.fs.abspath(splits[1])
  local finfo = vim.uv.fs_stat(absolute_fp)
  if not finfo then
    return
  end

  local r = {
    original_fp = splits[1],
    absolute_fp = absolute_fp,
    type        = finfo.type,
  }

  -- file
  if finfo.type == 'file' then
    r.lnum = tonumber(splits[2])  -- tonumber(nil) = nil
    r.col = tonumber(splits[3])
    return r
  elseif finfo.type == 'directory' then
    return r
  end

  vim.notify(string.format("try open file: '%s', it is not a file or dir", r.absolute_fp), vim.log.levels.INFO)
end

-- 分析 filepath
--
---@param str string
---@param need_hl string|boolean|nil (标记: 是否计算 highlight lnum, start_col, end_col)
---@return table|nil
local function filepath_from_str(str, need_hl)
  -- <>, (), [], ..., file://(...)
  local tmp = normalize_str(str)

  local r = filepath_with_lnum_col(tmp)
  if not r then
    return  -- NOTE: not a filepath, return nil
  end

  -- 需要计算 highlight lnum, start_col, end_col
  if need_hl then
    local pat_plain = r.original_fp
    if r.lnum then
      pat_plain = pat_plain .. ':' .. r.lnum
      if r.col then
        pat_plain = pat_plain .. ':' .. r.col
      end
    end

    -- 1: 从第一个 char 还是匹配
    -- true: plain=true, 关闭正则匹配, 避免 'pattern' 被解析为 Lua pattern
    r.i, r.j = string.find(str, pat_plain, 1, true)
    if not r.i or not r.j then
      error("string find error")
    end
  end

  return r
end

-- hl 不存在则只需要分析 absolute filepath 可用于 jump to path, 不需要分析 highlight start_col & end_col.
-- hl 存在则使用 string.find() & nvim_buf_add_highlight() 可用于 highlight.
--
---@param content string
---@return table|nil
M.parse_content = function(content)
  return filepath_from_str(content)
end

-- 获取所有需要 highlight 的 filepaths
--
---@return {bufnr: integer, pos: HighLightPos[]}|nil hl_params
M.parse_current_line = function()
  ---@type { bufnr: integer, pos: HighLightPos[] }
  local rs = {
    bufnr = vim.api.nvim_get_current_buf(),
    pos = {},
  }

  local lnum = vim.api.nvim_win_get_cursor(0)[1]  -- vim.fn.line('.')

  -- 根据 \t 或者 ' ' 进行 split
  local lsplits = vim.split(vim.api.nvim_get_current_line(), '[ \t]+', { trimempty=true })

  local pos = 0
  for _, value in ipairs(lsplits) do
    if #value ~= 0 then
      local r = filepath_from_str(value, 'hl')
      if r then
        ---@type HighLightPos
        local hl_pos = {
          type         = r.type,
          hl_lnum      = lnum -1,  -- vim.hl.range 中 lnum 是 0-indexed
          hl_start_col = pos + r.i -1,
          hl_end_col   = pos + r.j,
          original_fp  = r.original_fp,
          absolute_fp  = r.absolute_fp,
        }

        table.insert(rs.pos, hl_pos)
      end
    end

    pos = #value+pos+1 -- NOTE: move pos
  end

  if #rs.pos > 0 then
    return rs
  end
end

return M
