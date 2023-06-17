--- 安装: `git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim`
--- README: packer 主要是一个 plugin 安装/管理插件.
--- nvim 加载插件的时候读取的是 packer.compile() 之后的文件. 所以在修改了插件设置后需要 `:PackerCompile` 来使设置生效.
--- `:PackerSync` 的时候会自动运行 compile(), 重新生成 compile 文件. 主要影响 setup() 设置文件加载.
--- `:PackerLoad a b` 相当于 lua require('packer').loader('a b')
--- Packer.nvim 设置文档 --------------------------------------------------------------------------- {{{
-- https://github.com/wbthomason/packer.nvim#specifying-plugins
--
-- opt 属性:
--   当 plugin 有加载条件的时候, plugin 的安装地址会从 ~/.local/share/nvim/site/pack/packer/start -> opt
--   plugin 的 opt 属性会被改为 true, `:PackerStatus`
--
-- `:help packer.use()`
-- use {
--   'myusername/example',        -- The plugin location string
--
--   disable = boolean,           -- Mark a plugin as inactive
--   as = string,                 -- VVI: 别名
--   installer = function,        -- Specifies custom installer. See "custom installers" below.
--   updater = function,          -- Specifies custom updater. See "custom installers" below.
--   after = string or list,      -- after 中的 plugin 加载后, 自动加载自己; after 中的 plugin 没加载, 自己也不会加载.
--                                -- VVI: after 插件名可查看 packer_compiled.lua, eg: after = "nvim-cmp", 不能写 after = "hrsh7th/nvim-cmp"
--   rtp = string,                -- Specifies a subdirectory of the plugin to add to runtimepath.
--   opt = boolean,               -- Manually marks a plugin as optional.
--                                -- VVI: 可以通过 `:PackerLoad foo bar` OR require('packer').loader('foo bar') 手动加载
--                                -- packer.nvim 提供一个全局变量 packer_plugins 在 plugin/packer_compiled.lua 中.
--                                -- vim.print(packer_plugins) 可以用来判断 plugins 是否安装, 是否加载 (loaded=true)
--
--   bufread = boolean,           -- Manually specifying if a plugin needs BufRead after being loaded
--
--   -- 固定 plugin 版本
--   branch = string,             -- VVI: Specifies a git branch to use
--   tag = string,                -- VVI: Specifies a git tag to use. Supports '*' for "latest tag"
--   commit = string,             -- VVI: Specifies a git commit to use
--   lock = boolean,              -- VVI: Skip updating this plugin in updates/syncs. Still cleans.
--
--   run = string, function, or table, -- VVI: UPDATE 到 new version 之后执行. `:PackerUpdate`, `:PackerSync` ...
--   requires = string or list,   -- VVI: 只要求安装 requires 中的插件 (插件在 plugins table 中), 但不要求加载. 这也是和 after 最大的区别.
--                                -- requires 插件名需要写全名, requires = "hrsh7th/nvim-cmp"
--   config = string or function, -- VVI: after plugin loaded. `config = function() ... end`,
--   rocks = string or list,      -- Specifies `Luarocks` dependencies for the plugin
--
--   -- NOTE: The `setup` implies `opt = true`
--   setup = string or function,  -- VVI: Specifies code to run before this plugin is loaded.
--
--   -- NOTE: The following keys all imply `lazy-loading` and imply `opt = true`
--   -- plugin 加载条件.
--   cmd = string or list,        -- VVI: 必须是 plugin 自带 command.
--   ft = string or list,         -- 指定 filetype 加载插件.
--                                -- BUG: 使用 ft 后, after/syntax, after/ftplugin 中的文件会被读取两次. 不推荐使用.
--                                -- https://github.com/wbthomason/packer.nvim/issues/648
--                                -- https://github.com/wbthomason/packer.nvim/issues/698
--   keys = string or list,       -- Specifies maps which load this plugin. See "Keybindings".
--   event = string or list,      -- Specifies autocommand events which load this plugin.
--   fn = string or list          -- Specifies functions which load this plugin. VVI: 目前测试只有 VimL fn 可以使用.
--   cond = string, function, or list of strings/functions,   -- Specifies a conditional test to load this plugin
--   module = string or list      -- Specifies Lua module names for require. When requiring a string which starts
--                                -- with one of these module names, the plugin will be loaded.
--   module_pattern = string/list -- Specifies Lua pattern of Lua module names for require. When
--                                -- requiring a string which matches one of these patterns, the plugin will be loaded.
-- }
--
-- Packer 命令
--   `:PackerCompile`    -- Regenerate compiled loader file
--   `:PackerClean`      -- Remove any disabled or unused plugins
--   `:PackerInstall`    -- Clean, then install missing plugins
--   `:PackerUpdate`     -- Clean, then update and install plugins
--
--   `:PackerSnapshot foo`     -- 创建一个 snapshot
--   `:PackerSnapshotDelete foo`  -- 删除一个 snapshot
--   `:PackerSnapshotRollback foo`  -- 回滚到指定 snapshot
--
--   `:PackerSync`       -- NOTE: 使用这一个命令就够了. Perform `PackerUpdate` and then `PackerCompile`
--   NOTE: You must run this or `PackerSync` whenever you make changes to your plugin configuration.
--
-- Packer opt 设置
--   NOTE: Only required if you have packer configured as `opt`
--   vim.cmd [[packadd packer.nvim]]  -- 会在 stdpath('cache') 中创建 "packer.nvim" 文件夹

-- -- }}}

