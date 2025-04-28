--- lazy 主要是一个 安装/管理插件. `:help lazy.nvim.txt`
--- bootstrap -------------------------------------------------------------------------------------- {{{
local lazydir = vim.fn.stdpath("data") .. "/lazy"
local lazypath = lazydir .. "/lazy.nvim"
local lazyrepo = "https://github.com/folke/lazy.nvim.git"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
  end
end
vim.opt.rtp:prepend(lazypath)
-- -- }}}

--- `nvim dir` 打开文件夹时直接加载 nvim-tree.lua, `nvim file` 打开 file 时不加载 nvim-tree.lua, 通过快捷键加载.
local isfile = true
local finfo = vim.uv.fs_stat(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
if finfo and finfo.type == 'directory' then
  isfile = false
end

--- `:help lazy.nvim`
--- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/editor.lua
--- 如果插件被 require(xxx) or pcall(require, xxx) 会马上加载.
local plugins = {
  {
    "folke/lazy.nvim",
    -- version = "*",  -- 相当于 tag='stable'
    tag = "v11.17.1",
  },

  --- Performence & Functions ----------------------------------------------------------------------
  {
    "nvim-lua/plenary.nvim",
    commit = "857c5ac",
    priority = 1000,  -- 只在 lazy=false 的情况下有效. 影响加载顺序, 默认值为 50.
  },

  {
    "williamboman/mason.nvim",
    tag = "v1.11.0",
    -- build = ":MasonUpdate", -- :MasonUpdate updates All Registries, NOT packages.
    config = function() require("plugins.settings.mason_tool_installer") end,

    --- VVI: 需要在 $PATH 或者 vim.env.PATH 中加入 mason.setup({ "install_root_dir" }) 路径,
    --- 否则不能延迟加载 mason, 需要设置下面的 priority.
    priority = 999,
  },

  {
    "rcarriga/nvim-notify",
    commit = "b5825cf",
    -- tag = "v3.15.0",
    config = function() require("plugins.settings.nvim_notify") end,

    event = "VeryLazy",
  },

  {
    "folke/which-key.nvim",
    -- commit = "68e37e1",
    tag = "v3.17.0",
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
    -- commit = "d22166e",
    config = function() require("plugins.settings.treesitter") end,
  },

  --- 第一方 module 插件 ---
  {
    "nvim-treesitter/nvim-treesitter-context",  -- 顶部显示 cursor 所在 function 的定义.
    config = function() require("plugins.settings.treesitter_ctx") end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },

    event = "VeryLazy",
  },

  --- 第三方 plugin 需要用到 tree-sitter ---
  {
    "windwp/nvim-ts-autotag",  -- auto close tag <div></div>
    commit = "a1d526a",
    config = function() require("plugins.settings.treesitter_autotag") end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },

    event = "InsertEnter",
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    tag = "v3.9.0",
    config = function() require("plugins.settings.indentline") end,  -- setup() 设置 use_treesitter = true
    dependencies = {"nvim-treesitter/nvim-treesitter"},  -- for setup({scope})

    event = "VeryLazy",
  },

  --- Auto Completion ------------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    commit = "b5311ab",
    config = function() require("plugins.settings.cmp_completion") end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- lsp 提供的代码补全
      "hrsh7th/cmp-buffer",  -- 当前 buffer 中有的 word
      "hrsh7th/cmp-path",  -- filepath 补全
      "hrsh7th/cmp-cmdline", -- command and search 补全

      "saadparwaiz1/cmp_luasnip",  -- snippets
    },

    event = { "InsertEnter", "CmdlineEnter" },
  },

  --- 以下是 "nvim-cmp" 的 module 插件, 在 nvim-cmp.setup() 中启用的插件.
  --- VVI: 只有 "cmp-nvim-lsp" 不需要在 "nvim-cmp" 之后加载, 其他 module 插件都需要在 "nvim-cmp" 加载之后再加载, 否则报错.
  {
    "hrsh7th/cmp-nvim-lsp",  -- LSP source for nvim-cmp
    commit = "a8912b8",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {
    "hrsh7th/cmp-buffer",  -- 当前 buffer 中有的 word
    commit = "b74fab3",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {
    "hrsh7th/cmp-path",  -- filepath 补全
    commit = "c6635aa",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {
    "hrsh7th/cmp-cmdline",
    commit = "d250c63",

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {
    "saadparwaiz1/cmp_luasnip",  -- Snippets source for nvim-cmp
    commit = "98d9cb5",
    dependencies = {"L3MON4D3/LuaSnip"},  -- snippets content

    lazy = true,  -- nvim-cmp 加载时自动加载.
  },

  {
    "L3MON4D3/LuaSnip", -- snippet engine, for "cmp_luasnip", 会创建几个 [Scratch] buffer
    commit = "c9b9a22",
    --- for placeholder transformation
    --- https://code.visualstudio.com/docs/editor/userdefinedsnippets#_variable-transforms
    build = "make install_jsregexp",
    config = function() require("plugins.settings.luasnip_snippest") end,
    dependencies = {"rafamadriz/friendly-snippets"},  -- snippets content

    lazy = true,  -- cmp_luasnip 加载时自动加载.
  },

  {
    "rafamadriz/friendly-snippets",

    lazy = true,  -- LuaSnip 加载时自动加载.
  },

  {
    "windwp/nvim-autopairs",
    commit = "4d74e75",
    config = function() require("plugins.settings.autopairs") end,
    dependencies = {"hrsh7th/nvim-cmp"},  -- cmp.event:on() 设置.

    event = "InsertEnter",
  },

  --- LSP ------------------------------------------------------------------------------------------
  --- lspconfig && null-ls 两个插件是互相独立的 LSP client, 没有依赖关系.
  {
    "neovim/nvim-lspconfig",  -- 官方 LSP 引擎
    -- commit = "d88ae66",
    config = function() require("lsp.plugins.lsp_config") end,
    dependencies = {
      -- VVI: lspconfig 必须在 cmp_nvim_lsp 之后加载, 否则可能无法提供代码补全.
      "hrsh7th/cmp-nvim-lsp",
    },
  },

  --- "jose-elias-alvarez/null-ls.nvim",  -- Archived!!!
  {
    "nvimtools/none-ls.nvim",
    commit = "b3dfc91",
    config = function() require("lsp.plugins.null_ls") end,
    dependencies = { "nvim-lua/plenary.nvim" },

    event = "VeryLazy",
  },

  {
    "stevearc/conform.nvim",
    -- tag = "v9.0.0",
    commit = "372fc52",
    config = function() require("plugins.settings.formatter_conform") end,

    event = "BufWritePre",
    cmd = {"Format", "FormatEnable", "FormatDisable"}
  },

  --- File explorer --------------------------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    tag = "v1.12.0",
    config = function() require("plugins.settings.file_tree") end,
    dependencies = { "nvim-tree/nvim-web-devicons" },

    -- VVI: 本文件最后设置: 在 `nvim dir` 直接打开文件夹的时直接加载 nvim-tree.lua.
    keys = {
      {'<leader>;', '<cmd>NvimTreeToggle<CR>', desc='filetree: toggle' },
      {'<leader><CR>', '<cmd>NvimTreeFindFile!<CR>', desc='filetree: jump to file' },
    },

    --- `nvim dir` 打开文件夹时直接加载 nvim-tree.lua,
    --- `nvim file` 打开 file 时不加载 nvim-tree.lua, 通过快捷键加载.
    lazy = isfile,
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true, -- dep of nvim-tree & bufferline
  },

  --- Buffer & Status Line -------------------------------------------------------------------------
  {
    "akinsho/bufferline.nvim",  -- `:help 'tabline'`
    tag = "v4.9.1",
    config = function() require("plugins.settings.decor_bufferline") end,
    dependencies = { "nvim-tree/nvim-web-devicons" },

    event = "VeryLazy",
  },

  {
    "nvim-lualine/lualine.nvim",  -- `:help 'statusline'`
    commit = "15884ce",
    config = function() require("plugins.settings.decor_lualine") end,

    event = "VeryLazy",
  },

  --- Debug tools 安装 -----------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",  -- core debug tool
    commit = "8df427a",
    config = function() require("plugins.settings.debug.nvim_dap") end,

    cmd = {'Debug', 'DapToggleBreakpoint', 'DapContinue'},
    keys = {
      {'<F9>', '<cmd>DapToggleBreakpoint<CR>', desc = "Fn 9: debug: Toggle Breakpoint"},
    },
  },

  {
    "nvim-neotest/nvim-nio",
    tag = "v1.10.1",

    lazy = true,  -- nvim-dap-ui 加载时自动加载.
  },

  {
    "rcarriga/nvim-dap-ui",  -- ui for "nvim-dap"
    -- tag = "v4.0.0",
    commit = "73a26ab",
    config = function() require("plugins.settings.debug.nvim_dapui") end,
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",  -- 依赖, 必须安装.
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
      "nvim-telescope/telescope-fzf-native.nvim", -- telescope extension
      "nvim-telescope/telescope-ui-select.nvim",  -- ui
    },

    event = "VeryLazy",
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    commit = "1f08ed6",
    build = "make",

    lazy = true,  -- telescope 加载时自动加载.
  },

  {
    "nvim-telescope/telescope-ui-select.nvim",
    commit = "6e51d7d",

    lazy = true,  -- telescope 加载时自动加载.
  },

  --- Git
  --- NOTE: gitsigns 会检查 "trouble.nvim" 是否安装, 如果有安装则:
  --- `:Gitsigns setqflist/seqloclist` will open Trouble instead of quickfix or location list windows.
  --- https://github.com/lewis6991/gitsigns.nvim#troublenvim
  {
    "lewis6991/gitsigns.nvim",
    -- tag = "v1.0.2",
    commit = "9cd665f",
    config = function() require("plugins.settings.git_signs") end,

    --- `nvim dir` 启动时直接打开 dir 时可能会造成 gitsigns 报错.
    --- 根据测试情况选择 VeryLazy 或者 BufReadPre, BufNewFile ...
    event = "VeryLazy",
  },

  --- markdown, VVI: 安装 preview 插件后需要一段时间来执行 vim.fn["mkdp#util#install"]() 如果无法运行可以重装该插件.
  {
    "iamcco/markdown-preview.nvim",
    commit = "a923f5f",
    --- VVI: 每次 Update 后需要重新执行 `lua vim.fn["mkdp#util#install"]()` or `call mkdp#util#install()`
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()
      local css_path = vim.fn.stdpath("config") .. "/lua/plugins/settings/my_markdown.css"
      if vim.uv.fs_stat(css_path) then
        vim.g.mkdp_markdown_css = css_path
      end
    end,

    --- NOTE: 无法使用 cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" }, 作为加载条件.
    ft = {"markdown"},  -- markdown-preview 加载时间 < 1ms
  },

  {
    "folke/trouble.nvim",
    tag = "v3.7.1",
    config = function() require("plugins.settings.trouble_list") end,

    event = "VeryLazy",
  },

  --- https://docs.github.com/en/copilot/getting-started-with-github-copilot
  {
    "github/copilot.vim",
    config = function()  --- {{{
      --- VVI: `:help g:copilot_node_command`, using node@18 or above.
      --- 安装指定的 nodejs 版本. `brew install node@20`
      local node_path = "/opt/homebrew/opt/node@20/bin/node"

      --- check node cmd existence
      if not vim.uv.fs_stat(node_path) then
        Notify({"'" .. node_path .. "' is NOT Exist."}, "WARN", {title = "github/copilot", timeout = false})
        return
      end

      vim.g.copilot_node_command = node_path
    end,
    -- }}}

    cmd = { "Copilot" },  -- `:Copilot setup`, `:Copilot enable`, `:help copilot` 查看可用命令.
  },

  --- https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat-v2.lua
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    tag = "v3.11.1",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function() require("plugins.settings.ai_copilotchat") end,

    cmd = { "CopilotChat" },
  },

  --- recommanded plugins ------------------------------------------------------ {{{
  --{"mfussenegger/nvim-lint"}, -- linter
  -- {
  --   "ibhagwan/fzf-lua",
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  --   config = function()
  --     require('fzf-lua').setup({
  --       fzf_opts = {
  --         ["--no-header"] = true,  -- zshrc 中设置了 header, 这里取消.
  --         -- ["--header"] = "ABC",
  --       },
  --     })
  --     --- change default UI `:help vim.ui.select`
  --     require('fzf-lua').register_ui_select()
  --   end,
  -- },

  --{"nvim-neo-tree/neo-tree.nvim"},  -- File explorer. nvim-tree.lua 替代
  --{"Tastyep/structlog.nvim"},   -- log 工具
  --{"rebelot/heirline.nvim"},    -- lualine + bufferline 替代
  --{"willothy/nvim-cokeline"},   -- bufferline 替代
  --{"akinsho/toggleterm.nvim"},  -- terminal

  --{"goolord/alpha-nvim"},  -- neovim 启动页面
  --{"ahmedkhalf/project.nvim"},  -- project manager

  --{"p00f/nvim-ts-rainbow"}, -- rainbow 括号颜色, treesitter 插件. NOTE: 严重拖慢文件打开速度.
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
  install = {
    missing = false, -- auto install missing plugins
  },
  ui = {
    size = { width = 0.6, height = 0.75 },
    border = {"","▄","","","","▀","",""},
    icons = {
      list = { "★", "●", "○", "→" }
    },
  },
}

--- NOTE: 用于批量检查 plugins 升级
-- for _, p in ipairs(plugins) do
--   p.commit = nil
--   p.tag, p.version = nil, nil
-- end

lazy.setup(plugins, opts)



