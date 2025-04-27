local M = {}

local function table_index(tbl, v)
  for index, value in ipairs(tbl) do
    if value == v then
      return index
    end
  end
end

--- Lua Patterns: escape '()[]+-*.?%^$'
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
local function clear_brackets(str)
  local start_brackets = { '`', '"', "'", '(', '[', '{', '<'}
  local end_brackets   = { '`', '"', "'", ')', ']', '}', '>'}

  local b_index = table_index(start_brackets, string.sub(str,1,1))
  if b_index and string.sub(str,-1,-1) == end_brackets[b_index] then
    str = string.sub(str, 2, -2)
  end

  return str
end

--- clear file:// schema
local function clear_file_schema(str)
  local t = string.match(str, 'file://(.*)')
  if t then
    return t
  end
  return str
end

--- 从 str 中获取 filepath or dir, eg: /a/b/c:12:3
local function filepath_with_lnum_col(str)
  --- split filename:lnum:col
  local splits = vim.split(str, ':', {trimempty=true})

  --- 判断所有字符是否都是 file name character. `:help \f`
  --- 使用 pcall() 防止 str 中含有 \n byte(0) 等 blob chars.
  local ok, fname = pcall(vim.fn.matchstr, splits[1], '\\f\\+')
  if not ok or splits[1] ~= fname then
    return
  end

  local absolute_fp = vim.fn.fnamemodify(splits[1], ':p')
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
local function filepath_from_str(str, hl)
  local tmp = clear_brackets(str)  -- <>, (), [], ...
  tmp = clear_file_schema(tmp)  -- file://

  local r = filepath_with_lnum_col(tmp)
  if not r then
    return  -- NOTE: not a filepath, return nil
  end

  --- 需要计算 highlight
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
M.parse_content = function(content)
  local r = filepath_from_str(content)
  return r
end

M.parse_hl_line = function()
  --- {bufnr, pos=[]}
  local rs = {
    bufnr = vim.api.nvim_get_current_buf(),
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

        table.insert(rs.pos, {
          type = r.type,
          hl_lnum = lnum -1,
          hl_start_col = start_col,
          hl_end_col = end_col,
          original_fp = r.original_fp,
          absolute_fp = r.absolute_fp,
        })
      end
    end

    pos = #value+pos+1 -- NOTE: move pos
  end

  if #rs.pos > 0 then
    return rs
  end
end

return M