--- VVI: debug.getinfo() 函数获取本文件路径 -------------------------------------------------------- {{{
--- source 返回的内容中:
---   If source starts with a '@', it means that the function was defined in a file;
---   If source starts with a '=', the remainder of its contents describes the source in a user-dependent manner.
---   Otherwise, the function was defined in a string where source is that string. eg: `:lua print(debug.getinfo(1, 'S').source)`, result `:lua`
local this_file = debug.getinfo(1, 'S').source
if string.sub(this_file, 1, 1) ~= '@' then
  Notify("packer config file error", "ERROR", {title = "packer.nvim", timeout = false})
  return
else
  this_file = string.sub(this_file, 2)
  --- print(this_file)
end
-- -- }}}

--- vim.schedule() lazyload plugins ---------------------------------------------------------------- {{{
local function lazyload_plugins()
  --- NOTE: 利用vim.schedual() lazyload plugins
  vim.schedule(function()
    local lazyload_list = require("user.plugins_lazy_loader")
    for _, plugin in ipairs(lazyload_list) do
      require('packer').loader(plugin)
    end
  end)
end
-- -- }}}

--- NOTE: 如果 packer 不存在则自动 install "packer.nvim" ------------------------------------------- {{{
--- DOC: https://github.com/wbthomason/packer.nvim#bootstrapping
local packer_bootstrap = false  -- 是否需要安装 packer.

local packer_status_ok = pcall(require, "packer")
if not packer_status_ok then
  --- 需要安装 packer. NOTE: 其他插件的安装在 packer.startup() 函数的最后启动.
  packer_bootstrap = true

  print('installing packer.nvim ...')

  --- install "packer.nvim"
  --- DOC: https://github.com/wbthomason/packer.nvim#quickstart
  local packer_install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  local packer_install_cmd = 'git clone --depth 1 https://github.com/wbthomason/packer.nvim ' .. packer_install_path

  local result = vim.fn.system(packer_install_cmd)
  if vim.v.shell_error ~= 0 then  -- 判断 system() 结果是否错误
    vim.notify(result, vim.log.levels.ERROR)
    return
  end

  print('packer.nvim is installed.')
  print('installing plugins ...')

  --- VVI: 手动加载 packer. 否则其他的 require("packer") 无法使用.
  vim.cmd('packadd packer.nvim')  -- 加载 module

  --- packer plugin 安装完成后, 安装 treesitter lang parsers.
  vim.api.nvim_create_autocmd("User", {
    pattern = {"PackerComplete"},
    once = true,
    callback = function(params)
      vim.cmd('packadd nvim-treesitter')  -- 手动加载 treesitter
      vim.cmd('TSInstall all')  -- 安装 all lang parsers

      --- TODO :Mason install list
    end,
    desc = "install treesitter's parsers after packer is installed",
  })
else
  --- 不需要安装 packer 的情况下, lazyload plugins.
  lazyload_plugins()
end
-- -- }}}

