local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

-- load "L3MON4D3/LuaSnip"
local _, luasnip = pcall(require, "luasnip")


-- `:help cmp-config.sources`. 其他设置: group_index, max_item_count, priority ...
-- 显示 group 1 的时候不会显示 group 2 的内容; 显示 group 2 的时候不会显示 group 1 的内容.
local function sources()
  local sl = {
    { name = "nvim_lsp" },  -- "hrsh7th/cmp-nvim-lsp"
    { name = "path" },  -- "hrsh7th/cmp-path"
    { name = "buffer", max_item_count = 3 }, -- "hrsh7th/cmp-buffer", 最多显示 n 条.
  }

  -- "saadparwaiz1/cmp_luasnip" -> "L3MON4D3/LuaSnip"
  -- NOTE: other snippets engine -------------------------------------------- {{{
  --{ name = 'vsnip' },      -- For vsnip users      -- "hrsh7th/vim-vsnip" vim-script
  --{ name = 'luasnip' },    -- For luasnip users    -- "L3MON4D3/LuaSnip" lua
  --{ name = 'snippy' },     -- For snippy users     -- "dcampos/nvim-snippy" lua
  --{ name = 'ultisnips' },  -- For ultisnips users  -- "SirVer/ultisnips" python
  -- }}}
  if luasnip then
    table.insert(sl, { name = "luasnip", max_item_count = 3, priority = 999 })
  end

  return sl
end


-- NOTE: 快速调节 cmp 显示效果
local cmp_opts = {
  icon_color_reverse = false,  -- 是否需要 reverse icon color
  format_full = false,  -- 是否显示全部内容, {"icon", "abbr", "kind", "menu"}
}

-- "hrsh7th/nvim-cmp" 主要设置 --------------------------------------------------------------------
-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItemKind
-- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/types/lsp.lua#L177
-- `:lua vim.print(vim.lsp.protocol.CompletionItemKind)`

---@type table<string, { text:string, icon:string }>
local kind_text_icon = {  ------------------------------------------------------------------------------ {{{
  Keyword     = { text="keywd",  icon="" },  -- 
  Text        = { text="text",   icon="󰊄" },  --   󰊄  
  Module      = { text="module", icon="" },  -- 󰮄 , eg: import [module]
  Method      = { text="method", icon="󰊕" },  -- 󰆧
  Function    = { text="func",   icon="󰊕" },
  Constructor = { text="constr", icon="󰊕" },
  Variable    = { text="var",    icon="󰫧" },
  Constant    = { text="const",  icon="󰫧" },
  Class       = { text="class",  icon="" },  -- NOTE: golang 只有 "Type" 没有 "Class", eg: int; typescript 只有 "Class" 没有 "Type"
  Struct      = { text="struct", icon="" },  -- , typescript 没有 "Struct"
  Interface   = { text="iface",  icon="" },  -- 󰡀 󱘖 󰴽 󰌹 󱐥
  Field       = { text="field",  icon="" },
  Property    = { text="prop",   icon="" },
  Enum        = { text="enum",   icon="󰨾" },  -- 󰝖 󰨾 󰅪
  EnumMember  = { text="enum",   icon="󰨾" },
  Folder      = { text="/dir~",  icon="" },
  File        = { text="/file~", icon="" },
  Snippet     = { text="snip",   icon="" },

  -- 不常用
  TypeParameter = { text="tparam", icon="" },  -- "type"
  Color         = { text="color",  icon="󱥚" },  -- 
  Reference     = { text="ref",    icon="" },  -- 󰌹  
  Event         = { text="event",  icon="" },
  Operator      = { text="op",     icon="󰾞" },  -- 󱓉
  Unit          = { text="unit",   icon="󰺾" },  -- 󰺾   󰳂, eg: css 中(长度, 时间 ...)单位, eg: px, rem, ms
  Value         = { text="value",  icon="󰎠" },  -- 󰎠    󰗀, eg: yaml schema, css 中提供的可选值
}
-- }}}

