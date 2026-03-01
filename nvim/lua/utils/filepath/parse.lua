--- @class HighLightPos
---
--- uv.fs_stat.result.type
--- @field type 'file'|'directory'
---
--- filepath
--- @field original_fp string
---
--- absolute_filepath `vim.fs.abspath()`
--- @field absolute_fp string
---
--- highlight start column `vim.hl.range()`
--- @field hl_start_col integer
---
--- highlight end column `vim.hl.range()`
--- @field hl_end_col integer
---
--- highlight line number (start & end same line) `vim.hl.range()`
--- @field hl_lnum integer


local M = {}

--- index elem of a list
---
--- @param list string[]
--- @param v string
--- @return integer|nil
local function index_of(list, v)
  for index, value in ipairs(list) do
    if value == v then
      return index
    end
  end
end

--- Lua Patterns: escape '()[]+-*.?%^$'
---
--- @param x string|number
--- @return string
--- @return integer count
local function lua_escape(x)
  return string.gsub(x, '[%%%(%)%[%]%?%+%-%*%^%$%.]', {
    ['%'] = "%%",
    ["("] = "%(",
    [")"] = "%)",
    ["["] = "%[",
    ["]"] = "%]",
    ["?"] = "%?",
    ["+"] = "%+",
    ["-"] = "%-",
    ["*"] = "%*",
    ["^"] = "%^",
    ["$"] = "%$",
    ["."] = "%.",
  })
end

--- clear { '`', '"', "'", '(', '[', '{', '<'}
---
--- @param str string
--- @return string
local function clear_brackets(str)
  local start_brackets = { '`', '"', "'", '(', '[', '{', '<'}
  local end_brackets   = { '`', '"', "'", ')', ']', '}', '>'}

  local b_index = index_of(start_brackets, string.sub(str,1,1))
  if b_index and string.sub(str,-1,-1) == end_brackets[b_index] then
    str = string.sub(str, 2, -2)
  end

  return str
end

--- clear 'file://' schema
---
--- @param str string
--- @return string
local function clear_file_schema(str)
  local t = string.match(str, 'file://(.*)')
  if t then
    return t
  end
  return str
end

--- 从 str 中获取 filepath or dir, eg: /a/b/c:12:3
---
--- @param str string
--- @return table|nil
local function filepath_with_lnum_col(str)
  -- str:gsub(str, '%z', '󰟢')  -- lua 中 %z 表示 Null(\0)

  --- split filename:lnum:col
  local splits = vim.split(str, ':', {trimempty=true})

  --- 判断所有字符是否都是 file name character. `:help \f`
  --- 使用 pcall() 防止 str 中含有 Null(\0) 等 blob chars.
  local ok, fname = pcall(vim.fn.matchstr, splits[1], '\\f\\+')
  if not ok or splits[1] ~= fname then
    return
  end

  local absolute_fp = vim.fs.abspath(splits[1])
  local finfo = vim.uv.fs_stat(absolute_fp)
  if not finfo then
    return
  end

  local r = {}

  --- dir
  if finfo.type == 'directory' then
    r.type = finfo.type
    r.original_fp = splits[1]
    r.absolute_fp = absolute_fp
    return r
  end

  --- file
  if finfo.type == 'file' then
    r.type = finfo.type
    r.original_fp = splits[1]
    r.absolute_fp = absolute_fp
    r.lnum = tonumber(splits[2])
    r.col = tonumber(splits[3])
    return r
  end
end

--- 分析 filepath
---
--- @param str string
--- @param hl string|boolean|nil (标记: 是否计算 highlight lnum, start_col, end_col)
--- @return table|nil
local function filepath_from_str(str, hl)
  local tmp = clear_brackets(str)  -- <>, (), [], ...
  tmp = clear_file_schema(tmp)  -- file://

  local r = filepath_with_lnum_col(tmp)
  if not r then
    return  -- NOTE: not a filepath, return nil
  end

  --- 需要计算 highlight lnum, start_col, end_col
  if hl then
    local find = lua_escape(r.original_fp)
    if r.lnum then
      find = find .. ':' .. r.lnum
      if r.col then
        find = find .. ':' .. r.col
      end
    end

    r.i, r.j = string.find(str, find)
  end

  return r
end

--- hl 不存在则只需要分析 absolute filepath 可用于 jump to path, 不需要分析 highlight start_col & end_col.
--- hl 存在则使用 string.find() & nvim_buf_add_highlight() 可用于 highlight.
---
--- @param content string
--- @return table|nil
M.parse_content = function(content)
  return filepath_from_str(content)
end

--- 获取所有需要 highlight 的 filepaths
---
--- @return {bufnr: integer, pos: HighLightPos[]}|nil hl_params
M.parse_hl_line = function()
  --- {bufnr, pos=[]}
  local rs = {
    bufnr = vim.api.nvim_get_current_buf(),

    --- @type HighLightPos[]
    pos = {},
  }

  local lcontent = string.gsub(vim.api.nvim_get_current_line(), '\t', ' ')  --- VVI: replace '\t' with ' '
  local lnum = vim.fn.line('.')
  local lsplits = vim.split(lcontent, ' ', {trimempty=false})

  local pos = 0
  for _, value in ipairs(lsplits) do
    if #value ~= 0 then
      local r = filepath_from_str(value, 'hl')
      if r then
        local start_col = pos + r.i -1
        local end_col   = pos + r.j

        --- @type HighLightPos
        local hl_pos = {
          type = r.type,
          hl_lnum = lnum -1,
          hl_start_col = start_col,
          hl_end_col = end_col,
          original_fp = r.original_fp,
          absolute_fp = r.absolute_fp,
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
