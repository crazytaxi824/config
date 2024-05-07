--- NOTE: indent line 和 set list & set listchars 配合使用.

--- Use a protected call so we don't error out on first use
--- require("indent_blankline")  -- load v2.x
--- require("ibl")  -- load v3.x
local status_ok, indent_blankline = pcall(require, "ibl")
if not status_ok then
  return
end

--- 设置 indent.char 颜色 --------------------------------------------------------------------------
vim.api.nvim_set_hl(0, 'RainbowGrey',   {ctermfg=Colors.hint_grey.c, fg=Colors.hint_grey.g})
vim.api.nvim_set_hl(0, 'RainbowRed',    {ctermfg=Colors.red.c, fg=Colors.red.g})
vim.api.nvim_set_hl(0, 'RainbowYellow', {ctermfg=Colors.yellow.c, fg=Colors.yellow.g})
vim.api.nvim_set_hl(0, 'RainbowBlue',   {ctermfg=Colors.blue.c, fg=Colors.blue.g})
vim.api.nvim_set_hl(0, 'RainbowOrange', {ctermfg=Colors.orange.c, fg=Colors.orange.g})
vim.api.nvim_set_hl(0, 'RainbowGreen',  {ctermfg=Colors.green.c, fg=Colors.green.g})
vim.api.nvim_set_hl(0, 'RainbowViolet', {ctermfg=Colors.magenta.c, fg=Colors.magenta.g})
vim.api.nvim_set_hl(0, 'RainbowCyan',   {ctermfg=Colors.cyan.c, fg=Colors.cyan.g})

--- set list & set listchars, NOTE: 在 settings.lua 中设置.
--vim.opt.list = true
--vim.opt.listchars:append("space:⋅")
--vim.opt.listchars:append("eol:↴")

--- `:help indent-blankline` -----------------------------------------------------------------------
indent_blankline.setup({
  enabled = true,  -- Enables or disables indent-blankline

  --- `:help ibl.config.indent`
  indent = {
    char = "│",      -- space indent char
    tab_char = "│",  -- tab indent char
    -- highlight = {  -- colorful indent line.  --- {{{
    --   'RainbowGrey',
    --   'RainbowRed',
    --   'RainbowYellow',
    --   'RainbowBlue',
    --   'RainbowOrange',
    --   'RainbowGreen',
    --   'RainbowViolet',
    --   'RainbowCyan',
    -- },
    -- -- }}}
  },

  --- `:help ibl.config.whitespace`
  whitespace = {
    remove_blankline_trail = true,
    -- highlight = "NonText",  --- `listchars.trail` ·· 点的颜色
  },

  --- `:help ibl.config.scope`, cursor 所在位置的 treesitter node 显示 underline, 需要 treesitter.
  --- NOTE: Scope requires treesitter to be set up.
  scope = {
    enabled = true,
    show_start = false,  -- Underline first line of the scope. eg: "func Foo()"
    show_end = false,    -- Underline last line of the scope. eg: "return"
    highlight = {
      'RainbowGreen',
      'RainbowBlue',
    },
  },

  exclude = {
    filetypes = {
      "NvimTree",
      "startify",
      "dashboard",
      "neogitstatus",
      "Trouble",
    },
    buftypes = { "nofile", "quickfix", "help", "terminal", "prompt" },
  },
})



