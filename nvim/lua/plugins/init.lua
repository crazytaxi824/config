--- lazy 主要是一个 安装/管理插件. `:help lazy.nvim.txt`
--- bootstrap -------------------------------------------------------------------------------------- {{{
local lazydir = vim.fn.stdpath("data") .. "/lazy"
local lazypath = lazydir .. "/lazy.nvim"
local lazyrepo = "https://github.com/folke/lazy.nvim.git"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)
-- -- }}}

--- `:help lazy.nvim-lazy.nvim-plugin-spec`
--- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/editor.lua
--- 如果插件被 require(xxx) or pcall(require, xxx) 会马上加载.
local plugins = {
  {
    "folke/lazy.nvim",
    -- version = "*",  -- 相当于 tag='stable'
    tag = "v11.14.1",
  },

  --- Performence & Functions ----------------------------------------------------------------------
  --- Useful lua functions used by lots of plugins
  {
    "nvim-lua/plenary.nvim",
    commit = "2d9b06177",
    priority = 1000,  -- 只在 lazy=false 的情况下有效. 影响加载顺序, 默认值为 50.
  },

  --- 安装 & 管理 lsp/formatter/linter/dap-debug tools 的插件
  {
    "williamboman/mason.nvim",
    commit = "e2f7f90",
    -- tag = "v1.10.0",
    -- build = ":MasonUpdate", -- :MasonUpdate updates All Registries, NOT packages.
    config = function() require("plugins.settings.mason_tool_installer") end,

    --- VVI: 需要在 $PATH 或者 vim.env.PATH 中加入 mason.setup({ "install_root_dir" }) 路径,
    --- 否则不能延迟加载 mason, 需要设置下面的 priority.
    --cmd = {'Mason'},
    priority = 999,
  },

  --- 通知功能
  {
    "rcarriga/nvim-notify",
    tag = "v3.13.5",
    config = function() require("plugins.settings.nvim_notify") end,

    event = "VeryLazy",
  },

  --- 快捷键提醒功能, key mapping 的时候需要注册到 which-key
  {
    "folke/which-key.nvim",
    tag = "v3.13.3",
    config = function() require("plugins.settings.which_key") end,

    event = "VeryLazy",
  },

  --- Treesitter -----------------------------------------------------------------------------------
  --- Commands for "nvim-treesitter/nvim-treesitter" --------------------------- {{{
  --- `:help nvim-treesitter-commands`
  --- `:TSInstallInfo`        -- List all installed languages
  --- `:TSInstall {lang}`     -- Install languages
  --- `:TSUninstall {lang}`   -- Uninstall languages
  --- `:TSUpdate`             -- Update the installed languages
  --- `:TSUpdateSync`         -- Update the installed languages synchronously
  -- -- }}}
  --- DOCS: https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
  --- All queries found in the runtime directories will be combined.
  --- By convention, if you want to write a query, use the `queries/` directory,
  --- but if you want to extend a query use the `after/queries/` directory.
  {
    "nvim-treesitter/nvim-treesitter",
    -- commit = "d22166e",  -- NOTE: tag 更新太慢, 建议两周更新一次.
    config = function() require("plugins.settings.treesitter") end,
  },

  --- 第一方 module 插件 ---
  {
    "nvim-treesitter/nvim-treesitter-context",  -- 顶部显示 cursor 所在 function 的定义.
    -- commit = "e6cc783",
    config = function() require("plugins.settings.treesitter_ctx") end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },

    event = "VeryLazy",
  },

  --- 第三方 module 插件 ---
  {
    "windwp/nvim-ts-autotag",  -- auto close tag <div></div>
    commit = "e239a56",
    config = function() require("plugins.settings.treesitter_autotag") end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },

    event = "VeryLazy",
  },

  --- indent line
  {
    "lukas-reineke/indent-blankline.nvim",
    tag = "v3.8.2",
    config = function() require("plugins.settings.indentline") end,  -- setup() 设置 use_treesitter = true
    dependencies = {"nvim-treesitter/nvim-treesitter"},  -- for setup({scope})

    event = "VeryLazy",
  },

  --- Auto Completion ------------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    commit = "88661b7",
    config = function() require("plugins.settings.cmp_completion") end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- lsp 提供的代码补全
      "hrsh7th/cmp-buffer",  -- 当前 buffer 中有的 word
      "hrsh7th/cmp-path",  -- filepath 补全

      "saadparwaiz1/cmp_luasnip",  -- snippets
    },

    event = "InsertEnter",
  },

  --- NOTE: 以下是 "nvim-cmp" 的 module 插件, 在 nvim-cmp.setup() 中启用的插件.
  --- VVI: 只有 "cmp-nvim-lsp" 不需要在 "nvim-cmp" 之后加载, 其他 module 插件都需要在 "nvim-cmp" 加载之后再加载, 否则报错.
  {
    "hrsh7th/cmp-nvim-lsp",  -- LSP source for nvim-cmp
    commit = "39e2eda",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {
    "hrsh7th/cmp-buffer",  -- 当前 buffer 中有的 word
    commit = "3022dbc",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {
    "hrsh7th/cmp-path",  -- filepath 补全
    commit = "91ff86c",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {
    "saadparwaiz1/cmp_luasnip",  -- Snippets source for nvim-cmp
    commit = "05a9ab2",
    dependencies = {"L3MON4D3/LuaSnip"},  -- snippets content

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  --- snippet engine, for "cmp_luasnip", 每次打开文件都会有一个 [Scratch] buffer.
  {
    "L3MON4D3/LuaSnip",
    commit = "e808bee",
    --- for placeholder transformation
    --- https://code.visualstudio.com/docs/editor/userdefinedsnippets#_variable-transforms
    build = "make install_jsregexp",
    config = function() require("plugins.settings.luasnip_snippest") end,
    dependencies = {"rafamadriz/friendly-snippets"},  -- snippets content

    lazy = true,  -- cmp_luasnip 加载时自动加载.
  },

  --- snippets content, 自定义 snippets 可以借鉴这个结构.
  {
    "rafamadriz/friendly-snippets",
    -- commit = "00ebcaa",

    lazy = true,  -- LuaSnip 加载时自动加载.
  },

  --- 自动括号, 同时依赖 treesitter && cmp
  {
    "windwp/nvim-autopairs",
    commit = "ee297f2",
    config = function() require("plugins.settings.autopairs") end,
    dependencies = {"hrsh7th/nvim-cmp"},  -- cmp.event:on() 设置.

    event = "InsertEnter",
  },

  --- LSP ------------------------------------------------------------------------------------------
  --- lspconfig && null-ls 两个插件是互相独立的 LSP client, 没有依赖关系.
  --- 官方 LSP 引擎.
  {
    "neovim/nvim-lspconfig",
    -- commit = "d88ae66",
    config = function() require("lsp.plugins.lsp_config") end,  -- NOTE: 如果加载地址为文件夹, 则会寻找文件夹中的 init.lua 文件.
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- lsp 提供的代码补全. NOTE: lspconfig 必须在 cmp_nvim_lsp 之后加载, 否则可能无法提供代码补全.
    },
  },

  --- null-ls 插件 formatters && linters, depends on "nvim-lua/plenary.nvim"
  --- VVI: "jose-elias-alvarez/null-ls.nvim",  -- Archived!!!
  {
    "nvimtools/none-ls.nvim",
    commit = "dcc8cd4",
    config = function() require("lsp.plugins.null_ls") end,
    dependencies = { "nvim-lua/plenary.nvim" },

    event = "VeryLazy",
  },

  {
    "stevearc/conform.nvim",
    tag = "v8.1.0",
    config = function() require("plugins.settings.formatter_conform") end,

    event = "VeryLazy",
  },

  --- File explorer --------------------------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    tag = "v1.7.1",
    config = function() require("plugins.settings.file_tree") end,
    dependencies = { "nvim-tree/nvim-web-devicons" },

    -- VVI: 本文件最后设置: 在 `nvim dir` 直接打开文件夹的时直接加载 nvim-tree.lua.
    event = "VeryLazy",
  },

  {
    "nvim-tree/nvim-web-devicons",
    commit = "19d257c",

    lazy = true, -- dep of nvim-tree & bufferline
  },

  --- Buffer & Status Line -------------------------------------------------------------------------
  --- tabline decorator, `:help 'tabline'`
  {
    "akinsho/bufferline.nvim",
    -- commit = "aa16daf",
    tag = "v4.8.0",
    config = function() require("plugins.settings.decor_bufferline") end,
    dependencies = { "nvim-tree/nvim-web-devicons" },

    event = "VeryLazy",
  },

  --- statusline decorator, `:help 'statusline'`
  {
    "nvim-lualine/lualine.nvim",   -- bottom status line
    commit = "b431d22",
    config = function() require("plugins.settings.decor_lualine") end,

    event = "VeryLazy",
  },

  --- Debug tools 安装 -----------------------------------------------------------------------------
  --- NOTE: dap-ui && dap 设置在同一文件中.
  {
    "mfussenegger/nvim-dap",  -- core debug tool
    commit = "7ff6936",
    config = function() require("plugins.settings.dap_debug") end,

    cmd = {'DapToggleBreakpoint', 'DapContinue', 'DapLoadLaunchJSON'},
  },

  {
    "nvim-neotest/nvim-nio",
    tag = "v1.10.0",

    lazy = true,  -- nvim-dap-ui 加载时自动加载.
  },

  {
    "rcarriga/nvim-dap-ui",  -- ui for "nvim-dap"
    -- tag = "v4.0.0",
    commit = "ffa8983",
    config = function() require("plugins.settings.dapui_debug") end,
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",  -- NOTE: 依赖, 必须安装.
    },

    lazy = true,  -- nvim-dap config 文件中 require dapui.
  },

  --- Useful Tools ---------------------------------------------------------------------------------
  --- 依赖 rg fd, 但不依赖 fzf. 没有 fzf 命令行工具也可以运行.
  --- telescope 的 preview syntax 默认使用的是 treesitter, 如果没有 treesitter 则使用 vim syntax highlights.
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",  -- master branch is nightly version.
    tag = "0.1.8",
    config = function() require("plugins.settings.telescope_fzf") end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",  -- telescope extension
    },

    event = "VeryLazy",
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    commit = "cf48d4d",
    build = "make",

    lazy = true,  -- telescope 加载时自动加载.
  },

  --- Git
  --- NOTE: gitsigns 会检查 "trouble.nvim" 是否安装, 如果有安装则:
  --- `:Gitsigns setqflist/seqloclist` will open Trouble instead of quickfix or location list windows.
  --- https://github.com/lewis6991/gitsigns.nvim#troublenvim
  {
    "lewis6991/gitsigns.nvim",
    commit = "ee7634a",
    -- tag = "v0.9.0",
    config = function() require("plugins.settings.git_signs") end,

    --- NOTE: `nvim dir` 启动时直接打开 dir 时可能会造成 gitsigns 报错. 根据测试情况选择 VeryLazy 或者 BufReadPre ...
    --event = { "BufReadPre", "BufNewFile" },
    event = "VeryLazy",
  },

  --- markdown, VVI: 安装 preview 插件后需要一段时间来执行 vim.fn["mkdp#util#install"]() 如果无法运行可以重装该插件.
  {
    "iamcco/markdown-preview.nvim",
    commit = "a923f5f",
    --- VVI: 每次 Update 后需要重新执行 vim.fn["mkdp#util#install"](), 否则可能出现无法运行的情况.
    build = function() vim.fn["mkdp#util#install"]() end,

    --- NOTE: 无法使用 cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" }, 作为加载条件.
    ft = {"markdown"},  -- markdown-preview 加载时间 < 1ms
  },

  --- https://docs.github.com/en/copilot/getting-started-with-github-copilot
  -- {
  --   "github/copilot.vim",
  --   tag = "v1.22.0",
  --   -- config = function()  --- {{{
  --   --   --- VVI: `:help g:copilot_node_command`, using node@18 or above.
  --   --   --- 安装指定的 nodejs 版本. `brew install node@20`
  --   --   local node_path = "/opt/homebrew/opt/node@20/bin/node"
  --   --
  --   --   --- check node cmd existence
  --   --   if not vim.uv.fs_stat(node_path) then
  --   --     Notify({"'" .. node_path .. "' is NOT Exist."}, "WARN", {title = "github/copilot", timeout = false})
  --   --     return
  --   --   end
  --   --
  --   --   vim.g.copilot_node_command = node_path
  --   -- end,
  --   -- -- }}}
  --
  --   cmd = {"Copilot"},  -- `:Copilot setup`, `:Copilot enable`, `:help copilot` 查看可用命令.
  -- },

  --- recommanded plugins ------------------------------------------------------ {{{
  --- null-ls 替代:
  --{"mfussenegger/nvim-lint"}, -- linter
  --{"stevearc/conform.nvim"},  -- formatter

  --{"kyazdani42/nvim-web-devicons"}, -- Nerd Fonts 提供 icons 需要 patch 字体
  --{"nvim-neo-tree/neo-tree.nvim"},  -- File explorer. nvim-tree.lua 替代
  --{"Tastyep/structlog.nvim"},   -- log 工具
  --{"folke/trouble.nvim"},       -- quickfix/loclist 替代
  --{"rebelot/heirline.nvim"},    -- lualine + bufferline 替代
  --{"willothy/nvim-cokeline"},   -- bufferline 替代
  --{"akinsho/toggleterm.nvim"},  -- terminal
  --{"preservim/tagbar"},  -- universal-ctags, 用的少. https://github.com/universal-ctags/ctags/blob/master/docs/news.rst#new-parsers

  --{"goolord/alpha-nvim"}, {"goolord/alpha-nvim"},  -- neovim 启动页面
  --{"ahmedkhalf/project.nvim"},  -- project manager

  --{"p00f/nvim-ts-rainbow"}, -- rainbow 括号颜色, treesitter 插件. NOTE: 严重拖慢文件打开速度.
  --{"hrsh7th/cmp-cmdline"},  -- 自动补全 cmd. nvim-cmp 插件. NOTE: 不好用.
  -- -- }}}
}

