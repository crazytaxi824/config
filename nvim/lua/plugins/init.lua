--- lazy 主要是一个 plugin 安装/管理插件. `:help lazy.nvim.txt`
--- bootstrap -------------------------------------------------------------------------------------- {{{
local lazydir = vim.fn.stdpath("data") .. "/lazy"
local lazypath = lazydir .. "/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    Notify(vim.trim(result), "ERROR")
    return
  end
end
vim.opt.rtp:prepend(lazypath)
-- -- }}}

--- 插件设置
--- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/editor.lua
--- NOTE: 如果插件被 require(xxx) or pcall(require, xxx) 会马上加载.
local plugins = {
  { "folke/lazy.nvim",
    --- install the latest stable version of plugins that support Semver.
    -- version = "*",  -- 相当于 tag='stable'
    tag = "v10.17.0",
  },

  --- Performence & Functions ----------------------------------------------------------------------
  --- Useful lua functions used by lots of plugins
  {"nvim-lua/plenary.nvim",
    priority = 1000,  -- 影响加载顺序, 默认值为 50.
    commit = "f7adfc4",
  },

  --- 通知功能
  {"rcarriga/nvim-notify",
    tag = "v3.13.4",
    config = function() require("plugins.settings.nvim_notify") end,

    event = "VeryLazy",
  },

  --- 安装 & 管理 lsp/formatter/linter/dap-debug tools 的插件
  {"williamboman/mason.nvim",
    tag = "v1.10.0",
    build = ":MasonUpdate", -- :MasonUpdate updates All Registries, NOT packages.
    config = function() require("plugins.settings.mason_tool_installer") end,
    --- NOTE: 不能 lazyload mason, 否则其他插件无法找到 mason 安装的工具.
  },

  --- 快捷键提醒功能, key mapping 的时候需要注册到 which-key
  {"folke/which-key.nvim",
    -- tag = "v1.6.0",
    commit = "4433e5e",
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
  {"nvim-treesitter/nvim-treesitter",
    commit = "3ae78f3",  -- NOTE: tag 更新太慢, 建议两周更新一次.
    --build = ":TSUpdate",  -- NOTE: 推荐手动执行, 批量自动安装 parser 容易卡死.
    config = function() require("plugins.settings.treesitter") end,
    dependencies = {
      --- 以下都是 treesitter modules 插件, 在 setup() 中启用的插件.
      "nvim-treesitter/nvim-treesitter-context",  -- 顶部显示 cursor 所在 function 的定义.
      "windwp/nvim-ts-autotag",  -- auto close tag <div></div>
    },

    event = "VeryLazy",
  },

  --- 第一方 module 插件 ---
  {"nvim-treesitter/nvim-treesitter-context",  -- 顶部显示 cursor 所在 function 的定义.
    commit = "b8b7e52",
    config = function() require("plugins.settings.treesitter_ctx") end,

    lazy = true,  -- nvim-treesitter 加载时自动加载.
  },

  --- 第三方 module 插件 ---
  {"windwp/nvim-ts-autotag",  -- auto close tag <div></div>
    commit = "531f483",

    lazy = true,  -- nvim-treesitter 加载时自动加载.
  },

  --- 以下是使用了 treesitter 功能的插件. (这些插件也可以不使用 treesitter 的功能)
  --- 注释
  {"JoosepAlviste/nvim-ts-context-commentstring", -- Comment 依赖 commentstring.
    commit = "7ab799a",
    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,

    lazy = true,  -- nvim-treesitter 加载时自动加载.
  },

  {"numToStr/Comment.nvim",
    commit = "0236521",
    config = function() require("plugins.settings.comment") end,
    dependencies = {"JoosepAlviste/nvim-ts-context-commentstring"},  -- https://github.com/numToStr/Comment.nvim#-hooks

    keys = {
      --- VVI: alacritty 中已将 <Command + /> 映射为以下组合键. 可以通过 `cat -v` 查看.
      {'<M-/>', '<Plug>(comment_toggle_linewise_current)',      mode = 'n', desc = 'Comment current line'},
      {'<M-/>', '<C-o><Plug>(comment_toggle_linewise_current)', mode = 'i', desc = 'Comment current line'},
      {'<M-/>', '<Plug>(comment_toggle_linewise_visual)',       mode = 'v', desc = 'Comment Visual selected'},
    },
  },

  --- indent line
  {"lukas-reineke/indent-blankline.nvim",
    tag = "v3.5.4",
    config = function() require("plugins.settings.indentline") end,  -- setup() 设置 use_treesitter = true
    dependencies = {"nvim-treesitter/nvim-treesitter"},  -- for setup({scope})

    event = "VeryLazy",
  },

  --- Auto Completion ------------------------------------------------------------------------------
  {"hrsh7th/nvim-cmp",
    commit = "04e0ca3",
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
  {"hrsh7th/cmp-nvim-lsp",  -- LSP source for nvim-cmp
    commit = "5af77f5",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {"hrsh7th/cmp-buffer",  -- 当前 buffer 中有的 word
    commit = "3022dbc",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {"hrsh7th/cmp-path",  -- filepath 补全
    commit = "91ff86c",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {"saadparwaiz1/cmp_luasnip",  -- Snippets source for nvim-cmp
    commit = "05a9ab2",
    dependencies = {"L3MON4D3/LuaSnip"},  -- snippets content

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  --- snippet engine, for "cmp_luasnip", 每次打开文件都会有一个 [Scratch] buffer.
  {"L3MON4D3/LuaSnip",
    commit = "a7a4b46",
    build = "make install_jsregexp",  -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#transformations
    config = function() require("plugins.settings.luasnip_snippest") end,
    dependencies = {"rafamadriz/friendly-snippets"},  -- snippets content

    lazy = true,  -- cmp_luasnip 加载时自动加载.
  },

  --- snippets content, 自定义 snippets 可以借鉴这个结构.
  {"rafamadriz/friendly-snippets",
    commit = "dcd4a58",

    lazy = true,  -- LuaSnip 加载时自动加载.
  },

  --- 自动括号, 同时依赖 treesitter && cmp
  {"windwp/nvim-autopairs",
    commit = "c6139ca",
    config = function() require("plugins.settings.autopairs") end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",  -- setup() 中 `check_ts`, `ts_config` 需要 treesitter 支持.
      "hrsh7th/nvim-cmp",  -- cmp.event:on() 设置.
    },

    event = "InsertEnter",
  },

  --- LSP ------------------------------------------------------------------------------------------
  --- lspconfig && null-ls 两个插件是互相独立的 LSP client, 没有依赖关系.
  --- 官方 LSP 引擎.
  {"neovim/nvim-lspconfig",
    commit = "4bdd380",
    config = function() require("lsp.lsp_config") end,  -- NOTE: 如果加载地址为文件夹, 则会寻找文件夹中的 init.lua 文件.
    dependencies = {
      "williamboman/mason.nvim",  -- 安装 lsp 命令行工具.
      "hrsh7th/cmp-nvim-lsp",  -- lsp 提供的代码补全. NOTE: lspconfig 必须在 cmp_nvim_lsp 之后加载, 否则可能无法提供代码补全.
    },
  },

  --- null-ls 插件 formatters && linters, depends on "nvim-lua/plenary.nvim"
  {"jose-elias-alvarez/null-ls.nvim",
    commit = "0010ea9",  -- Archived!!!
    config = function() require("lsp.null_ls") end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "williamboman/mason.nvim",  -- 安装 linter/formatter 命令行工具. eg: shfmt, stylua ...
    },

    event = "VeryLazy",
  },

  --- File explorer --------------------------------------------------------------------------------
  {"kyazdani42/nvim-tree.lua",
    tag = "v1.1",
    config = function() require("plugins.settings.file_tree") end,

    -- VVI: 本文件最后设置: 在 `nvim dir` 直接打开文件夹的时直接加载 nvim-tree.lua.
    event = "VeryLazy",
  },

  --- Buffer & Status Line -------------------------------------------------------------------------
  --- tabline decorator, `:help 'tabline'`
  {"akinsho/bufferline.nvim",
    tag = "v4.5.2",
    config = function() require("plugins.settings.decor_bufferline") end,

    event = "VeryLazy",
  },

  --- statusline decorator, `:help 'statusline'`
  {"nvim-lualine/lualine.nvim",   -- bottom status line
    commit = "26dac2f",
    config = function() require("plugins.settings.decor_lualine") end,

    event = "VeryLazy",
  },

  --- Debug tools 安装 -----------------------------------------------------------------------------
  --- NOTE: dap-ui && dap 设置在同一文件中.
  {"mfussenegger/nvim-dap",  -- core debug tool
    -- tag = "0.7.0",
    commit = "fc880e8",
    dependencies = {"williamboman/mason.nvim"},  -- install dap-debug tools. eg: 'delve'

    lazy = true,  -- nvim-dap-ui 加载时自动加载.
  },

  {"rcarriga/nvim-dap-ui",  -- ui for "nvim-dap"
    -- tag = "v3.9.3",
    commit = "9720eb5",
    config = function() require("plugins.settings.dap_debug") end,  -- dap-ui && dap 设置在同一文件中.
    dependencies = {"mfussenegger/nvim-dap"},

    cmd = {'DapToggleBreakpoint', 'DapContinue', 'DapLoadLaunchJSON'},
  },

  --- Useful Tools ---------------------------------------------------------------------------------
  --- 依赖 rg fd, 但不依赖 fzf. 没有 fzf 命令行工具也可以运行.
  --- telescope 的 preview syntax 默认使用的是 treesitter, 如果没有 treesitter 则使用 vim syntax highlights.
  {"nvim-telescope/telescope.nvim",
    branch = "0.1.x",  -- master branch is nightly version.
    tag = "0.1.6",
    config = function() require("plugins.settings.telescope_fzf") end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",  -- telescope extension
    },

    event = "VeryLazy",
  },

  { "nvim-telescope/telescope-fzf-native.nvim",
    commit = "9ef21b2",
    build = "make",

    lazy = true,  -- telescope 加载时自动加载.
  },

  --- Git
  --- NOTE: gitsigns 会检查 "trouble.nvim" 是否安装, 如果有安装则:
  --- `:Gitsigns setqflist/seqloclist` will open Trouble instead of quickfix or location list windows.
  --- https://github.com/lewis6991/gitsigns.nvim#troublenvim
  {"lewis6991/gitsigns.nvim",
    commit = "4e34864",
    config = function() require("plugins.settings.git_signs") end,

    --- NOTE: `nvim dir` 启动时直接打开 dir 时可能会造成 gitsigns 报错. 根据测试情况选择 VeryLazy 或者 BufReadPre ...
    --event = { "BufReadPre", "BufNewFile" },
    event = "VeryLazy",
  },

  --- markdown, VVI: 安装 preview 插件后需要一段时间来执行 vim.fn["mkdp#util#install"]() 如果无法运行可以重装该插件.
  {"iamcco/markdown-preview.nvim",
    commit = "a923f5f",
    --- VVI: 每次 Update 后需要重新执行 vim.fn["mkdp#util#install"](), 否则可能出现无法运行的情况.
    build = function() vim.fn["mkdp#util#install"]() end,

    --- NOTE: 无法使用 cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" }, 作为加载条件.
    ft = {"markdown"},  -- markdown-preview 加载时间 < 1ms
  },

  --- https://docs.github.com/en/copilot/getting-started-with-github-copilot
  -- {"github/copilot.vim",
  --   tag = "v1.22.0",
  --   -- config = function()  --- {{{
  --   --   --- VVI: `:help g:copilot_node_command`, using node@18 or above.
  --   --   --- 安装指定的 nodejs 版本. `brew install node@20`
  --   --   local node_path = "/opt/homebrew/opt/node@20/bin/node"
  --   --
  --   --   --- check node cmd existence
  --   --   if vim.fn.filereadable(node_path) == 0 then
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
  ui = {  ---------------------------------------------------------------------- {{{
    size = { width = 0.6, height = 0.9 },
    border = {"▄","▄","▄","█","▀","▀","▀","█"},
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
    if vim.fn.isdirectory(vim.api.nvim_buf_get_name(params.buf)) == 1 then
      lazy.load({plugins = {"nvim-tree.lua"}})
    end
  end,
  desc = "Lazy: load nvim-tree.lua on condition",
})



