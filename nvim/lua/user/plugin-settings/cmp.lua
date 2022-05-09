local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

--- load "L3MON4D3/LuaSnip"
local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

--- "hrsh7th/nvim-cmp" 主要设置 --------------------------------------------------------------------
--- NOTE: find more here: https://www.nerdfonts.com/cheat-sheet
local kind_icons = {  --- {{{
  Text = "txt",
  Module = "module",     -- import
  Method = "fn",
  Function = "fn",
  Constructor = "fn",
  Field = "fld",
  Property = "fld",
  Struct = "struct",
  Class = "struct",
  Interface = "iface",
  TypeParameter = "param",
  Unit = "u",
  Value = "v",
  Enum = "enum",
  EnumMember = "enum",
  Keyword = "keywd",
  Snippet = "snip",
  Color = "c",
  File = "file",
  Reference = "ref",
  Folder = "dir",
  Variable = "var",
  Constant = "const",
  Event = "event",
  Operator = "op",
}
-- }}}

cmp.setup {
  preselect = cmp.PreselectMode.None,  -- NOTE: cmp.PreselectMode.None | cmp.PreselectMode.Item
  -- 设置 snippet engine, "saadparwaiz1/cmp_luasnip" 插件
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For "L3MON4D3/LuaSnip" users.
    end,
  },
  sources = {
    -- VVI: 顺序很重要
    { name = "luasnip" },   -- "saadparwaiz1/cmp_luasnip" -> "L3MON4D3/LuaSnip"
    { name = "nvim_lsp" },  -- "hrsh7th/cmp-nvim-lsp"
    { name = "buffer" },    -- "hrsh7th/cmp-buffer"
    { name = "path" },      -- "hrsh7th/cmp-path"
    -- NOTE: other snippets engine --- {{{
    -- { name = 'vsnip' },     -- For vsnip users     -- "hrsh7th/vim-vsnip" vim-script
    -- { name = 'luasnip' },   -- For luasnip users   -- "L3MON4D3/LuaSnip" lua
    -- { name = 'snippy' },    -- For snippy users    -- "dcampos/nvim-snippy" lua
    -- { name = 'ultisnips' }, -- For ultisnips users -- "SirVer/ultisnips" python
    -- }}}
  },
  window = {
    --completion = cmp.config.window.bordered({border = "single"}),  -- `:help nvim_open_win()`
    --documentation = cmp.config.window.bordered({border = "single"}),
  },
  -- completion 菜单显示
  formatting = {
    fields = { "abbr", "kind", "menu" },
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format("   %s", kind_icons[vim_item.kind])  --  kind icon 前多个空格
      -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
      vim_item.menu = ({
        luasnip  = "[Snip]",
        nvim_lsp = "[LSP]",
        buffer   = "[Buff]",
        path     = "[Path]",
      })[entry.source.name]
      return vim_item
    end,
  },
  experimental = {
    ghost_text = false,
    native_menu = false,   -- VVI: disable it.
  },
  -- key mapping -------
  mapping = {
    ["<Up>"] = cmp.mapping.select_prev_item(),
    ["<Down>"] = cmp.mapping.select_next_item(),
    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<Esc>"] = cmp.mapping(cmp.mapping.abort()),
    --["<C-e>"] = cmp.mapping {  -- 默认 <C-e>, 对 insert, command 模式分别设置不同的行为.  --- {{{
    --  i = cmp.mapping.abort(),
    --  c = cmp.mapping.close(),
    --},
    --["{"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    --["}"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
    --["<C-s>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),   -- 手动触发 completion. NOTE: 不需要.
    -- -- }}}

    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ["<CR>"] = cmp.mapping.confirm { select = true },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        -- cmp.select_next_item()  -- 选择下一个 item
        cmp.confirm { select = true }  -- confirm
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        -- cmp.complete()  -- 手动触发 completion menu.
        fallback()  -- 执行原本的功能
      end
    end, {"i","s"}), -- 在 insert select 模式下使用
    --["<S-Tab>"] = cmp.mapping(function(fallback)   --- {{{
    --  if cmp.visible() then
    --    cmp.select_prev_item()
    --  elseif luasnip.jumpable(-1) then
    --    luasnip.jump(-1)
    --  else
    --    fallback()
    --  end
    --end, {"i","s"}),
    -- }}}
  },
}

--- NOTE: command line completion, 分开设置. 因为不能使用自定义 key mapping.
--- NOTE: 不要设置 command line completion, keymap 不好用.
--- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore). --- {{{
-- cmp.setup.cmdline(':', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })
-- -- }}}

--- Cmp completion menu color ---------------------------------------------------------------------- {{{
-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
--- 匹配文字的颜色
vim.cmd [[highlight! CmpItemAbbrMatch ctermfg=213]]
vim.cmd [[highlight! CmpItemAbbrMatchFuzzy ctermfg=213]]

vim.cmd [[highlight! link CmpItemKindInterface Type]]
vim.cmd [[highlight! link CmpItemKindClass Type]]
vim.cmd [[highlight! link CmpItemKindStruct Type]]
vim.cmd [[highlight! link CmpItemKindTypeParameter Type]]
vim.cmd [[highlight! link CmpItemKindFunction Function]]
vim.cmd [[highlight! link CmpItemKindMethod Function]]
vim.cmd [[highlight! link CmpItemKindKeyword Keyword]]
vim.cmd [[highlight! link CmpItemKindModule String]]

-- grey
vim.cmd [[highlight! CmpItemAbbrDeprecated ctermfg=244 cterm=underline]]  -- 弃用的 suggestion.
vim.cmd [[highlight! CmpItemKindText ctermfg=246]]

-- light blue
vim.cmd [[hi! CmpItemKindSnippet ctermfg=75]]

--- }}}


