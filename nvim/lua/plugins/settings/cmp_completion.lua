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
--- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItemKind
--- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/types/lsp.lua#L177
local kind_icon_txt = {  --------------------------------------------------------------------------- {{{
  Text = "txt",
  Module = "module",     -- import
  Method = "method",
  Function = "func",
  Constructor = "construct",
  Field = "field",
  Property = "property",
  Class = "class",  -- golang 中 type MyInt int/map/... 的 kind 是 Class
  Struct = "struct",  -- golang 中 type Persion struct{} 的 kind 是 Struct
  Interface = "iface",  -- golang 中 type Constraint interface{} 的 kind 是 Interface
  TypeParameter = "t-param",
  Unit = "unit",
  Value = "value",
  Enum = "enum",
  EnumMember = "enum",
  Keyword = "keyword",
  Snippet = "snippet",
  Color = "color",
  Reference = "ref",
  Folder = "/dir~",
  File = "/file~",
  Variable = "var",
  Constant = "const",
  Event = "event",
  Operator = "operator",
}
-- -- }}}

--- 默认设置: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua
--- DOCS: `:help nvim-cmp`
cmp.setup {
  preselect = cmp.PreselectMode.None,  -- cmp.PreselectMode.None | cmp.PreselectMode.Item

  -- performance = {
  --   debounce = 120,  --- 停止输入文字的时间超过该数值, 则向 sources 请求更新 completion Item. 默认 60.
  --   throttle = 60,   --- 停止输入文字的时间超过该数值, 则匹配和过滤本地已获取的 completion Item. 默认 30.
  --   fetching_timeout = 200,  --- 默认 200.
  -- },

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
    --- 显示 group 1 的时候不会显示 group 2 的内容; 显示 group 2 的时候不会显示 group 1 的内容.
    { name = "luasnip", priority = 999 }, -- "saadparwaiz1/cmp_luasnip" -> "L3MON4D3/LuaSnip"
    { name = "nvim_lsp" },  -- "hrsh7th/cmp-nvim-lsp"
    { name = "buffer", max_item_count = 6 }, -- "hrsh7th/cmp-buffer", 最多显示 n 条.
    { name = "path" },  -- "hrsh7th/cmp-path"
    --- NOTE: other snippets engine -------------------------------------------- {{{
    --{ name = 'vsnip' },      -- For vsnip users      -- "hrsh7th/vim-vsnip" vim-script
    --{ name = 'luasnip' },    -- For luasnip users    -- "L3MON4D3/LuaSnip" lua
    --{ name = 'snippy' },     -- For snippy users     -- "dcampos/nvim-snippy" lua
    --{ name = 'ultisnips' },  -- For ultisnips users  -- "SirVer/ultisnips" python
    -- -- }}}
  },

  window = {
    completion = {
      -- border = {"","","","","","","",""},
      -- winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None',
      scrollbar = true,  -- true: 需要时显示 scrollbar; false: 永远不显示 scrollbar.
    },
    documentation = {
      border = {"", "", "", "▕", "", "", "", "▏"},  -- `:help nvim_open_win()`
      --winhighlight = 'FloatBorder:NormalFloat',
    },
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
      if vim.bo.filetype == 'go' and vim_item.kind == 'Class' then
        vim_item.kind = string.format("   %s", 'type')
      else
        vim_item.kind = string.format("   %s", kind_icon_txt[vim_item.kind])  --  kind icon 前多个空格
        --vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)  -- 使用图标和 kind_name
      end

      --- 不显示 menu
      -- vim_item.menu = " "
      --- 如果需要显示 menu 使用以下设置.
      vim_item.menu = ({
        luasnip  = " [Snip]",
        nvim_lsp = " [LSP]",
        buffer   = " [Buff]",
        path     = " [Path]",
      })[entry.source.name]

      return vim_item
    end,
  },

  experimental = {
    ghost_text = false, -- this feature conflict with Copilot.vim's preview.
    native_menu = false, -- disable it. 影响 cmdline auto completion.
  },

  --- DOCS: key mapping, `:help cmp-mapping`, mode = { `i` = insert mode(default), `c` = command mode, `s` = select mode }
  --- command mode 主要用于 : / ? search; select mode 主要用于 snippet.
  mapping = {
    --- 当使用 select_prev/next_item() 的时候. abort() 关闭代码提示窗, 同时回到代码之前的状态;
    --- cmp.mapping.close() 也可以关闭代码提示窗口, 但是会保持代码现在的状态.
    --- 当使用 select_prev_item({behavior=cmp.SelectBehavior}) 的时候, abort() & close() 效果相同.
    ["<ESC>"] = cmp.mapping.abort(),  -- omit mode means insert mode only.
    ["<C-e>"] = cmp.mapping(cmp.mapping.abort(), { "i", "c", "s" }),

    --- 如果 backspace 过程中删除了关键 char - "." 则 reset, 用于修复 snip 和 buff 无法显示的问题.
    ["<BS>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_get_current_line()
        if col > 0 and line:sub(col, col) == '.' then
          fallback()  -- 执行快捷键原本的功能
          cmp.core:reset() -- HACK: :reset() cmp cache. fix: [snip] and [buff] missing when delete dot(.) char.
        end
      end

      fallback()  -- 执行快捷键原本的功能
    end),

    --- SelectBehavior: 选择 item 的时候不会将内容填到行内.
    ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior, count = 1 }),  { "i", "c", "s" }),
    ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior, count = 1 }),{ "i", "c", "s" }),

    ["<S-Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior, count = 3 }),  { "i", "c", "s" }),
    ["<S-Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior, count = 3 }),{ "i", "c", "s" }),

    ["<PageUp>"]   = cmp.mapping(cmp.mapping.scroll_docs(-3)),
    ["<PageDown>"] = cmp.mapping(cmp.mapping.scroll_docs(3)),

    --- Accept currently selected item. If none selected, `select` first item.
    --- Set `select` to `false` to only confirm explicitly selected items.
    --- VVI: needed <CR> map to confirm() to enable 'autopairs'
    ["<CR>"] = cmp.mapping({
      i = cmp.mapping.confirm({ select = true }),  -- true: 如果没有选中 item, 则选中第一个 item.
      c = cmp.mapping.confirm({ select = false }), -- false: 如果没有选中 item 则直接执行.
    }),

    ["<C-Space>"] = cmp.mapping(function(fallback)
      --- HACK: :reset() cmp cache. fix: [snip] and [buff] missing when delete dot(.) char.
      cmp.core:reset()
      cmp.complete()
    end, { "i", "c", "s" }),  -- 手动触发 completion window.

    --- <Tab> 不同情况下触发不同行为.
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })  -- 确认选择
      elseif luasnip.expand_or_locally_jumpable() then
        --- expand    指展开 snippest, eg: fmtp -> fmt.Println(|)
        --- jumpable  指有可以 jump 的 node, eg: ${1}
        --- locally_jumpable  same as jumpable, except it ignored if the cursor is not inside the current snippet.
        luasnip.expand_or_jump()  -- 展开 snippet OR 跳转到下一个 jumpable node
      else
        --cmp.complete()  -- 手动触发 completion menu.
        fallback()  -- 执行快捷键原本的功能
      end
    end, { "i", "c", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(-1) then  -- 如果存在 previous jumpable node
        luasnip.jump(-1)  -- 跳转到 previous jumpable node
      else
        fallback()  -- 执行快捷键原本的功能
      end
    end, { "i", "s" }),
  },
}

