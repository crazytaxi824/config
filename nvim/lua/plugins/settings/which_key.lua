local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

--- Shift + Ctrl + fn key Rename ------------------------------------------------------------------- {{{
local function fn_key_rename()
  local fn_keys = {}

  for i=1,12,1 do
    fn_keys['<F' .. i+12 .. '>'] = '<S-F' .. i .. '>'
    fn_keys['<F' .. i+24 .. '>'] = '<C-F' .. i .. '>'
    fn_keys['<F' .. i+36 .. '>'] = '<C-S-F' .. i .. '>'
  end

  -- vim.print(fn_keys)
  return fn_keys
end
-- -- }}}

--- setup ------------------------------------------------------------------------------------------
--- `:help which-key.nvim.txt`
--- `:help which-key.nvim-which-key-configuration`
which_key.setup({
  plugins = {
    marks = false,     -- shows a list of your marks on ' and `
    registers = true,  -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = false,  -- z= select spelling suggestions, NOTE: 目前使用的 telescope
      --suggestions = 20, -- how many suggestions should be shown in the list?
    },
    --- the presets plugin, adds help for a bunch of default keybindings in Neovim,
    --- No actual key bindings are created.
    --- presets 是 which-key 预设好的 keymap. 虽然和系统快捷键功能一样,
    --- 但是进行了二次绑定, 所以会覆盖 keymaps.lua 中的设置.
    --presets = {
    --  operators = true,  -- 'c', 'd', 'y', 'v' ... 例如: 'ciw', 'yaw', 'diw' ... VVI: 设为 true 会和 <, > 冲突.
    --  motions = true,   -- 'g', 例如: 'gg', 'ge' ...
    --  text_objects = true,  -- 'a' - around, 'i' - inside.
    --  windows = true,  -- <c-w>
    --  nav = true,  -- '[', ']' ...
    --  z = true,    -- 'z=', 'zz', 'zo', 'zc' ...
    --  g = true,    -- 'gn', 'gN', 'gi', 'gv', 'gx', 'gf', 'g%'
    --},
  },

  icons = {
    separator = Nerd_icons.arrows.right, -- symbol used between a key and it's label
  },

  --- NOTE: override the label used to display some keys.
  --- 这里是将 <F24> rename 到 <S-F12> ...
  key_labels = fn_key_rename(),

  popup_mappings = {
    scroll_down = '<down>', -- <C-d> binding to scroll down inside the popup
    scroll_up = '<up>', -- <C-u> binding to scroll up inside the popup
  },

  --- NOTE: hide mapping boilerplate, for-loop string.gsub(str, '<cmd>', '')
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " },

  --triggers = "auto", -- automatically setup triggers
  --triggers = {"<leader>"} -- or specify a list manually
  triggers_blacklist = {
    --- list of mode / prefixes that should never be hooked by WhichKey
    --- this is mostly relevant for key maps that start with a native binding
    --- most people should not need to change this
    i = { "j", "k" },
    v = { "j", "k" },
  },

  --- disable the WhichKey popup for certain buf types and file types.
  --- Disabled by deafult for Telescope
  disable = {
    buftypes = {},
    --- 这里 filetypes 主要是全屏的 floating window
    filetypes = { "NvimTree", "TelescopePrompt", "mason", "packer", "null-ls-info", "lspinfo" },
  },
})

--- VVI: mark which key is loaded. vim.cmd('doautocmd User LoadedWhichKey')
vim.api.nvim_exec_autocmds("User", { pattern = { "LoadedWhichKey" }})

--- highlight --------------------------------------------------------------------------------------
--- WhichKeyFloat && WhichKeyBorder 可以设置
vim.api.nvim_set_hl(0, 'WhichKeyDesc', {ctermfg=Color.cyan, fg=Color_gui.cyan})



