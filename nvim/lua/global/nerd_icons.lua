-- NOTE: 这里主要是为了统一 icon 风格.
-- NerdFont: nf-cod-xxx, nf-md-xxx, nd-fa-xxx, nd-oct-xxx(special icons)
Nerd_icons = {
  diag = {
    -- "", "", "", "󰛨",
    "", "", "󰋽", "󰛩",

    error = "",  --    󰅙 󰅚
    warn  = "",  --  
    info  = "󰋽",  -- 󰋽   󰋼 
    hint  = "󰛩",  -- 󰛩 󰛨 ⚐ ⚑  -- NerdFont: lightbulb, flag
  },
  arrows = {
    up    = '↑',  --     󰁝 󰛃  󰳡 󰳢  󰁣 󰁢
    right = '→',  --     󰁔 󰛀  󰳟 󰳠  󰁚 󰁙
    down  = '↓',  --     󰁅 󰛂  󰳟 󰳠  󰁋 󰁊
    left  = '←',  --     󰁍 󰛁  󰳝 󰳞  󰁓 󰁒
  },
  indent = {
    edge   = "│",  -- nvim-tree, listchars.tab, indent-line
    item   = "├",
    corner = "└",
  },

  git = {
    unstaged  = "", --   󰃉
    staged    = "󰄵", --  󰄵
    unmerged  = "", --  󰘭  
    renamed   = "", -- 
    untracked = "", --  󰐖  -- untracked = new file.
    deleted   = "", --  󰍵
    ignored   = "◌", --   ◌ 
  },

  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItemKind
  -- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/types/lsp.lua#L177
  -- `:lua vim.print(vim.lsp.protocol.CompletionItemKind)`
  ---@type table<string, { text: string, icon: string }>
  cmp_kind = {
    Keyword     = { text="keywd",  icon="" },  --  
    Text        = { text="text",   icon="" },  --   󰊄  
    Module      = { text="module", icon="" },  -- 󰮄     -- eg: import [module]
    Method      = { text="method", icon="󰊕" },  -- 󰆧 󰡱 
    Function    = { text="func",   icon="󰊕" },
    Constructor = { text="constr", icon="󰊕" },
    Variable    = { text="var",    icon="󰫧" },  --  󰫧
    Constant    = { text="const",  icon="󰫧" },
    Class       = { text="class",  icon="" },  -- NOTE: golang 只有 "Type" 没有 "Class", eg: int; typescript 只有 "Class" 没有 "Type"
    Struct      = { text="struct", icon="" },  --     -- typescript 没有 "Struct"
    Interface   = { text="iface",  icon="" },  -- 󰡀 󱘖 󰴽 󰌹 󱐥 
    Field       = { text="field",  icon="" },
    Property    = { text="prop",   icon="" },
    Enum        = { text="enum",   icon="󰨾" },  -- 󰝖 󰨾 󰅪
    EnumMember  = { text="enum",   icon="󰨾" },
    Folder      = { text="/dir~",  icon="" },
    File        = { text="/file~", icon="" },
    Snippet     = { text="snip",   icon="" },
    Operator    = { text="op",     icon="󱓉" },  -- 󱓉 󰾞 
    Unit        = { text="unit",   icon="󰺾" },  -- 󰺾   󰳂  -- eg: css 中(长度, 时间 ...)单位, eg: px, rem, ms
    Value       = { text="value",  icon="󰎠" },  -- 󱀍  󰎠   󰗀  -- eg: yaml schema, css 中提供的可选值

    -- 不常用
    TypeParameter = { text="tparam", icon="" },  --   -- "type"
    Color         = { text="color",  icon="󰸌" },  -- 󰸌 󰏘 󱥚 󱍜 󰢵
    Reference     = { text="ref",    icon="" },  -- 󰌹  
    Event         = { text="event",  icon="" },  -- 󰃯   󰧓 󰸗
  },

  border = {"▄","▄","▄","█","▀","▀","▀","█"},  -- `:h nvim_open_win()`
  -- border = {"┌","─","┐","│","┘","─","└","│"},  -- "Box Drawings Light"
  -- border = {"╭","─","╮","│","╯","─","╰","│"},  -- "Box Drawings Light Arc"
  separator = '┃',  -- 用于 fillchars, bufferline offsets.separator
  check = '',  --   󰄬 ✓ ✔ 󰗠   󰄲 󰄵
  close = '✕',  --   󰅖 ✕ ✖ 󰅙   󰅗
  star  = '',  -- 󰓎    ★  
  dot   = '●',  -- ● ○ ◌   
  dot_h = '○',
  lock  = '󰌾',  --   󰌾   
  ellipsis = '',  -- … 
}
