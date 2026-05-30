-- c: "cterm", g: "gui"
---@type table<string, { c: integer, g: string }>
Colors = {
  white   = { c=251, g='#C0C0C0' },  -- foreground, text
  black   = { c=233, g='#121212' },  -- black background
  cyan    = { c=81,  g='#9CDCFE' },  -- VVI: one of vim's main color. SpecialChar, Underlined, Label ...
  yellow  = { c=220, g='#FFD800' },  -- Search, lualine: Insert Mode background && tabline: tab seleced background
  magenta = { c=213, g='#FF87FF' },  -- IncSearch, return, if, else, break, package, import
  red     = { c=167, g='#F85249' },  -- error message
  orange  = { c=208, g='#FFA000' },  -- warning message
  blue    = { c=75,  g='#4FC1FF' },  -- info message, constant ...
  grey_hint = {c=244,g='#808080' },  -- hint message
  green   = { c=42,  g='#00D787' },  -- OK message, markdown title

  -- 其他常用颜色
  -- VVI: Keyword 和 Boolean 最好是一样颜色, 省去很多麻烦
  blue_boolean = { c=74,  g='#569CD6' },  -- Keyword, Boolean, Special ...
  green_type   = { c=79,  g='#4EC9B0' },  -- type, 数据类型
  green_bg     = { c=35,  g='#00AF5F' },  -- command mode bg color
  red_bg       = { c=52,  g='#66201D' },  -- 作为 background 使用的红色. '#4E201E', '#72201D'
  gold_fn      = { c=78,  g='#DCDCAA' },  -- 78|85, func, function_call, method, method_call ... | bufferline, lualine
  purple       = { c=170, g='#D75FD7' },

  -- grayscale 颜色
  g234 = { c=234, g='#1C1C1C' },
  g235 = { c=235, g='#262626' },
  g236 = { c=236, g='#303030' },
  g237 = { c=237, g='#3A3A3A' },
  g238 = { c=238, g='#444444' },
  g239 = { c=239, g='#4E4E4E' },
  g240 = { c=240, g='#585858' },
  g241 = { c=241, g='#626262' },
  g242 = { c=242, g='#6C6C6C' },
  g243 = { c=243, g='#767676' },
  g244 = { c=244, g='#808080' },
  g245 = { c=245, g='#8A8A8A' },
  g246 = { c=246, g='#949494' },
}