--- lazy.nvim settings
local lazy = require('lazy')
local opts = {
  root = lazydir, -- directory where plugins will be installed
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json", -- lockfile generated after running update.
  defaults = {
    lazy = false, -- should plugins be lazy-loaded?
  },
  rocks = {
    enabled = false, -- luarocks disabled.
  },
  ui = {
    size = { width = 0.6, height = 0.9 },
    border = Nerd_icons.border,
    icons = {
      list = { "●", "→", "★", "‒" }
    },
  },
}

--- NOTE: 用于批量检查 plugins 升级
-- for _, p in ipairs(plugins) do
--   p.commit = nil
--   p.tag, p.version = nil, nil
-- end

lazy.setup(plugins, opts)

--- `nvim dir` 打开文件夹时直接加载 nvim-tree.lua, `nvim file` 打开 file 时不加载 nvim-tree.lua, 通过快捷键加载.
--- VVI: 这里只能使用 BufWinEnter, 不能使用 BufEnter.
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  pattern = {"*"},
  once = true,
  callback = function (params)
    local finfo = vim.uv.fs_stat(vim.api.nvim_buf_get_name(params.buf))
    if finfo and finfo.type == 'directory' then
      lazy.load({plugins = {"nvim-tree.lua"}})
    end
  end,
  desc = "Lazy: load nvim-tree.lua on condition",
})