--- save plugins.lua (本文件) 时自动运行 `:PackerSync` OR `:PackerCompile` 命令 -------------------- {{{
--- NOTE: 修改本文件后必须进行 `:PackerCompile`, 否则设置无法生效.
--- 这里必须使用 autogroup 否则每次 `:source <this_file>` 都会生成一个新的 autocmd, 导致很多个相同的 autocmd 存在.
--- 通过 'autogroup <group_name> au! ... ' 可以覆盖之前的 autogroup 设置. 所以每次 `:source <this_file>` 之后
--- 只有一个 autogroup 存在.
local packer_user_config_id = vim.api.nvim_create_augroup(
  "packer_user_config",
  {clear = true}  -- NOTE: clear=true 表示 'au!'
)

--- this_file 保存之后自动执行 `source <this_file> | PackerCompile`
vim.api.nvim_create_autocmd("BufWritePost", {
  group = packer_user_config_id,
  pattern = {this_file},
  command = 'source ' .. this_file .. ' | PackerCompile profile=true',  -- 相当于 'source <afile>',
  desc = "PackerCompile after packer config is changed",
})
-- -- }}}

--- packer 记录 update info & :PackerUpdateLog ----------------------------------------------------- {{{
--- NOTE: 使用 :PackerSync :PackerUpdate ... 之后记录 update info 到指定文件.
--- doautocmd User PackerComplete     -- Fires after install, update, clean, and sync asynchronous operations finish.
--- doautocmd User PackerCompileDone  -- Fires after compiling.
--- 使用方法 vim.cmd [[ autocmd User PackerComplete :set filetype? ]]
--- getline(1, '$') 获取文件所有内容. return list.
--- writefile(["foo", "bar"], "foo.log", "a")  -- a - append mode

--- packer update log 文件写入位置.
local packer_update_log = vim.fn.stdpath('cache') .. '/packer.myupdate.log'

--- 记录 :PackerSync && :PackerUpdate ... 更新信息到指定文件.
vim.api.nvim_create_autocmd("User", {
  pattern = { "PackerComplete" },
  callback = function(params)
    --- NOTE: 如果打开了 packer 窗口, 则记录窗口中的所有内容.
    if vim.bo[params.buf].filetype == 'packer' then
      --- 读取 packer 面板 buffer 中的所有信息. 从第一行到最后一行.
      local update_info = vim.fn.getline(1, '$')

      --- 读取 log 文件中的最后几行, 判断内容是否相同.
      if vim.fn.filereadable(packer_update_log) == 1 then
        local line_num = #update_info
        local log_content = vim.fn.readfile(packer_update_log, '', -line_num) -- 负数从后向前读.

        --- 查看 content 是否相同
        if table.concat(update_info, '') == table.concat(log_content, '') then
          return
        end
      end

      --- 给内容添加时间信息.
      local time_now = vim.fn.strftime(" [%Y-%m-%d %H:%M:%S]")
      update_info = vim.list_extend({"", time_now}, update_info)

      --- 将内容写入文件中.
      vim.fn.writefile(update_info, packer_update_log, 'a')
      vim.cmd('checktime')
    end
  end,
  desc = "log packer update logs",
})

--- 显示上述文件的内容.
vim.api.nvim_create_user_command("PackerUpdateLog",
  function()
    --- nobuflisted
    --- nomodifiable 不能修改原文件, 但是可以将修改后的文件保存到另一个文件中.
    --- readonly     不能 :w 保存修改, 但是可以 :w! 强制保存修改到原文件.
    vim.cmd([[edit +setlocal\ readonly ]] .. packer_update_log)
  end,
  {bang=true, bar=true}
)
-- -- }}}

