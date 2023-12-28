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
  local fname = vim.fn.matchstr(splits[1], '\\f\\+')
  if splits[1] ~= fname then
    return
  end

  local absolute_fp = vim.fn.fnamemodify(splits[1], ':p')

  local r = {}

  --- dir
  if vim.fn.isdirectory(absolute_fp) == 1 then
    r.type = 'dir'
    r.original_fp = splits[1]
    r.absolute_fp = absolute_fp
    return r
  end

  --- file
  if vim.fn.filereadable(absolute_fp) == 1 then
    r.type = 'file'
    r.original_fp = splits[1]
    r.absolute_fp = absolute_fp

    if splits[2] and tonumber(splits[2]) then
      r.lnum = splits[2]
      if splits[3] and tonumber(splits[3]) then
        r.col = splits[3]
      end
    end
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
M.parse_content = function(content, hl)
  local r = filepath_from_str(content, hl)
  if r and not hl then
    return r  -- 不需要 highlight 的情况下直接返回
  end

  if r and hl then
    local lcontent = vim.api.nvim_get_current_line()
    local find = lua_escape(content)  -- escape '()[]+-*.?%^$'

    local i, j = string.find(lcontent, '^' .. find)
    if not i then
      i, j = string.find(lcontent, '%s' .. find)
      i = i+1 -- 去掉 %s 计算在内的 index
    end

    if i then
      local start_col = i + r.i - 2
      local end_col   = i + r.j - 1

      return {
        bufnr = vim.api.nvim_get_current_buf(),
        type = r.type,
        hl_lnum = vim.fn.line('.') -1,
        hl_start_col = start_col,
        hl_end_col = end_col,
        original_fp = r.original_fp,
        absolute_fp = r.absolute_fp,
      }
    end
  end
end

M.parse_hl_line = function()
  local rs = {}
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

        table.insert(rs, {
          bufnr = vim.api.nvim_get_current_buf(),
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

  if #rs > 0 then
    return rs
  end
end

return M
