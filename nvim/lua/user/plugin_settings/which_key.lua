local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

--- setup ---
which_key.setup({
  plugins = {
    marks = false,     -- shows a list of your marks on ' and `
    registers = true,  -- shows your registers on "/@ in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = false,  -- z= select spelling suggestions, NOTE: 目前使用的 telescope
      suggestions = 36, -- how many suggestions should be shown in the list?
    },
    --- the presets plugin, adds help for a bunch of default keybindings in Neovim, No actual key bindings are created.
    --- presets 是 which-key 预设好的 keymap 绑定. 虽然和系统快捷键功能一样, 但是进行了二次绑定, 所以会覆盖 keymaps.lua 中的设置.
    presets = {
      --- https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua
      operators = false,    -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = false,      -- adds help for motions, eg: 'gg', 'k', 'j', 'h', 'l', '0', '$', '^', 'b', 'e', 'w'...
      text_objects = true,  -- help for text objects, eg: 'va' - around, 'vi' - inside ...
      --- https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/misc.lua
      windows = true,       -- default bindings on <c-w>
      nav = true,           -- '[', ']', 'H', 'M', 'L' ...
      z = true,             -- bindings for folds, spelling and others prefixed with z
      g = true,             -- bindings for prefixed with g. 'gn', 'gN', 'gi', 'gv', 'gx', 'gf', 'g%'
    },
  },
  operators = { gc = "Comments" },  -- NOTE: 手动 trigger which-key 显示.
  key_labels = {
    --- override the label used to display some keys. It doesn't effect WK in any other way.
    --- For example:
    --  ["<space>"] = "SPC",
    --  ["<cr>"] = "RET",
    --  ["<tab>"] = "TAB",
  },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜",  -- symbol used between a key and it's label
    group = "+ ",     -- symbol prepended to a group
  },
  popup_mappings = {
    scroll_down = '<down>', -- <C-d> binding to scroll down inside the popup
    scroll_up = '<up>', -- <C-u> binding to scroll up inside the popup
  },
  window = {
    border = "none", -- none, single, double, shadow
    position = "bottom", -- bottom, top
    margin = { 1, 0, 1, 0 },  -- extra window margin  [top, right, bottom, left]
    padding = { 1, 0, 1, 0 }, -- extra window padding [top, right, bottom, left]
    winblend = 0
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "}, -- hide mapping boilerplate
  show_help = true, -- show help message 在下方 <BSpace> 可以返回上一层菜单.
  triggers = "auto", -- automatically setup triggers
  --triggers = {"<leader>"} -- or specify a list manually
  triggers_blacklist = {
    --- list of mode / prefixes that should never be hooked by WhichKey
    --- this is mostly relevant for key maps that start with a native binding
    --- most people should not need to change this
    i = { "j", "k" },
    v = { "j", "k" },
  },
})