--- packer.init(), Have packer use a popup window, "nvim-lua/popup.nvim" --------------------------- {{{
require('packer').init {
  --- Name of the snapshot File you would like to load at startup.
  --- 该设置需要联网, 如果无法访问 github.com 则直接报错.
  --- VVI: 最好在 startup() 的每个 use() 中使用 commit && lock 固化插件版本 curing plugins.
  --snapshot = "2022.07.18",

  snapshot_path = vim.fn.stdpath('cache') .. '/packer_snapshots',  -- 默认路径是 stdpath('cache') .. '/packer.nvim'
  --package_root = vim.fn.stdpath('data') .. '/site/pack',  -- 默认值
  --compile_path = vim.fn.stdpath('config') .. '/plugin/packer_compiled.lua',  -- VVI: 默认值, 文件放在 plugin/ 文件夹下, nvim 会自动加载.

  ensure_dependencies = true, -- Should packer install plugin dependencies?
  auto_clean = true, -- During sync(), remove unused plugins
  autoremove = false, -- Remove disabled or unused plugins without prompting the user
  compile_on_sync = true, -- During sync(), run packer.compile()
  auto_reload_compiled = true, -- Automatically reload the compiled file after creating it.

  display = {
    open_fn = function()
      --- require("packer.util").float() 使用 float window 打开 packer info 面板. 默认在右侧打开新 window.
      --- border = { ... } 面板 border 样式.
      return require("packer.util").float({ border = {"▄","▄","▄","█","▀","▀","▀","█"} })  -- `:help nvim_open_win()`
    end,
    prompt_border = {"▄","▄","▄","█","▀","▀","▀","█"},  -- prompt 面板样式. eg: delete plugins
    keybindings = { -- Keybindings for the display window
      quit = 'q',  -- close window, 默认是 'q'
      toggle_info = '<CR>',
      diff = 'd',
      prompt_revert = 'r',
    },
  },
  log = { level = 'warn' }, -- "trace", "debug", "info", "warn"(*), "error", "fatal".
}
-- -- }}}