-- 默认设置: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua
-- DOCS: `:help nvim-cmp`
cmp.setup {
  preselect = cmp.PreselectMode.None,  -- cmp.PreselectMode.None | cmp.PreselectMode.Item

  -- performance = {
  --   debounce = 120,  -- 停止输入文字的时间超过该数值, 则向 sources 请求更新 completion Item. 默认 60.
  --   throttle = 60,   -- 停止输入文字的时间超过该数值, 则匹配和过滤本地已获取的 completion Item. 默认 30.
  --   fetching_timeout = 200,  -- 默认 200.
  -- },

  -- 给 "saadparwaiz1/cmp_luasnip" 设置 snippet
  -- snippet = {
  --   expand = function(args)
  --   end,
  -- },

  -- `:help cmp-config.sources`. 其他设置: group_index, max_item_count, priority ...
  sources = sources(),

  window = {
    completion = {
      col_offset = cmp_opts.icon_color_reverse and -3 or -2,  -- Offsets the completion window relative to the cursor
      side_padding = cmp_opts.icon_color_reverse and 0 or 1,  -- left padding only
      scrollbar = true,  -- true: 需要时显示 scrollbar; false: 永远不显示 scrollbar.
      -- border = {"","","","","","","",""},
      -- winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
    },
    documentation = {
      border = {"", "", "", "▕", "", "", "", "▏"},  -- 只显示左右 border, `:help nvim_open_win()`
      -- winhighlight = 'FloatBorder:NormalFloat',
    },
  },

  -- completion 菜单显示
  formatting = {
    -- show the `~` expandable indicator in cmp's floating window. eg: 'fmtp~  [snip]'
    expandable_indicator = true,

    -- abbr: suggestion
    -- kind: "function", "method", "module"...
    -- menu: [LSP], [Buffer]...
    fields = cmp_opts.format_full and { "icon", "abbr", "kind", "menu" } or { "icon", "abbr", "menu" },

    format = function(entry, vim_item)
      -- add icons
      if cmp_opts.icon_color_reverse then
        vim_item.icon = string.format(' %s ', kind_text_icon[vim_item.kind].icon or '?')  -- width=3: col_offset=-3, side_padding=0
      else
        vim_item.icon = string.format('%s', kind_text_icon[vim_item.kind].icon or '?')  -- width=1: col_offset=-2, side_padding=1
      end

      -- NOTE: 对 Class 特殊处理, typescript 中没有 "Type", golang 中没有 "Class".
      local langs_no_class = { 'go', 'rust', 'zig', 'c' }
      if vim.tbl_contains(langs_no_class, vim.bo.filetype) and vim_item.kind == 'Class' then
        vim_item.kind = string.format('%s', 'type')
      else
        vim_item.kind = string.format('%s', kind_text_icon[vim_item.kind].text)
      end

      -- vim_item.menu = " "  -- 不显示 menu
      vim_item.menu = ({
        luasnip  = "[snip]",
        nvim_lsp = "[lsp~]",  -- 󰒍 
        buffer   = "[buff]",  -- 
        path     = "[path]",
      })[entry.source.name]

      return vim_item
    end,
  },

  experimental = {
    ghost_text = false, -- this feature conflict with Copilot.vim's preview.
    native_menu = false, -- disable it. 影响 cmdline auto completion.
  },

  -- DOCS: key mapping, `:help cmp-mapping`, mode = { `i` = insert mode(default), `c` = command mode, `s` = select mode }
  -- command mode 主要用于 : / ? search; select mode 主要用于 snippet.
  mapping = {  ------------------------------------------------------------------------------------- {{{
    -- 当使用 select_prev/next_item() 的时候. abort() 关闭代码提示窗, 同时回到代码之前的状态;
    -- cmp.mapping.close() 也可以关闭代码提示窗口, 但是会保持代码现在的状态.
    -- 当使用 select_prev_item({behavior=cmp.SelectBehavior}) 的时候, abort() & close() 效果相同.
    ["<ESC>"] = cmp.mapping.abort(),  -- omit mode means insert mode only.
    ["<C-e>"] = cmp.mapping(cmp.mapping.abort(), { "i", "c", "s" }),

    -- 如果 backspace 过程中删除了关键 char - "." 则 reset, 用于修复 snip 和 buff 无法显示的问题.
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

    -- SelectBehavior: 选择 item 的时候不会将内容填到行内.
    ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior, count = 1 }),  { "i", "c", "s" }),
    ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior, count = 1 }),{ "i", "c", "s" }),

    ["<S-Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior, count = 3 }),  { "i", "c", "s" }),
    ["<S-Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior, count = 3 }),{ "i", "c", "s" }),

    ["<PageUp>"]   = cmp.mapping(cmp.mapping.scroll_docs(-3)),
    ["<PageDown>"] = cmp.mapping(cmp.mapping.scroll_docs(3)),

    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    -- VVI: needed <CR> map to confirm() to enable 'autopairs'
    ["<CR>"] = cmp.mapping({
      i = cmp.mapping.confirm({ select = true }),  -- true: 如果没有选中 item, 则选中第一个 item.
      c = cmp.mapping.confirm({ select = false }), -- false: 如果没有选中 item 则直接执行.
    }),

    ["<C-Space>"] = cmp.mapping(function(fallback)
      -- HACK: :reset() cmp cache. fix: [snip] and [buff] missing when delete dot(.) char.
      cmp.core:reset()
      cmp.complete()
    end, { "i", "c", "s" }),  -- 手动触发 completion window.

    -- <Tab> 不同情况下触发不同行为.
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })  -- 确认选择
      elseif luasnip and luasnip.expand_or_locally_jumpable() then
        -- expand    指展开 snippest, eg: fmtp -> fmt.Println(|)
        -- jumpable  指有可以 jump 的 node, eg: ${1}
        -- locally_jumpable  same as jumpable, except it ignored if the cursor is not inside the current snippet.
        luasnip.expand_or_jump()  -- 展开 snippet OR 跳转到下一个 jumpable node
      else
        --cmp.complete()  -- 手动触发 completion menu.
        fallback()  -- 执行快捷键原本的功能
      end
    end, { "i", "c", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if luasnip and luasnip.locally_jumpable(-1) then  -- 如果存在 previous jumpable node
        luasnip.jump(-1)  -- 跳转到 previous jumpable node
      else
        fallback()  -- 执行快捷键原本的功能
      end
    end, { "i", "s" }),
  },  -- }}}
}

