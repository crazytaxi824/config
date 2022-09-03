--- NOTE: 返回光标所在位置是否已经在最左侧了, 或者光标前一个字符是否为 %s, 即:\n \t \r space ...
---       目的是判断是否需要执行 backspace.
---       true - 本行前一位没有任何字符; nil - 本行前一位有字符.
function Check_backspace()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

--- escape RegExp charactor ------------------------------------------------------------------------
--- escape 传入的整个 string 用于 RegExp.
--- '%%' 代表 '%' 是 lua string.gsub(), string.match(), string.find(), string.gmatch() 中的 pattern safe substitute.
--- https://fhug.org.uk/kb/kb-article/understanding-lua-patterns/
--- % . [ ] ^ $ ( ) * + - ? 有特殊含义, 需要使用 '%' escape. NOTE: 这里不包括 \ { }
---
--- 以下函数的意思是将 ()[]{} ... 这些 char 替换成 \(\)\[\]\{\} ... 用于 RegExp.
--- 而 RegExp 中需要对 \ { } 进行 escape, 但不需要对 % escape.
---
--- eg: Escape_RegExp_chars('()[]{}%.^*$+-\\')  -> \(\)\[\]\{\}%\.\^\*\$\+\-\\
function Escape_RegExp_chars(string)
  return string.gsub(string, "[\\%(%)%[%]{}%?%+%-%*%^%$%.]", {
    ["\\"] = "\\\\",  -- \ -> \\
    ["("] = "\\(",
    [")"] = "\\)",
    ["["] = "\\[",
    ["]"] = "\\]",
    ["{"] = "\\{",
    ["}"] = "\\}",
    ["?"] = "\\?",
    ["+"] = "\\+",
    ["-"] = "\\-",
    ["*"] = "\\*",
    ["^"] = "\\^",
    ["$"] = "\\$",
    ["."] = "\\.",
  })
end



