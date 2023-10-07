--- NOTE: indent line 和 set list & set listchars 配合使用.

--- Use a protected call so we don't error out on first use
--- require("indent_blankline")  -- load v2.x
--- require("ibl")  -- load v3.x
local status_ok, indent_blankline = pcall(require, "ibl")
if not status_ok then
  return
end

--- 设置 indent.char 颜色 -------------------------------------------------------------------------- {{{
-- vim.api.nvim_set_hl(0, 'RainbowGrey',   {ctermfg=240})
-- vim.api.nvim_set_hl(0, 'RainbowRed',    {ctermfg=167})
-- vim.api.nvim_set_hl(0, 'RainbowYellow', {ctermfg=180})
-- vim.api.nvim_set_hl(0, 'RainbowBlue',   {ctermfg=75})
-- vim.api.nvim_set_hl(0, 'RainbowOrange', {ctermfg=173})
-- vim.api.nvim_set_hl(0, 'RainbowGreen',  {ctermfg=107})
-- vim.api.nvim_set_hl(0, 'RainbowViolet', {ctermfg=176})
-- vim.api.nvim_set_hl(0, 'RainbowCyan',   {ctermfg=73})
--
-- local indent_highlights = {
--   'RainbowGrey',
--   'RainbowRed',
--   'RainbowYellow',
--   'RainbowBlue',
--   'RainbowOrange',
--   'RainbowGreen',
--   'RainbowViolet',
--   'RainbowCyan',
-- }
-- -- }}}

--- set list & set listchars, NOTE: 在 settings.lua 中设置.
--vim.opt.list = true
--vim.opt.listchars:append("space:⋅")
--vim.opt.listchars:append("eol:↴")

--- `:help indent-blankline`
indent_blankline.setup({
  enabled = true,  -- Enables or disables indent-blankline

  --- `:help ibl.config.indent`
  indent = {
    char = "│",     -- space indent char
    tab_char = "│",  -- tab indent char
    -- highlight = indent_highlights,  --- colorful indent line.
  },

  --- `:help ibl.config.whitespace`
  whitespace = {
    remove_blankline_trail = true,
    -- highlight = "NonText",  --- `listchars.trail` ·· 点的颜色
  },

  --- `:help ibl.config.scope`, cursor 所在位置的 treesitter node 的相关颜色, 需要 treesitter.
  scope = {
    enabled = false,  --- NOTE: Scope requires treesitter to be set up.
    -- show_start = false,  -- Underline first line of the scope.
    -- show_end = false,    -- Underline last line of the scope.
  },

  exclude = {
    filetypes = {
      "qf",  -- quickfix & location list
      "help",
      "packer",
      "NvimTree",
      "tagbar",
      "startify",
      "dashboard",
      "neogitstatus",
      "Trouble",
      --"python",  -- python 不适合 indent line.
    },
    buftypes = { "nofile", "quickfix", "help", "terminal", "prompt" },
  },
})



