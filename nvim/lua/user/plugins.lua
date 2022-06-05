-- Packer.nvim 设置 -------------------------------------------------------------------------------- {{{
-- https://github.com/wbthomason/packer.nvim#specifying-plugins
--
-- opt 属性:
--   当 plugin 有加载条件的时候, plugin 的安装地址会从 ~/.local/share/nvim/site/pack/packer/start -> opt
--   plugin 的 opt 属性会被改为 true, `:PackerStatus`
--
-- use {
--   'myusername/example',        -- The plugin location string
--
--   disable = boolean,           -- Mark a plugin as inactive
--   as = string,                 -- VVI: 别名
--   installer = function,        -- Specifies custom installer. See "custom installers" below.
--   updater = function,          -- Specifies custom updater. See "custom installers" below.
--   after = string or list,      -- 在加载指定 plugin 后, 加载自己.
--                                -- NOTE: after 插件名只写最后一部分, eg: after = "nvim-cmp", VVI: 不要写 after = "hrsh7th/nvim-cmp"
--   rtp = string,                -- Specifies a subdirectory of the plugin to add to runtimepath.
--   opt = boolean,               -- Manually marks a plugin as optional.
--
--   -- 固定 plugin 版本
--   branch = string,             -- VVI: Specifies a git branch to use
--   tag = string,                -- VVI: Specifies a git tag to use. Supports '*' for "latest tag"
--   commit = string,             -- VVI: Specifies a git commit to use
--   lock = boolean,              -- VVI: Skip updating this plugin in updates/syncs. Still cleans.
--
--   run = string, function, or table, -- VVI: UPDATE 之后执行, 不是 loaded. 类似 vim-plug { 'do' }
--   requires = string or list,   -- VVI: 会先加载 requires 中的 plugin. requires 插件名需要写全名, requires = "hrsh7th/nvim-cmp"
--   config = string or function, -- VVI: after plugin loaded. `config = function() ... end`,
--   rocks = string or list,      -- Specifies `Luarocks` dependencies for the plugin
--   -- NOTE: The `setup` implies `opt = true`
--   setup = string or function,  -- VVI: Specifies code to run before this plugin is loaded.
--
--   -- NOTE: The following keys all imply `lazy-loading` and imply `opt = true`
--   -- plugin 加载条件.
--   cmd = string or list,        -- Specifies commands which load this plugin. Can be an autocmd pattern.
--   ft = string or list,         -- VVI: 指定 filetype 加载插件.
--                                -- BUG 使用 ft 后, after/syntax, after/ftplugin 中的文件会被读取两次. 不推荐使用.
--                                -- FIXME https://github.com/wbthomason/packer.nvim/issues/648
--   keys = string or list,       -- Specifies maps which load this plugin. See "Keybindings".
--   event = string or list,      -- Specifies autocommand events which load this plugin.
--   fn = string or list          -- Specifies functions which load this plugin.
--   cond = string, function, or list of strings/functions,   -- Specifies a conditional test to load this plugin
--   module = string or list      -- Specifies Lua module names for require. When requiring a string which starts
--                                -- with one of these module names, the plugin will be loaded.
--   module_pattern = string/list -- Specifies Lua pattern of Lua module names for require. When
--   requiring a string which matches one of these patterns, the plugin will be loaded.
-- }
--
-- Packer 命令
-- `:PackerCompile`    -- Regenerate compiled loader file
-- `:PackerClean`      -- Remove any disabled or unused plugins
-- `:PackerInstall`    -- Clean, then install missing plugins
-- `:PackerUpdate`     -- Clean, then update and install plugins
--
-- `:PackerSnapshot foo`     -- 创建一个 snapshot
-- `:PackerSnapshotDelete foo`  -- 删除一个 snapshot
-- `:PackerSnapshotRollback foo`  -- 回滚到指定 snapshot
--
-- `:PackerSync`       -- NOTE: 使用这一个命令就够了. Perform `PackerUpdate` and then `PackerCompile`
-- NOTE: You must run this or `PackerSync` whenever you make changes to your plugin configuration.

-- -- }}}

--- VVI: Only required if you have packer configured as `opt`
--vim.cmd [[packadd packer.nvim]]  -- 在 stdpath('cache') 中创建 "packer.nvim" 文件夹

