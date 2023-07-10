--- lazy 主要是一个 plugin 安装/管理插件. `:help lazy.nvim.txt`
--- bootstrap
local lazydir = vim.fn.stdpath("data") .. "/lazy"
local lazypath = lazydir .. "/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--- 用于批量检查 plugins 升级. true 的时候, commit 和 tag 都会被设置为 nil.
local nil_value = false
local function str_or_nil(str)
  return (not nil_value and str or nil)
end

--- 插件设置
--- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/editor.lua
local plugins = {
  { "folke/lazy.nvim",
    version = "*", -- install the latest stable version of plugins that support Semver.
  },

  --- Performence & Functions ----------------------------------------------------------------------
  --- Useful lua functions used by lots of plugins
  {"nvim-lua/plenary.nvim",
    commit = str_or_nil("bda256f"),
  },

  --- 通知功能
  {"rcarriga/nvim-notify",
    tag = str_or_nil("v3.12.0"),
    priority = 1000,  -- 影响加载顺序, 默认为 50.
    config = function() require("user.plugin_settings.nvim_notify") end,
  },

  --- 安装 & 管理 lsp/formatter/linter/dap-debug tools 的插件
  {"williamboman/mason.nvim",
    tag = str_or_nil("v1.6.0"),
    build = ":MasonUpdate", -- :MasonUpdate updates All Registries, NOT packages.
    config = function() require("user.plugin_settings.mason_tool_installer") end,
    --- NOTE: 不能 lazyload mason, 否则其他插件无法找到 mason 安装的工具.
  },

  --- 快捷键提醒功能, key mapping 的时候需要注册到 which-key
  {"folke/which-key.nvim",
    tag = str_or_nil("v1.4.3"),
    priority = 999,
    config = function() require("user.plugin_settings.which_key") end,

    event = {"VeryLazy"},
  },

  --- Treesitter -----------------------------------------------------------------------------------
  --- Commands for "nvim-treesitter/nvim-treesitter" --- {{{
  --- `:help nvim-treesitter-commands`
  --- `:TSInstallInfo`        -- List all installed languages
  --- `:TSInstall {lang}`     -- Install languages
  --- `:TSUninstall {lang}`   -- Uninstall languages
  --- `:TSUpdate`             -- Update the installed languages
  --- `:TSUpdateSync`         -- Update the installed languages synchronously
  -- -- }}}
  --- README: https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
  --- All queries found in the runtime directories will be combined.
  --- By convention, if you want to write a query, use the `queries/` directory,
  --- but if you want to extend a query use the `after/queries/` directory.
  {"nvim-treesitter/nvim-treesitter",
    commit = str_or_nil("d9104a1"),  -- NOTE: tag 更新太慢, 建议两周更新一次.
    --build = ":TSUpdate",  -- NOTE: 推荐手动执行, 批量自动安装 parser 容易卡死.
    config = function() require("user.plugin_settings.treesitter") end,
    dependencies = {
      --- 以下都是 treesitter modules 插件, 在 setup() 中启用的插件.
      "nvim-treesitter/nvim-treesitter-context",  -- 顶部显示 cursor 所在 function 的定义.
      "JoosepAlviste/nvim-ts-context-commentstring", -- Comment 依赖 commentstring.
      "windwp/nvim-ts-autotag",  -- auto close tag <div></div>
    },

    event = {"VeryLazy"},
  },

  --- 第一方 module 插件 ---
  {"nvim-treesitter/nvim-treesitter-context",  -- 顶部显示 cursor 所在 function 的定义.
    commit = str_or_nil("63f3ffc"),
    config = function() require("user.plugin_settings.treesitter_ctx") end,

    lazy = true,  -- nvim-treesitter 加载时自动加载.
  },

  {"nvim-treesitter/playground",  -- 用于获取 treesitter 信息, 调整颜色很有用.
    commit = str_or_nil("2b81a01"),
    dependencies = {"nvim-treesitter/nvim-treesitter"},

    cmd = {"TSPlaygroundToggle", "TSHighlightCapturesUnderCursor"},
  },

  --- 第三方 module 插件 ---
  {"windwp/nvim-ts-autotag",  -- auto close tag <div></div>
    commit = str_or_nil("6be1192"),

    lazy = true,  -- nvim-treesitter 加载时自动加载.
  },

  {"JoosepAlviste/nvim-ts-context-commentstring", -- Comment 依赖 commentstring.
    commit = str_or_nil("7f62520"),

    lazy = true,  -- nvim-treesitter 加载时自动加载.
  },

  --- 以下是使用了 treesitter 功能的插件. (这些插件也可以不使用 treesitter 的功能)
  --- 注释
  {"numToStr/Comment.nvim",
    commit = str_or_nil("176e85e"),
    config = function() require("user.plugin_settings.comment") end,
    dependencies = {"JoosepAlviste/nvim-ts-context-commentstring"},  -- https://github.com/numToStr/Comment.nvim#-hooks

    keys = {
      --- VVI: alacritty 中已将 <Command + /> 映射为 <CTRL-J>
      {'<C-j>', '<Plug>(comment_toggle_linewise_current)',      mode = 'n', desc = 'Comment current line'},
      {'<C-j>', '<C-o><Plug>(comment_toggle_linewise_current)', mode = 'i', desc = 'Comment current line'},
      {'<C-j>', '<Plug>(comment_toggle_linewise_visual)',       mode = 'v', desc = 'Comment Visual selected'},
    },
  },

  --- indent line
  {"lukas-reineke/indent-blankline.nvim",
    tag = str_or_nil("v2.20.7"),
    config = function() require("user.plugin_settings.indentline") end,  -- setup() 设置 use_treesitter = true
    dependencies = {"nvim-treesitter/nvim-treesitter"},

    event = {"VeryLazy"},
  },

  --- Auto Completion ------------------------------------------------------------------------------
  {"hrsh7th/nvim-cmp",
    commit = str_or_nil("2743dd9"),
    config = function() require("user.plugin_settings.cmp_completion") end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- lsp 提供的代码补全
      "hrsh7th/cmp-buffer",  -- 当前 buffer 中有的 word
      "hrsh7th/cmp-path",  -- filepath 补全

      "saadparwaiz1/cmp_luasnip",  -- snippets
      "windwp/nvim-autopairs",  -- 括号补全
    },

    event = "InsertEnter",
  },

  --- NOTE: 以下是 "nvim-cmp" 的 module 插件, 在 nvim-cmp.setup() 中启用的插件.
  --- VVI: 只有 "cmp-nvim-lsp" 不需要在 "nvim-cmp" 之后加载, 其他 module 插件都需要在 "nvim-cmp" 加载之后再加载, 否则报错.
  {"hrsh7th/cmp-nvim-lsp",  -- LSP source for nvim-cmp
    commit = str_or_nil("44b16d1"),

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {"hrsh7th/cmp-buffer",  -- 当前 buffer 中有的 word
    commit = str_or_nil("3022dbc"),

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {"hrsh7th/cmp-path",  -- filepath 补全
    commit = str_or_nil("91ff86c"),

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {"saadparwaiz1/cmp_luasnip",  -- Snippets source for nvim-cmp
    commit = str_or_nil("1809552"),
    dependencies = {"L3MON4D3/LuaSnip"},  -- snippets content

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  --- snippet engine, for "cmp_luasnip", 每次打开文件都会有一个 [Scratch] buffer.
  {"L3MON4D3/LuaSnip",
    commit = str_or_nil("a658ae2"),
    build = "make install_jsregexp",  -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#transformations
    config = function() require("user.plugin_settings.luasnip_snippest") end,
    dependencies = {"rafamadriz/friendly-snippets"},  -- snippets content

    lazy = true,  -- cmp_luasnip 加载时自动加载.
  },

  --- snippets content, 自定义 snippets 可以借鉴这个结构.
  {"rafamadriz/friendly-snippets",
    commit = str_or_nil("7f6681b"),

    lazy = true,  -- LuaSnip 加载时自动加载.
  },

  --- 自动括号, 同时依赖 treesitter && cmp
  {"windwp/nvim-autopairs",
    commit = str_or_nil("e8f7dd7"),
    config = function() require("user.plugin_settings.autopairs") end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",  -- setup() 中 `check_ts`, `ts_config` 需要 treesitter 支持.
      "hrsh7th/nvim-cmp",  -- cmp.event:on() 设置.
    },

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  --- LSP ------------------------------------------------------------------------------------------
  --- lspconfig && null-ls 两个插件是互相独立的 LSP client, 没有依赖关系.
  --- 官方 LSP 引擎.
  {"neovim/nvim-lspconfig",
    commit = str_or_nil("0011c43"),
    config = function() require("user.lsp.lsp_config") end,  -- NOTE: 如果加载地址为文件夹, 则会寻找文件夹中的 init.lua 文件.
    dependencies = {
      "williamboman/mason.nvim",  -- 安装 lsp 命令行工具.
    },
  },

  --- null-ls 插件 formatters && linters, depends on "nvim-lua/plenary.nvim"
  {"jose-elias-alvarez/null-ls.nvim",
    commit = str_or_nil("db09b6c"),
    config = function() require("user.lsp.null_ls") end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "williamboman/mason.nvim",  -- 安装 linter/formatter 命令行工具. eg: shfmt, stylua ...
    },

    event = "BufWritePre",  -- save file 的时候 lazyload null-ls
  },

  --- File explorer --------------------------------------------------------------------------------
  {"kyazdani42/nvim-tree.lua",
    commit = str_or_nil("a708bd2"),
    config = function() require("user.plugin_settings.file_tree") end,

    -- VVI: 本文件最后设置: 在 `nvim dir` 直接打开文件夹的时直接加载 nvim-tree.lua.
    event = {"VeryLazy"},
  },

  --- Buffer & Status Line -------------------------------------------------------------------------
  --- tabline decorator, `:help 'tabline'`
  {"akinsho/bufferline.nvim",
    tag = str_or_nil("v4.2.0"),
    config = function() require("user.plugin_settings.decor_bufferline") end,

    event = {"VeryLazy"},
  },

  --- statusline decorator, `:help 'statusline'`
  {"nvim-lualine/lualine.nvim",   -- bottom status line
    commit = str_or_nil("05d78e9"),
    config = function() require("user.plugin_settings.decor_lualine") end,

    event = {"VeryLazy"},
  },

  --- Debug tools 安装 -----------------------------------------------------------------------------
  --- NOTE: dap-ui && dap 设置在同一文件中.
  {"mfussenegger/nvim-dap",  -- core debug tool
    tag = str_or_nil("0.6.0"),
    dependencies = {"williamboman/mason.nvim"},  -- install dap-debug tools. eg: 'delve'

    lazy = true,  -- nvim-dap-ui 加载时自动加载.
  },

  {"rcarriga/nvim-dap-ui",  -- ui for "nvim-dap"
    tag = str_or_nil("v3.8.3"),
    config = function() require("user.plugin_settings.dap_debug") end,  -- dap-ui && dap 设置在同一文件中.
    dependencies = {"mfussenegger/nvim-dap"},

    cmd = {'DapToggleBreakpoint', 'DapContinue', 'DapLoadLaunchJSON'},
  },

  --- Useful Tools ---------------------------------------------------------------------------------
  --- 依赖 rg fd, 但不依赖 fzf. 没有 fzf 命令行工具也可以运行.
  --- telescope 的 preview syntax 使用的是 treesitter, 而 fzf 用的是 bat.
  {"nvim-telescope/telescope.nvim",
    commit = str_or_nil("276362a"),  -- tag = "0.1.2", 半年更新一次 tag
    config = function() require("user.plugin_settings.telescope_fzf") end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },

    event = {"VeryLazy"},
  },

  { "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",

    lazy = true,  -- telescope 加载时自动加载.
  },

  --- terminal
  {"akinsho/toggleterm.nvim",
    tag = str_or_nil("v2.7.0"),  -- NOTE: 尽量少更新, 更新后需要检查 user/utils/term/bg_term 运行情况.
    config = function() require("user.plugin_settings.toggleterm_terminal") end,

    event = {"VeryLazy"},
  },

  --- Git
  --- NOTE: gitsigns 会检查 "trouble.nvim" 是否安装, 如果有安装则:
  --- `:Gitsigns setqflist/seqloclist` will open Trouble instead of quickfix or location list windows.
  --- https://github.com/lewis6991/gitsigns.nvim#troublenvim
  {"lewis6991/gitsigns.nvim",
    commit = str_or_nil("dc2962f"),
    config = function() require("user.plugin_settings.git_signs") end,

    --- VVI: 这里不能用 VeryLazy.
    --- BufReadPre 在打开 file 时会触发, 打开 dir 时不会触发.
    --- `nvim dir` 启动时直接打开 dir 会造成 gitsign 报错.
    event = { "BufReadPre", "BufNewFile" },
  },

  --- tagbar --- {{{
  --- 函数/类型列表，需要安装 Universal Ctags - `brew info universal-ctags`, 注意不要安装错了.
  --- https://github.com/universal-ctags/ctags/blob/master/docs/news.rst#new-parsers
  --- `ctags --list-languages` 查看支持的语言. 不支持 jsx/tsx, 支持 typescript, 勉强支持 javascript
  -- -- }}}
  {"preservim/tagbar",
    commit = str_or_nil("be56353"),
    config = function() require("user.plugin_settings.tagbar") end,

    event = {"VeryLazy"},
  },

  --- markdown preview
  {"iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,  -- VVI: Update 后需要重新安装 preview 插件, 否则可能出现无法运行的情况.
    config = function() vim.cmd('doautocmd mkdp_init BufEnter') end,  -- VVI: 需要这个设置才能使用 cmd 条件加载, 否则报错.

    cmd = {"MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop"},
  },

  --- https://docs.github.com/en/copilot
  --- https://docs.github.com/en/copilot/getting-started-with-github-copilot?tool=neovim#prerequisites-3
  {"github/copilot.vim",
    tag = str_or_nil("v1.9.1"),
    config = function()
      --- VVI: Neovim >= 0.6 and Node.js <= 17
      --- 指定 nodejs 版本. 这里使用的是 `brew install node@16`
      local node_path = "/usr/local/opt/node@16/bin/node"

      --- check node existence
      if vim.fn.filereadable(node_path) == 0 then
        Notify({"'" .. node_path .. "' is NOT Exist."}, "WARN", {title = "github/copilot", timeout = false})
        return
      end

      --- node version 17 or below
      vim.g.copilot_node_command = "/usr/local/opt/node@16/bin/node"
    end,

    cmd = {"Copilot"},  -- `:Copilot setup`, `:Copilot enable`, `:help copilot` 查看可用命令.
  },

  --{"kyazdani42/nvim-web-devicons"}, -- Nerd Fonts 提供 icons 需要 patch 字体
  --{"nvim-neo-tree/neo-tree.nvim"},  -- File explorer. nvim-tree.lua 替代
  --{"Tastyep/structlog.nvim"},   -- log 工具.
  --{"folke/trouble.nvim"},       -- quickfix/loclist 替代.
  --{"goolord/alpha-nvim"},       -- neovim 启动页面
  --{"ahmedkhalf/project.nvim"},  -- project manager

  --{"p00f/nvim-ts-rainbow"},  -- rainbow 括号颜色, treesitter 插件. NOTE: 严重拖慢文件打开速度.
  --{"hrsh7th/cmp-cmdline"},  -- 自动补全 cmd. nvim-cmp 插件. NOTE: 不好用.
}

--- load plugins
local opts = {
  root = lazydir, -- directory where plugins will be installed
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json", -- lockfile generated after running update.
  defaults = {
    lazy = false, -- should plugins be lazy-loaded?
  },
  ui = {  --- {{{
    icons = {
      cmd = " cmd:",
      config = " conf:",
      event = " event:",
      ft = " ft:",
      init = " init:",
      import = " import:",
      keys = " key:",
      lazy = " ● ",
      loaded = "●",
      not_loaded = "○",
      plugin = " plugin:",
      runtime = " runtime:",
      source = " source:",
      start = " ",
      task = "✔ ",
      list = {
        "●",
        "➜",
        "★",
        "‒",
      },
    },
  },
  -- -- }}}
}

local lazy = require('lazy')
lazy.setup(plugins, opts)

--- `nvim dir` 打开文件夹时直接加载 nvim-tree.lua, `nvim file` 打开 file 时不加载 nvim-tree.lua, 通过快捷键加载.
--- VVI: 这里只能使用 BufWinEnter, 不能使用 BufEnter.
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  pattern = {"*"},
  callback = function (params)
    if vim.fn.isdirectory(vim.api.nvim_buf_get_name(params.buf)) == 1 then
      lazy.load({plugins = {"nvim-tree.lua"}})
    end
  end
})



