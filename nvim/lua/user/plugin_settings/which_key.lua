local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

--- Shift + Ctrl + fn key Rename --- {{{
local function fn_key_rename()
  local fn_keys = {}

  for i=1,12,1 do
    fn_keys['<F' .. i+12 .. '>'] = '<S-F' .. i .. '>'
    fn_keys['<F' .. i+24 .. '>'] = '<C-F' .. i .. '>'
    fn_keys['<F' .. i+36 .. '>'] = '<C-S-F' .. i .. '>'
  end

  -- print(vim.inspect(fn_keys))
  return fn_keys
end
-- -- }}}

--- setup ---
which_key.setup({
  plugins = {
    marks = false,     -- shows a list of your marks on ' and `
    registers = true,  -- shows your registers on "/@ in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = false,  -- z= select spelling suggestions, NOTE: 目前使用的 telescope
      suggestions = 36, -- how many suggestions should be shown in the list?
    },
    --- the presets plugin, adds help for a bunch of default keybindings in Neovim,
    --- No actual key bindings are created.
    --- presets 是 which-key 预设好的 keymap. 虽然和系统快捷键功能一样,
    --- 但是进行了二次绑定, 所以会覆盖 keymaps.lua 中的设置.
    presets = {
      --- https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua
      ---  BUG: 下面的 operators 和 text_objects 设置中都有 'a', 'i' 设置, 重复显示.
      operators = false,  -- 'c', 'd', 'y', 'v' ... 例如: 'ciw', 'caw', 'diw' ...
                          -- VVI: 设为 true 会影响 <, > buffer 跳转.
      motions = false,   -- 'g', 例如: 'gg', 'ge' ...
      text_objects = true,  -- 'a' - around, 'i' - inside.

      --- https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/misc.lua
      windows = true,  -- <c-w>
      nav = true,  -- '[', ']' ...
      z = true,    -- 'z=', 'zz', 'zo', 'zc' ...
      g = true,    -- 'gn', 'gN', 'gi', 'gv', 'gx', 'gf', 'g%'
    },
  },
  operators = { gc = "Comments" },  -- NOTE: 手动 trigger which-key 显示.

  --- NOTE: override the label used to display some keys.
  --- 这里是将 <F24> rename 到 <S-F12> ...
  key_labels = fn_key_rename(),

  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜",  -- symbol used between a key and it's label
    group = "+",     -- symbol prepended to a group
  },
  popup_mappings = {
    scroll_down = '<down>', -- <C-d> binding to scroll down inside the popup
    scroll_up = '<up>', -- <C-u> binding to scroll up inside the popup
  },

  --- NOTE: 窗口显示设置.
  window = {
    border = "none", -- none, single, double, shadow
    position = "bottom", -- bottom, top
    margin = { 1, 0, 1, 0 },  -- extra window margin  [top, right, bottom, left]
    padding = { 1, 0, 1, 0 }, -- extra window padding [top, right, bottom, left]
    winblend = 0,  -- NOTE: 除非使用 termguicolors, 否则设置为 0.
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },

  ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
  show_help = true, -- show help message 在下方 <bs> 返回上一层菜单, <esc> 退出.

  --- VVI: hide mapping boilerplate, for-loop string.gsub(str, '<cmd>', '')
  hidden = {
    "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "require", "^:", "^ ",
    "render.canvas'%)._mapping%('",  -- HACK: for 'dap-ui' default keymapping.
  },

  triggers = "auto", -- automatically setup triggers
  --triggers = {"<leader>"} -- or specify a list manually
  triggers_blacklist = {
    --- list of mode / prefixes that should never be hooked by WhichKey
    --- this is mostly relevant for key maps that start with a native binding
    --- most people should not need to change this
    i = { "j", "k" },
    v = { "j", "k" },
  },

  -- disable the WhichKey popup for certain buf types and file types.
  -- Disabled by deafult for Telescope
  disable = {
    buftypes = {},
    --- 这里 filetypes 主要是全屏的 floating window
    filetypes = { "NvimTree", "TelescopePrompt", "mason", "packer", "null-ls-info", "lspinfo" },
  },
})

--- highlight --------------------------------------------------------------------------------------
--- WhichKeyFloat && WhichKeyBorder 可以设置
vim.api.nvim_set_hl(0, 'WhichKeyDesc', {ctermfg = Color.cyan})