--- command line completion, 设置
-- Use buffer source for `/` and `?` (cmp.setup() 中 `native_menu` 必须为 false).
cmp.setup.cmdline({ '/', '?' }, {
  -- enabled = false,
  -- mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (cmp.setup() 中 `native_menu` 必须为 false).
cmp.setup.cmdline(':', {
  -- enabled = false,
  -- mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

--- Cmp completion menu color ---------------------------------------------------------------------- {{{
--- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance

--- 匹配文字的颜色
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', {ctermfg=Colors.magenta.c, fg=Colors.magenta.g})
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', {ctermfg=Colors.magenta.c, fg=Colors.magenta.g})

--- [lsp], [buff], [path], [snip] icon 颜色
vim.api.nvim_set_hl(0, 'CmpItemMenu', {ctermfg=Colors.g240.c, fg=Colors.g240.g})

--- VVI: CmpItemKindXXX 默认颜色, 如果没有单独设置 CmpItemKindXXX 颜色则会使用该颜色.
vim.api.nvim_set_hl(0, 'CmpItemKindDefault', {ctermfg=Colors.g246.c, fg=Colors.g246.g})

vim.api.nvim_set_hl(0, 'CmpItemKindInterface', {link = 'Type'})
vim.api.nvim_set_hl(0, 'CmpItemKindClass',     {link = 'Type'})
vim.api.nvim_set_hl(0, 'CmpItemKindStruct',    {link = 'Type'})
vim.api.nvim_set_hl(0, 'CmpItemKindTypeParameter', {link = 'Type'})
vim.api.nvim_set_hl(0, 'CmpItemKindFunction',    {link = 'Function'})
vim.api.nvim_set_hl(0, 'CmpItemKindMethod',      {link = 'Function'})
vim.api.nvim_set_hl(0, 'CmpItemKindConstructor', {link = 'Function'})
vim.api.nvim_set_hl(0, 'CmpItemKindKeyword' , {link = 'Keyword'})
vim.api.nvim_set_hl(0, 'CmpItemKindVariable', {link = 'Keyword'})
vim.api.nvim_set_hl(0, 'CmpItemKindConstant', {link = 'Keyword'})
vim.api.nvim_set_hl(0, 'CmpItemKindEnum',     {link = 'Keyword'})
vim.api.nvim_set_hl(0, 'CmpItemKindModule',   {link = 'String'})

-- blue
vim.api.nvim_set_hl(0, 'CmpItemKindSnippet', {ctermfg=Colors.blue_boolean.c, fg=Colors.blue_boolean.g})
vim.api.nvim_set_hl(0, 'CmpItemKindFile',    {ctermfg=Colors.blue_boolean.c, fg=Colors.blue_boolean.g})
vim.api.nvim_set_hl(0, 'CmpItemKindFolder',  {ctermfg=Colors.blue_boolean.c, fg=Colors.blue_boolean.g, bold = true})

--- grey, 弃用的 suggestion.
vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated',  {ctermfg=Colors.g242.c, fg=Colors.g242.g, underline = true})

-- -- }}}


