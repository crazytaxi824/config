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
local kind_icon_txt = {  --- {{{
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
  Unit = "unit",
  Value = "val",
  Enum = "enum",
  EnumMember = "enum",
  Keyword = "keywd",
  Snippet = "snip",
  Color = "color",
  File = "file",
  Reference = "ref",
  Folder = "dir",
  Variable = "var",
  Constant = "const",
  Event = "event",
  Operator = "op",
}
-- -- }}}

--- 默认设置: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua
cmp.setup {
  preselect = cmp.PreselectMode.None,  -- NOTE: cmp.PreselectMode.None | cmp.PreselectMode.Item

  performance = {
   debounce = 120,  --- 停止输入文字的时间超过该数值, 则向 sources 请求更新 completion Item. 默认 60.
   throttle = 60,   --- 停止输入文字的时间超过该数值, 则匹配和过滤本地已获取的 completion Item. 默认 30.
   -- fetching_timeout = 200,  --- 默认 200.
  },

  snippet = {  -- 给 "saadparwaiz1/cmp_luasnip" 设置 snippet
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For "L3MON4D3/LuaSnip" users.
      --require('snippy').expand_snippet(args.body) -- For `snippy` users.
      --vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      --vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },

  sources = {
    --- `:help cmp-config.sources`. 其他设置: group_index, max_item_count, priority ...
    --- 显示 group 1 的时候不会显示 group 2 的内容; 显示 group2 的时候不会显示 group 1 的内容.
    { name = "luasnip",  group_index = 1, priority = 999 }, -- "saadparwaiz1/cmp_luasnip" -> "L3MON4D3/LuaSnip"
    { name = "nvim_lsp", group_index = 1 },  -- "hrsh7th/cmp-nvim-lsp"
    { name = "buffer",   group_index = 1, max_item_count = 6 }, -- "hrsh7th/cmp-buffer", 最多显示 n 条.
    { name = "path",     group_index = 2 },  -- "hrsh7th/cmp-path"
    --- NOTE: other snippets engine --- {{{
    --{ name = 'vsnip' },      -- For vsnip users      -- "hrsh7th/vim-vsnip" vim-script
    --{ name = 'luasnip' },    -- For luasnip users    -- "L3MON4D3/LuaSnip" lua
    --{ name = 'snippy' },     -- For snippy users     -- "dcampos/nvim-snippy" lua
    --{ name = 'ultisnips' },  -- For ultisnips users  -- "SirVer/ultisnips" python
    -- -- }}}
  },

  window = {
    --completion = cmp.config.window.bordered({border = "single"}),  -- `:help nvim_open_win()`
    --documentation = cmp.config.window.bordered({border = "single"}),
  },

  --- completion 菜单显示
  formatting = {
    --- show the `~` expandable indicator in cmp's floating window. eg: 'fmtp~  [snip]'
    expandable_indicator = true,

    --- abbr: suggestion
    --- kind: function, method, module...
    --- menu: [LSP], [Buffer]...
    fields = { "abbr", "kind", "menu" },

    format = function(entry, vim_item)
      vim_item.kind = string.format("   %s", kind_icon_txt[vim_item.kind])  --  kind icon 前多个空格
      --vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)  -- 使用图标和 kind_name

      --- 不显示 menu
      vim_item.menu = " "
      --- 如果需要显示 menu 使用以下设置.
      -- vim_item.menu = ({
      --   luasnip  = "[Snip]",
      --   nvim_lsp = "[LSP]",
      --   buffer   = "[Buff]",
      --   path     = "[Path]",
      -- })[entry.source.name]

      return vim_item
    end,
  },

  experimental = {
    ghost_text = false,
    native_menu = false,   -- VVI: disable it.
  },

  --- key mapping -------
  mapping = {
    ["<Up>"] = cmp.mapping.select_prev_item(),
    ["<Down>"] = cmp.mapping.select_next_item(),
    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<Esc>"] = cmp.mapping.abort(),

    --- 其他 cmp.mapping 设置方式 --- {{{
    -- ["<C-e>"] = cmp.mapping {  -- 默认 <C-e>, 对 insert, command 模式分别设置不同的行为.
    --   i = cmp.mapping.abort(),
    --   c = cmp.mapping.close(),
    -- },
    --
    -- ["{"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    -- ["}"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
    -- ["<C-s>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),   -- 手动触发 completion. NOTE: 不需要.
    -- -- }}}

    --- Accept currently selected item. If none selected, `select` first item.
    --- Set `select` to `false` to only confirm explicitly selected items.
    ["<CR>"] = cmp.mapping.confirm({ select = true }),

    --- <Tab> 不同情况下触发不同行为.
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })  -- 确认选择
      elseif luasnip.expand_or_locally_jumpable() then
        --- expand   是指展开 snippest
        --- jumpable 是指 cursor 跳转到 placeholder ${1}
        luasnip.expand_or_jump()  -- 展开 snippet OR 跳转到下一个 snippets placeholder
      else
        --cmp.complete()  -- 手动触发 completion menu.
        fallback()  -- 执行原本的功能
      end
    end, {"i","s"}), -- 在 insert select 模式下使用

    -- ["<S-Tab>"] = cmp.mapping(function(fallback)  --- {{{
    --   if luasnip.jumpable(-1) then  -- 如果存在上一个 snippets placeholder
    --     luasnip.jump(-1)  -- 跳转到上一个 snippets placeholder
    --   else
    --     fallback()
    --   end
    -- end, {"i","s"}),
    -- -- }}}
  },
}

--- NOTE: command line completion, 分开设置. 因为不能使用自定义 key mapping.
---       不要设置 command line completion, keymap 不好用.
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
vim.cmd [[hi CmpItemAbbrMatch ctermfg=213]]
vim.cmd [[hi CmpItemAbbrMatchFuzzy ctermfg=213]]

--- [lsp], [buffer], [path], [snippet] 颜色
vim.cmd [[hi CmpItemMenu ctermfg=43]]

--- VVI: CmpItemKindXXX 默认颜色, 如果没有单独设置 CmpItemKindXXX 颜色则会使用该颜色.
vim.cmd [[hi CmpItemKindDefault ctermfg=248]]

vim.cmd [[hi! link CmpItemKindInterface Type]]
vim.cmd [[hi! link CmpItemKindClass Type]]
vim.cmd [[hi! link CmpItemKindStruct Type]]
vim.cmd [[hi! link CmpItemKindTypeParameter Type]]
vim.cmd [[hi! link CmpItemKindFunction Function]]
vim.cmd [[hi! link CmpItemKindMethod Function]]
vim.cmd [[hi! link CmpItemKindConstructor Function]]
vim.cmd [[hi! link CmpItemKindKeyword Keyword]]
vim.cmd [[hi! link CmpItemKindVariable Keyword]]
vim.cmd [[hi! link CmpItemKindConstant Keyword]]
vim.cmd [[hi! link CmpItemKindEnum Keyword]]
vim.cmd [[hi! link CmpItemKindModule String]]

--- cyan
vim.cmd [[hi CmpItemKindFile ctermfg=81]]
vim.cmd [[hi CmpItemKindFolder ctermfg=81]]

-- grey
vim.cmd [[hi CmpItemAbbrDeprecated ctermfg=244 cterm=underline]]  -- 弃用的 suggestion.

-- blue
vim.cmd [[hi CmpItemKindSnippet ctermfg=75]]

-- -- }}}


