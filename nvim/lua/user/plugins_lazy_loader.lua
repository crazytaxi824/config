--- lazy load opt plugins,
--- require('packer').loader("foo bar ..."), 名字可以查看 `plugin/packer_compiled.lua`

--- VVI: 加载顺序很重要
local lazyload_plugins = {
  'nvim-treesitter',  -- TreeSitter, NOTE: 必须要 lazyload, 否则严重影响 neovim startup 速度.
  'indent-blankline.nvim',

  --'nvim-tree.lua',  -- NOTE: 不推荐使用 lazyload, 会导致 `$ nvim dir` 直接打开文件夹的时候出现问题.
  'bufferline.nvim',  -- NOTE: 需要先设置 showtabline=2 (always show tabline), 否则在加载 bufferline 后屏幕会向下移动一行.
  'lualine.nvim',

  'toggleterm.nvim',
  'gitsigns.nvim',

  --- VVI: 以下插件使用 lazyload 时, 需要设置 {bufread = false}. 否则会多次触发 FileType event.
  'telescope.nvim',
}

return lazyload_plugins