-- command line completion, 设置
-- Use buffer source for `/` and `?` (cmp.setup() 中 `native_menu` 必须为 false).
cmp.setup.cmdline({ '/', '?' }, {
  -- enabled = false,
  -- mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  },
  window = {
    completion = {
      col_offset = -1,  -- Offsets the completion window relative to the cursor
      scrollbar = true,  -- true: 需要时显示 scrollbar; false: 永远不显示 scrollbar.
    },
  },
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
  window = {
    completion = {
      col_offset = 1,  -- Offsets the completion window relative to the cursor
      side_padding = 1,  -- left padding only
      scrollbar = true,  -- true: 需要时显示 scrollbar; false: 永远不显示 scrollbar.
    },
  },
  formatting = {
    fields = { "abbr" },
  },
  matching = { disallow_symbol_nonprefix_matching = false },
})

-- Cmp completion menu color ----------------------------------------------------------------------- {{{
-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance

-- 匹配文字的颜色
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { ctermfg=Colors.magenta.c, fg=Colors.magenta.g })
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link = "CmpItemAbbrMatch" })

-- [lsp], [buff], [path], [snip] icon 颜色
vim.api.nvim_set_hl(0, 'CmpItemMenu', { ctermfg=Colors.g239.c, fg=Colors.g239.g })

-- VVI: CmpItemKindXXX 默认颜色, 如果没有单独设置 CmpItemKindXXX 颜色则会使用该颜色.
vim.api.nvim_set_hl(0, 'CmpItemKindDefault', { ctermfg=Colors.g245.c, fg=Colors.g245.g })

vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { link = '@keyword' })
vim.api.nvim_set_hl(0, 'CmpItemKindModule',  { link = '@module' })

vim.api.nvim_set_hl(0, 'CmpItemKindInterface',     { link = '@type' })
vim.api.nvim_set_hl(0, 'CmpItemKindClass',         { link = '@type' })
vim.api.nvim_set_hl(0, 'CmpItemKindStruct',        { link = '@type' })
vim.api.nvim_set_hl(0, 'CmpItemKindTypeParameter', { link = '@type' })

vim.api.nvim_set_hl(0, 'CmpItemKindFunction',    { link = '@function' })
vim.api.nvim_set_hl(0, 'CmpItemKindMethod',      { link = '@function' })
vim.api.nvim_set_hl(0, 'CmpItemKindConstructor', { link = '@function' })

vim.api.nvim_set_hl(0, 'CmpItemKindEnum',       { link = '@variable' })
vim.api.nvim_set_hl(0, 'CmpItemKindEnumMember', { link = '@variable' })
vim.api.nvim_set_hl(0, 'CmpItemKindVariable',   { link = '@variable' })
vim.api.nvim_set_hl(0, 'CmpItemKindConstant',   { link = '@constant' })

vim.api.nvim_set_hl(0, 'CmpItemKindField',    { link = '@field' })
vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { link = '@property' })

-- blue
vim.api.nvim_set_hl(0, 'CmpItemKindSnippet', { link = 'WarningMsg' })
vim.api.nvim_set_hl(0, 'CmpItemKindFile',    { link = 'Normal' })
vim.api.nvim_set_hl(0, 'CmpItemKindFolder',  { link = 'Directory' })
vim.api.nvim_set_hl(0, 'CmpItemKindColor',   { link = 'Conditional' })  -- magenta

-- grey, 弃用的 suggestion.
vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated',  { ctermfg=Colors.g242.c, fg=Colors.g242.g, strikethrough = true })

-- Icon highlights links to Kind, eg: 'CmpItemKindClass' -> 'CmpItemKindClassIcon'
for name, _ in pairs(vim.lsp.protocol.CompletionItemKind) do
  local kind_hl_name = 'CmpItemKind' .. name
  local icon_hl_name = kind_hl_name .. "Icon"
  local kind_hl = vim.api.nvim_get_hl(0, { name=kind_hl_name, link=false })
  local icon_hl = vim.tbl_extend('force', kind_hl, { reverse = true })
  if cmp_opts.icon_color_reverse then
    vim.api.nvim_set_hl(0, icon_hl_name, icon_hl)  -- reverse kind color
  else
    vim.api.nvim_set_hl(0, icon_hl_name, { link=kind_hl_name })  -- no reverse color
  end
end

-- }}}