--- save plugins.lua 时自动运行 `:PackerSync` 命令. --- {{{
--- NOTE: 这里的文件名是 plugins.lua, 是本文件的文件名.
-- vim.cmd [[
--  augroup packer_user_config
--    autocmd!
--    autocmd BufWritePost plugins.lua source <afile> | PackerSync
--  augroup end
-- ]]
-- -- }}}

--- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

--- Have packer use a popup window, "nvim-lua/popup.nvim"
packer.init {
  --snapshot = nil,   -- VVI: Name of the snapshot you would like to load at startup
  snapshot_path = vim.fn.stdpath('config') .. '/packer_snapshot', -- Default save directory for snapshots
  display = {
    open_fn = function()
      -- Packer 面板 border 样式.
      -- return require("packer.util").float { border = "single" }  -- `:help nvim_open_win()`
      return require("packer.util").float { border = {"▄","▄","▄","█","▀","▀","▀","█"} }  -- `:help nvim_open_win()`
    end,
  },
}

--- NOTE: Install plugins here
--- 官方文档 https://github.com/wbthomason/packer.nvim
--- 插件推荐 https://github.com/LunarVim/Neovim-from-scratch/ -> lua/user/plugins.lua
--- `:echo stdpath("data")` == "~/.local/share/nvim"
--- 插件的安装位置在 "~/.local/share/nvim/site/pack/packer/start/..."
--- `:PackerSync` - install / update / clean 插件包.
return packer.startup(function(use)
  use "wbthomason/packer.nvim" -- Have packer manage itself

  --- Performence & Functions ----------------------------------------------------------------------
  use "lewis6991/impatient.nvim"  -- 加快 lua module 加载时间, 生成 ~/.cache/nvim/luacache_chunks & luacache_modpaths
  use "nvim-lua/plenary.nvim"     -- [必要] Useful lua functions used by lots of plugins
  -- [FIXME] Needed while issue https://github.com/neovim/neovim/issues/12587 is still open
  -- CursorHold and CursorHoldI are blocked by timer_start()
  use "antoinemadec/FixCursorHold.nvim"

  --- Treesitter -----------------------------------------------------------------------------------
  --- NOTE: 下面大部分插件需要在 treesitter.setup() 中启用设置.
  --- Commands for "nvim-treesitter/nvim-treesitter" --- {{{
  --- `:help nvim-treesitter-commands`
  --- `:TSInstallInfo`        -- List all installed languages
  --- `:TSInstall {lang}`     -- Install languages
  --- `:TSUninstall {lang}`   -- Uninstall languages
  --- `:TSUpdate`             -- Update the installed languages
  -- -- }}}
  use {"nvim-treesitter/nvim-treesitter",  -- NOTE: treesitter 主要插件
    run = ":TSUpdate",   -- Post-update/install hook
    requires = {
      --- requests 中都是 treesitter modules 插件, 在 setup() 中启用的插件.
      {"JoosepAlviste/nvim-ts-context-commentstring"}, -- Comment 依赖 commentstring.
      {"windwp/nvim-ts-autotag"},   -- auto close tag <div></div>
      {"p00f/nvim-ts-rainbow"},   -- 括号颜色. treesitter 解析
      {"nvim-treesitter/playground",   -- tree-sitter 插件, 用于获取 tree-sitter 信息, 调整颜色很有用
         cmd = {"TSPlaygroundToggle", "TSHighlightCapturesUnderCursor"},  -- NOTE: 需要时再加载 playground.
      },
    }
  }

  --- 以下是使用了 treesitter 功能的插件. (这些插件也可以不使用 treesitter 的功能)
  use {"numToStr/Comment.nvim",   -- 注释
    requires = {
      "JoosepAlviste/nvim-ts-context-commentstring", -- Comment 依赖 commentstring.
      "nvim-treesitter/nvim-treesitter",
    },
  }

  use {"windwp/nvim-autopairs",   -- 自动括号
    requires = "nvim-treesitter/nvim-treesitter",  -- setup() 中 `check_ts`, `ts_config` 需要 treesitter 支持.
  }

  use {"lukas-reineke/indent-blankline.nvim",  -- identline
    requires = "nvim-treesitter/nvim-treesitter",  -- 设置 vim.g.indent_blankline_use_treesitter = "v:true"
  }

  --- Completion -----------------------------------------------------------------------------------
  use {"hrsh7th/nvim-cmp",         -- 主要的 completion plugin
    -- 以下是 nvim-cmp 的组件.
    requires = {
      "hrsh7th/cmp-nvim-lsp",      -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",        -- buffer completions
      "hrsh7th/cmp-path",          -- path completions
      {"saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
        requires = {
          {"L3MON4D3/LuaSnip",     -- snippet engine, for "cmp_luasnip"
          requires = "rafamadriz/friendly-snippets"},  -- snippets content, 自定义 snippets 可以借鉴这个结构.
        },
      },
      --"hrsh7th/cmp-cmdline",     -- cmdline completions, 不好用.
    },
  }

  --- LSP ------------------------------------------------------------------------------------------
  use "neovim/nvim-lspconfig"            -- enable LSP, 官方 LSP 引擎.
  --- Commands for "williamboman/nvim-lsp-installer" --- {{{
  ---   命令 `:LspInstallInfo` -- 列出所有 lsp, <i>-install | <u>-update | <X>-uninstall
  ---   安装位置 '~/.local/share/nvim/lsp_servers'
  -- -- }}}
  use "williamboman/nvim-lsp-installer"  -- simple to use language server installer
  use "jose-elias-alvarez/null-ls.nvim"  -- for formatters and linters, depends on "nvim-lua/plenary.nvim"

  --- File Tree Display ----------------------------------------------------------------------------
  --use "kyazdani42/nvim-web-devicons"  -- 提供 icons 需要 patch 字体 (Nerd Fonts)
  use "kyazdani42/nvim-tree.lua"  -- 类似 NerdTree

  --- Buffer & Status Line -------------------------------------------------------------------------
  -- vim-fugitive: airline 中显示 git 状态
  use {"vim-airline/vim-airline", requires="tpope/vim-fugitive"}
  --- TODO 以下插件可以替代 airline --- {{{
  --use "akinsho/bufferline.nvim"     -- top buffer list
  --use "nvim-lualine/lualine.nvim"   -- bottom status line
  --use "moll/vim-bbye"               -- better :Bdelete & :Bwipeout
  -- }}}

  --- Debug tools 安装 -----------------------------------------------------------------------------
  --- VimspectorInstall! delve | :VimspectorUpdate!
  --- delve 安装位置 vimspector_base_dir=~/.local/share/nvim/site/pack/packer/start/vimspector/gadgets/macos/...
  --- https://github.com/puremourning/vimspector
  --- https://pepa.holla.cz/2021/03/01/golang-debugging-application-in-neovim/
  use {"puremourning/vimspector"}    -- Debug Tool.
  --use "mfussenegger/nvim-dap"   -- lua debug tool

  --- Useful Tools ---------------------------------------------------------------------------------
  use {"nvim-telescope/telescope.nvim",  -- fzf rg fd, preview 使用的是 tree-sitter, 而不用 bat 了
    requires="nvim-lua/plenary.nvim",
  }
  use "akinsho/toggleterm.nvim"       -- terminal
  use "folke/which-key.nvim"          -- 快捷键提醒功能, key mapping 的时候需要注册到 which-key
  use "rcarriga/nvim-notify"          -- 通知功能

  --- tagbar --- {{{
  --- 函数/类型列表，需要安装 Universal Ctags - `brew info universal-ctags`, 注意不要安装错了.
  --- https://github.com/universal-ctags/ctags/blob/master/docs/news.rst#new-parsers
  --- `ctags --list-languages` 查看支持的语言. 不支持 jsx/tsx, 支持 typescript, 勉强支持 javascript
  -- -- }}}
  use "preservim/tagbar"

  --- markdown preview
  use {"iamcco/markdown-preview.nvim",
    -- VVI: Update 后需要重新安装 preview 插件, 否则可能出现无法运行的情况.
    run = function() vim.fn["mkdp#util#install"]() end,
  }

  --use "goolord/alpha-nvim"          -- neovim 启动页面
  --use "ahmedkhalf/project.nvim"     -- project manager

  --- Git
  --use "lewis6991/gitsigns.nvim"

  --- Colorschemes
  --use "lunarvim/colorschemes"     -- A bunch of colorschemes you can try out
  --use "lunarvim/darkplus.nvim"
  --use "Mofiqul/vscode.nvim"

end)