--- 官方文档 https://github.com/wbthomason/packer.nvim
--- 插件推荐 https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/plugins.lua
---          https://github.com/LunarVim/LunarVim/blob/master/lua/lvim/plugins.lua
--- `:echo stdpath("data")` == "~/.local/share/nvim"
--- 插件的安装位置在 "~/.local/share/nvim/site/pack/packer/start/..."
--- `:PackerSync` - install / update / clean 插件包.
return require('packer').startup(function(use)
  use {"wbthomason/packer.nvim",  -- VVI: 必要. Have packer manage itself
    commit = "1d0cf98",
  }

  --- Performence & Functions ----------------------------------------------------------------------
  --- 加快 lua module 加载时间, 生成 ~/.cache/nvim/luacache_chunks && luacache_modpaths
  --- VVI: impatient needs to be setup before any other lua plugin is loaded.
  use {"lewis6991/impatient.nvim",
    --- NOTE: 这里只是安装 impatient, config 设置在 init.lua 中.
    commit = "47302af",
    run = ":LuaCacheClear",  -- Update 后清空 luacache_chunks && luacache_modpaths, 下次启动 nvim 时重新生成.
  }

  --- Useful lua functions used by lots of plugins
  --- NOTE: plenary.nvim 合并了 popup.nvim
  use {"nvim-lua/plenary.nvim",
    commit = "36aaceb",
  }

  --- Must install ---------------------------------------------------------------------------------
  --- 快捷键提醒功能, key mapping 的时候需要注册到 which-key
  use {"folke/which-key.nvim",
    tag = "v1.4.3",
    config = function() require("user.plugin_settings.which_key") end,
  }

  --- 通知功能
  use {"rcarriga/nvim-notify",
    tag = "v3.12.0",
    config = function() require("user.plugin_settings.nvim_notify") end,
  }

  --- 安装 & 管理 lsp/formatter/linter/dap-debug tools 的插件
  use {"williamboman/mason.nvim",
    tag = "v1.2.1",
    run = ":MasonUpdate", -- :MasonUpdate updates All Registries, NOT packages.
    config = function() require("user.plugin_settings.mason_tool_installer") end,
    --- NOTE: 不能 opt 加载 mason 否则其他插件无法找到 mason 安装的工具.
  }

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
  use {"nvim-treesitter/nvim-treesitter",
    commit = "1b9f704e",  -- NOTE: tag 更新太慢, commit 更新太快, 最好两周更新一次.
    --run = ":TSUpdate",  -- NOTE: 推荐手动执行, 批量安装 parser 容易卡死.
    config = function() require("user.plugin_settings.treesitter") end,
    requires = {
      --- 以下都是 treesitter modules 插件, 在 setup() 中启用的插件.
      "nvim-treesitter/nvim-treesitter-context",  -- 顶部显示 cursor 所在 function 的定义.
      "nvim-treesitter/playground",  -- 用于获取 treesitter 信息, 调整颜色很有用.
      "JoosepAlviste/nvim-ts-context-commentstring", -- Comment 依赖 commentstring.
      "windwp/nvim-ts-autotag",  -- auto close tag <div></div>
      --"p00f/nvim-ts-rainbow",  -- 括号颜色. treesitter 解析, 严重拖慢文件打开速度.
    },

    opt = true,  -- 在 vim.schedule() 中 lazy load
  }

  --- 第一方 module 插件 ---
  use {"nvim-treesitter/nvim-treesitter-context",  -- 顶部显示 cursor 所在 function 的定义.
    commit = "efe8706",
    config = function() require("user.plugin_settings.treesitter_ctx") end,

    after = "nvim-treesitter",
  }

  use {"nvim-treesitter/playground",  -- 用于获取 treesitter 信息, 调整颜色很有用.
    commit = "2b81a01",

    cmd = {"TSPlaygroundToggle", "TSHighlightCapturesUnderCursor"},
  }

  --- 第三方 module 插件 ---
  use {"windwp/nvim-ts-autotag",  -- auto close tag <div></div>
    commit = "6be1192",

    after = "nvim-treesitter",
  }

  use {"JoosepAlviste/nvim-ts-context-commentstring", -- Comment 依赖 commentstring.
    commit = "0bf8fbc",

    after = "nvim-treesitter",
  }

  --- 以下是使用了 treesitter 功能的插件. (这些插件也可以不使用 treesitter 的功能)
  --- 注释
  use {"numToStr/Comment.nvim",
    commit = "176e85e",
    config = function() require("user.plugin_settings.comment") end,
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "JoosepAlviste/nvim-ts-context-commentstring", -- Comment 依赖 context-commentstring.
    },

    after = {"nvim-treesitter", "nvim-ts-context-commentstring"},
  }

  --- indent line
  use {"lukas-reineke/indent-blankline.nvim",
    tag = 'v2.20.6',
    config = function() require("user.plugin_settings.indentline") end,  -- setup() 设置 use_treesitter = true
    requires = "nvim-treesitter/nvim-treesitter",

    after = "nvim-treesitter",
  }

  --- Auto Completion ------------------------------------------------------------------------------
  use {"hrsh7th/nvim-cmp",
    commit = "b8c2a62",
    config = function() require("user.plugin_settings.cmp_completion") end,
    requires = {
      "hrsh7th/cmp-nvim-lsp",  -- lsp 提供的代码补全
      "hrsh7th/cmp-buffer",  -- 当前 buffer 中有的 word
      "hrsh7th/cmp-path",  -- filepath 补全
      --"hrsh7th/cmp-cmdline",  -- cmdline completions, 不好用.
      "saadparwaiz1/cmp_luasnip",  -- snippets
    },

    opt = true,  -- 在 vim.schedule() 中 lazy load
  }

  --- NOTE: 以下是 "nvim-cmp" 的 module 插件, 在 nvim-cmp.setup() 中启用的插件.
  --- 只有 "cmp-nvim-lsp" 不需要在 "nvim-cmp" 之后加载,
  --- 其他 module 插件都需要在 "nvim-cmp" 加载之后再加载, 否则报错.
  use {"hrsh7th/cmp-nvim-lsp",  -- LSP source for nvim-cmp
    commit = "0e6b2ed",
  }

  use {"hrsh7th/cmp-buffer",  -- 当前 buffer 中有的 word
    commit = "3022dbc",

    after = "nvim-cmp",
  }

  use {"hrsh7th/cmp-path",  -- filepath 补全
    commit = "91ff86c",

    after = "nvim-cmp",
  }

  use {"saadparwaiz1/cmp_luasnip",  -- Snippets source for nvim-cmp
    commit = "1809552",
    requires = "L3MON4D3/LuaSnip",

    after = "nvim-cmp",
  }

  --- snippet engine, for "cmp_luasnip", 每次打开文件都会有一个 [Scratch] buffer.
  use {"L3MON4D3/LuaSnip",
    commit = "4964cd1",
    run = "make install_jsregexp",  -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#transformations
    config = function() require("user.plugin_settings.luasnip_snippest") end,
    requires = "rafamadriz/friendly-snippets",  -- snippets content

    --- VVI: 默认 bufread=true, 在 lazyload 该 plugin 之后马上再次触发 Filetype event.
    --- 导致连续多次触发 FileType event.
    opt = true,  -- 在 vim.schedule() 中 lazy load
    bufread = false,
  }

  --- snippets content, 自定义 snippets 可以借鉴这个结构.
  use {"rafamadriz/friendly-snippets",
    commit = "70b727d",
    --- NOTE: friendly-snippets 不能安装在 opt/ 文件夹下, 否则不生效. 该 plugin 不会对启动性能有影响, 可以直接加载.
  }

  --- cmdline completions, 不好用.
  -- use {"hrsh7th/cmp-cmdline",
  --   commit = "",
  --   after = "nvim-cmp",
  -- }

  --- 自动括号, 同时依赖 treesitter && cmp
  use {"windwp/nvim-autopairs",
    commit = "59df87a",
    config = function() require("user.plugin_settings.autopairs") end,
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp",
    },

    -- after = {
    --   "nvim-treesitter",  -- setup() 中 `check_ts`, `ts_config` 需要 treesitter 支持.
    --   "nvim-cmp",  -- cmp.event:on() 设置.
    -- },
    opt = true,  -- 在 vim.schedule() 中 lazy load
  }

  --- LSP ------------------------------------------------------------------------------------------
  --- lspconfig && null-ls 两个插件是互相独立的 LSP client, 没有依赖关系.
  --- 官方 LSP 引擎.
  use {"neovim/nvim-lspconfig",
    commit = "08f1f34",
    config = function() require("user.lsp.lsp_config") end,  -- NOTE: 如果加载地址为文件夹, 则会寻找文件夹中的 init.lua 文件.
    requires = {
      "nvim-cmp",  -- provide content to nvim-cmp Completion. cmp_nvim_lsp.update_capabilities(capabilities)
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason.nvim",  -- 安装 lsp 命令行工具.
    },

    after = {
      "mason.nvim",  -- 需要 mason 安装的 lsp cmd tool
      "cmp-nvim-lsp",  -- cmp_nvim_lsp.update_capabilities(capabilities) 代码补全功能.
    },
  }

  --- null-ls 插件 formatters && linters, depends on "nvim-lua/plenary.nvim"
  use {"jose-elias-alvarez/null-ls.nvim",
    commit = "a138b14",
    config = function() require("user.lsp.null_ls") end,
    requires = {
      "nvim-lua/plenary.nvim",
      "williamboman/mason.nvim",  -- 安装 linter/formatter 命令行工具. eg: shfmt, stylua ...
    },

    --after = "mason.nvim",  -- 需要 mason 安装的 lsp cmd tool
    opt = true,  -- 在 vim.schedule() 中 lazy load
  }

  --- File Tree Display ----------------------------------------------------------------------------
  --use "kyazdani42/nvim-web-devicons"  -- 提供 icons 需要 patch 字体 (Nerd Fonts)
  --- file explorer
  use {"kyazdani42/nvim-tree.lua",
    commit = "0345117",
    config = function() require("user.plugin_settings.file_tree") end,

    --opt = true,  -- VVI: 不推荐使用 lazyload, 会导致 `$ nvim dir` 直接打开文件夹的时候出现问题.
  }

  --- Buffer & Status Line -------------------------------------------------------------------------
  --- tabline decorator, `:help 'tabline'`
  use {"akinsho/bufferline.nvim",
    tag = "v4.1.0",
    config = function() require("user.plugin_settings.decor_bufferline") end,

    opt = true,  -- 在 vim.schedule() 中 lazy load
  }

  --- statusline decorator, `:help 'statusline'`
  use {"nvim-lualine/lualine.nvim",   -- bottom status line
    commit = "05d78e9",
    config = function() require("user.plugin_settings.decor_lualine") end,

    opt = true,  -- 在 vim.schedule() 中 lazy load
  }

  --- Debug tools 安装 -----------------------------------------------------------------------------
  --- NOTE: dap-ui && dap 设置在同一文件中.
  use {"mfussenegger/nvim-dap",  -- core debug tool
    tag = "0.6.0",
    requires = "williamboman/mason.nvim",  -- install dap-debug tools. eg: 'delve'

    cmd = {'DapToggleBreakpoint', 'DapContinue', 'DapLoadLaunchJSON'},
  }

  use {"rcarriga/nvim-dap-ui",  -- ui for "nvim-dap"
    tag = "v3.8.3",
    config = function() require("user.plugin_settings.dap_debug") end,  -- dap-ui && dap 设置在同一文件中.

    after = "nvim-dap",
  }

  --- Useful Tools ---------------------------------------------------------------------------------
  --- fzf rg fd, preview 使用的是 treesitter, 而不用 bat
  use {"nvim-telescope/telescope.nvim",
    commit = "89ca726",  -- tag = "0.1.2", 半年更新一次 tag
    config = function() require("user.plugin_settings.telescope_fzf") end,
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },

    --- VVI: 默认 bufread=true, 在 lazyload 该 plugin 之后马上再次触发 Filetype event.
    --- 导致连续多次触发 FileType event.
    --keys = {"<leader>f"},
    opt = true,  -- 在 vim.schedule() 中 lazy load
    bufread = false,
  }

  --- terminal
  use {"akinsho/toggleterm.nvim",
    tag = "v2.7.0",  -- NOTE: 尽量少更新, 更新后需要检查 user/utils/term/bg_term 运行情况.
    config = function() require("user.plugin_settings.toggleterm_terminal") end,

    opt = true,  -- 在 vim.schedule() 中 lazy load
  }

  --- Git
  --- NOTE: gitsigns 会检查 "trouble.nvim" 是否安装, 如果有安装则:
  --- `:Gitsigns setqflist/seqloclist` will open Trouble instead of quickfix or location list windows.
  --- https://github.com/lewis6991/gitsigns.nvim#troublenvim
  use {"lewis6991/gitsigns.nvim",
    commit = "4455bb5",
    config = function() require("user.plugin_settings.git_signs") end,

    opt = true,  -- 在 vim.schedule() 中 lazy load
  }

  --- tagbar --- {{{
  --- 函数/类型列表，需要安装 Universal Ctags - `brew info universal-ctags`, 注意不要安装错了.
  --- https://github.com/universal-ctags/ctags/blob/master/docs/news.rst#new-parsers
  --- `ctags --list-languages` 查看支持的语言. 不支持 jsx/tsx, 支持 typescript, 勉强支持 javascript
  -- -- }}}
  use {"preservim/tagbar",
    commit = "be56353",
    config = function() require("user.plugin_settings.tagbar") end,

    opt = true,  -- 在 vim.schedule() 中 lazy load
  }

  --- markdown preview
  use {"iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,  -- VVI: Update 后需要重新安装 preview 插件, 否则可能出现无法运行的情况.
    config = function() vim.cmd('doautocmd mkdp_init BufEnter') end,  -- VVI: 需要这个设置才能使用 cmd 条件加载, 否则报错.

    cmd = {"MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop"},
  }

  --use "goolord/alpha-nvim"          -- neovim 启动页面
  --use "ahmedkhalf/project.nvim"     -- project manager

  --- https://docs.github.com/en/copilot
  --- https://docs.github.com/en/copilot/getting-started-with-github-copilot?tool=neovim#prerequisites-3
  use {"github/copilot.vim",  -- NOTE: 目前不需要锁定版本.
    config = function()
      --- VVI: Neovim >= 0.6 and Node.js <= 17
      --- 指定 nodejs 版本. 这里使用的是 `brew install node@16`
      vim.g.copilot_node_command = "/usr/local/opt/node@16/bin/node"
    end,

    cmd = {"Copilot"},  -- `:Copilot setup`, `:Copilot enable`, `:help copilot` 查看可用命令.
  }

  --- VVI: 需要安装 packer 的情况下, 同时安装其他插件.
  if packer_bootstrap then
    require('packer').sync()
  end
end)
