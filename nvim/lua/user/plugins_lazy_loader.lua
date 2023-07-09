--- lazy load opt plugins
local lazyload_plugins = {
  'nvim-treesitter',  -- Tree Sitter, NOTE: 必须要 lazyload, 否则严重影响 neovim startup 速度.
  'indent-blankline.nvim',

  'bufferline.nvim',  -- NOTE: 需要先设置 showtabline=2 (always show tabline), 否则在加载 bufferline 后屏幕会向下移动一行.
  'lualine.nvim',

  'telescope.nvim',
  'toggleterm.nvim',
  'tagbar',
}

return lazyload_plugins
