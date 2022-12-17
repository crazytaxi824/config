--- lazy load opt plugins, loader() 名字可以查看 `plugin/packer_compiled.lua`
--- VVI: 加载顺序很重要
local lazyload_plugins = {
  'nvim-treesitter',  -- TreeSitter, NOTE: 必须要 lazyload, 否则严重影响 neovim startup 速度.
  'nvim-cmp',  -- Auto Completion

  --- VVI: 如果要 lazyload lspconfig 时需要手动 `:LspStart`, 否则当前 buffer 的 autocmd 不会被执行.
  --- 使用 `:LspInfo` 查看会发现当前 bufnr 不在 LSP attach 中.
  --'nvim-lspconfig', -- NOTE: lazyload lspconfig 不会提高 neovim startup 速度, 同时会引起一些 bug.
  'null-ls.nvim',  -- null-ls 和 lspconfig 没有依赖关系.

  --'nvim-tree.lua',  -- NOTE: 不推荐使用 lazyload, 会导致 `$ nvim dir` 直接打开文件夹的时候出现问题.
  'bufferline.nvim',  -- NOTE: 需要先设置 showtabline=2 (always show tabline), 否则在加载 bufferline 后屏幕会向下移动一行.
  'lualine.nvim',

  'nvim-autopairs',
  'toggleterm.nvim',
  'gitsigns.nvim',
  'tagbar',

  --- VVI: 以下插件使用 lazyload 时, 需要设置 {bufread = false}. 否则会多次触发 FileType event.
  'telescope.nvim',
  'LuaSnip',  -- BUG: 目前 LuaSnip 使用 use({opt=true}) 时, 无法加载内置 jsregexp 插件.
}

return lazyload_plugins



