--- NOTE: 这里主要是为了统一 icon 风格.
Nerd_icons = {
  diag = {
    hint  = "󱩎",  -- ⚐ ⚑ 󰛨
    info  = "",  -- 𝖎    
    warn  = "",  -- ⚠️  
    error = "",  -- ❌✕✖︎✗✘⛌
  },
  arrows = {
    up    = '↑',
    right = '→',
    down  = '↓',
    left  = '←',

    tri_up    = '',
    tri_right = '',  -- fold
    tri_down  = '',  -- expand
    tri_left  = '',
  },
  indent = {
    edge   = "│",  -- nvim-tree, listchars.tab, indent-line
    item   = "├",
    corner = "└",
  },
  border = {"▄","▄","▄","█","▀","▀","▀","█"},  -- `:h nvim_open_win()`
  -- border = {"┌","─","┐","│","┘","─","└","│"},  -- "Box Drawings Light"
  -- border = {"╭","─","╮","│","╯","─","╰","│"},  -- "Box Drawings Light Arc"
  separator = '┃',  -- 用于 fillchars, bufferline offsets.separator
  tick  = '✓',  -- ✓✔︎  
  cross = '⛌', -- ❌✕✖︎✗✘⛌ 
  star  = '★',
  modified = '●',
  h_dot = '○',
  lock  = '',
  ellipsis = '', -- … 
  h_circle = "◌", --  
}
