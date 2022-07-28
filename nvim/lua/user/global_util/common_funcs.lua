--- NOTE: 返回光标所在位置是否已经在最左侧了, 或者光标前一个字符是否为 %s, 即:\n \t \r space ...
---       目的是判断是否需要执行 backspace.
---       true - 本行前一位没有任何字符; nil - 本行前一位有字符.
function Check_backspace()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

--- 去掉 string prefix suffix whitespace -----------------------------------------------------------
--- 类似 vim.fn.trim()
function Trim_string(str)
  return string.match(str, "^%s*(.-)%s*$")
end

--- escape charactor -------------------------------------------------------------------------------
function Escape_chars(string)
  return string.gsub(string, "[%(|%)|\\|%[|%]|%-|%{%}|%?|%+|%*|%^|%$|%.]", {
    ["\\"] = "\\\\",
    ["-"] = "\\-",
    ["("] = "\\(",
    [")"] = "\\)",
    ["["] = "\\[",
    ["]"] = "\\]",
    ["{"] = "\\{",
    ["}"] = "\\}",
    ["?"] = "\\?",
    ["+"] = "\\+",
    ["*"] = "\\*",
    ["^"] = "\\^",
    ["$"] = "\\$",
    ["."] = "\\.",
  })
end

--- NOTE: 以下是 test functions --------------------------------------------------------------------

--- 测试 autocmd FileType 传入的 params.buf 和 bufnr() 得出的结果是否一样.
--- 可以通过 `:badd file` 打开一个文件, 但不 Enter/Load.
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = {"*"},
--   callback = function(params)
--     local bufinfo = vim.fn.getbufinfo(params.buf)[1]
--     print('bufnr():', vim.fn.bufnr(), '| params.buf:', params.buf, '| bufname():', vim.fn.bufname(), "| getbufinfo(params.buf):", bufinfo.bufnr, bufinfo.name)
--     print()
--   end
-- })



