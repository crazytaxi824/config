local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

--- fn key icons ----------------------------------------------------------------------------------- {{{
local fn_key_icons = {
  F1  = "F1",
  F2  = "F2",
  F3  = "F3",
  F4  = "F4",
  F5  = "F5",
  F6  = "F6",
  F7  = "F7",
  F8  = "F8",
  F9  = "F9",
  F10 = "F10",
  F11 = "F11",
  F12 = "F12",

  F13 = "󰘶 F1",
  F14 = "󰘶 F2",
  F15 = "󰘶 F3",
  F16 = "󰘶 F4",
  F17 = "󰘶 F5",
  F18 = "󰘶 F6",
  F19 = "󰘶 F7",
  F20 = "󰘶 F8",
  F21 = "󰘶 F9",
  F22 = "󰘶 F10",
  F23 = "󰘶 F11",
  F24 = "󰘶 F12",

  F25 = "󰘴 F1",
  F26 = "󰘴 F2",
  F27 = "󰘴 F3",
  F28 = "󰘴 F4",
  F29 = "󰘴 F5",
  F30 = "󰘴 F6",
  F31 = "󰘴 F7",
  F32 = "󰘴 F8",
  F33 = "󰘴 F9",
  F34 = "󰘴 F10",
  F35 = "󰘴 F11",
  F36 = "󰘴 F12",

  F37 = "󰘶 󰘴 F1",
  F38 = "󰘶 󰘴 F2",
  F39 = "󰘶 󰘴 F3",
  F40 = "󰘶 󰘴 F4",
  F41 = "󰘶 󰘴 F5",
  F42 = "󰘶 󰘴 F6",
  F43 = "󰘶 󰘴 F7",
  F44 = "󰘶 󰘴 F8",
  F45 = "󰘶 󰘴 F9",
  F46 = "󰘶 󰘴 F10",
  F47 = "󰘶 󰘴 F11",
  F48 = "󰘶 󰘴 F12",

  F49 = "󰘵 F1",
  F50 = "󰘵 F2",
  F51 = "󰘵 F3",
  F52 = "󰘵 F4",
  F53 = "󰘵 F5",
  F54 = "󰘵 F6",
  F55 = "󰘵 F7",
  F56 = "󰘵 F8",
  F57 = "󰘵 F9",
  F58 = "󰘵 F10",
  F59 = "󰘵 F11",
  F60 = "󰘵 F12",
}
-- -- }}}

--- setup ------------------------------------------------------------------------------------------
--- `:help which-key.nvim.txt`
--- `:help which-key.nvim-which-key-configuration`
which_key.setup({
  plugins = {
    marks = true,     -- shows a list of your marks on ' and `
    registers = true,  -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = false,  -- z= select spelling suggestions, NOTE: 目前使用的 telescope
      --suggestions = 20, -- how many suggestions should be shown in the list?
    },
    --- the presets plugin, adds help for a bunch of default keybindings in Neovim,
    --- No actual key bindings are created.
    --- presets 是 which-key 预设好的 keymap. 虽然和系统快捷键功能一样,
    --- 但是进行了二次绑定, 所以会覆盖 keymaps.lua 中的设置.
    presets = {
      operators = false,  -- 'c', 'r', 'd', 'y', 'v' ... 例如: 'ciw', 'yaw', 'diw' ...
      -- motions = true,   -- 'g', 例如: 'gg', 'ge' ...
      -- text_objects = true,  -- 'a' - around, 'i' - inside.
      -- windows = true,  -- <c-w>
      -- nav = true,  -- '[', ']' ...
      -- z = true,    -- 'z=', 'zz', 'zo', 'zc' ...
      -- g = true,    -- 'gn', 'gN', 'gi', 'gv', 'gx', 'gf', 'g%'
    },
  },

  --- `:help which-key.nvim-which-key-triggers`
  -- triggers = {
  --   { "<auto>", mode = "nxso" },
  --   { "<auto>", mode = "nixsotc" },
  --   { "a", mode = { "n", "v" } },
  --   { "<leader>", mode = { "n", "v" } },
  -- },

  icons = {
    mappings = false,  -- NOTE: not use mini.icons & nvim-web-devicons
    separator = "»", -- symbol used between a key and it's label
    keys = fn_key_icons,
  },

  win = {
    -- don't allow the popup to overlap with the cursor
    no_overlap = false,
  },

  keys = {
    scroll_down = '<S-D-down>', -- <C-d> binding to scroll down inside the popup
    scroll_up = '<S-D-up>', -- <C-u> binding to scroll up inside the popup
  },

  sort = { "group", "mod", "desc", "alphanum" },

  --- disable the WhichKey popup for certain buf types and file types.
  --- Disabled by deafult for Telescope
  disable = {
    --- disable buftypes
    bt = {},
    --- 这里 filetypes 主要是全屏的 floating window
    -- ft = { "NvimTree", "TelescopePrompt", "mason", "packer", "lazy", "null-ls-info", "lspinfo" },
  },
})

--- VVI: mark which key is loaded. vim.cmd('doautocmd User LoadedWhichKey')
vim.api.nvim_exec_autocmds("User", { pattern = { "LoadedWhichKey" }})

--- highlight --------------------------------------------------------------------------------------
--- WhichKeyFloat && WhichKeyBorder 可以设置
vim.api.nvim_set_hl(0, 'WhichKeyDesc', {ctermfg=Colors.cyan.c, fg=Colors.cyan.g})



