local nv_ts_status_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
if not nv_ts_status_ok then
  return
end

local nvim_ts_ok, nvim_ts_parsers = pcall(require, "nvim-treesitter.parsers")
if not nvim_ts_ok then
  return
end

--- path to store parsers. VVI: directory must be writeable and must be explicitly added to the runtimepath.
--- 需要在 setup() 中设置 parser_install_dir, 同时将 path 添加到 vim 的 runtimepath 中.
--local treesitter_parsers_path = vim.fn.stdpath('data') .. '/treesitter_parser'
--vim.opt.runtimepath:append(treesitter_parsers_path)

ts_configs.setup {
  --- supported langs, https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  --- 白名单, ts 启动时自动安装, "all" OR a list of languages.
  --- NOTE: 推荐使用黑名单 (ignore_install), 因为某些语言有多个 parsers, 使用白名单时可能导致遗漏.
  ensure_installed = "all",
  -- ensure_installed = {  --- {{{
  --   "vim", "vimdoc", "query", "lua",  -- for neovim itself
  --   "javascript", "typescript", "tsx", "html", "css", "scss",
  --   "python", "go",
  --   "markdown", "markdown_inline", "latex",
  --   "toml", "yaml", "json", "jsonc",
  -- },
  -- -- }}}

  --- 黑名单, ts 启动时不安装. list 中的 lang 在 :TSUpdate & :TSInstall 时安装速度太慢.
  --- ignore 的 lang 可以手动更新 `:TSUpdate rust`, 但是不能使用 `:TSUpdate` 自动更新.
  ignore_install = {"d", "scala", "rust"},  -- compile too slow.

  --- install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  --- VVI: opt 加载 nvim-treesitter 时最好使用默认路径. 否则 run=":TSUpdate" 会在本 config 文件加载之前进行安装,
  --- 这时候 nvim-treesitter 并没有读取到 parser_install_dir 导致 parser 被安装在默认位置.
  --- nvim-treesitter 加载 config 后会在多个文件夹中读取到重复的 parser 造成冲突而报错.
  --parser_install_dir = treesitter_parsers_path,  -- path to store parsers.

  --- `:TSModuleInfo` 可以查看 module 设置.
  --- treesitter 自带 modules 设置 -----------------------------------------------------------------
  highlight = {
    --- VVI: 如果使用 lazy 方式启动 highlight, 需要设置为 false,
    --- 提前加载会严重拖慢 nvim 启动/文件打开速度.
    enable = true,

    --- list of language that will be disabled.
    disable = function(lang, buf)
      local disabled_langs = {}  --- vimdoc 即 :help 文档.
      if vim.tbl_contains(disabled_langs, lang) then
        return true
      end

      local max_filesize = 300 * 1024 -- 300 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))  -- 获取 filesize
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,

    --- NOTE: `:help :syn-manual`. nvim-treesitter 会强制将 syntax 设置为 `syntax manual`.
    ---        This will enable the syntax highlighting, but not switch it on automatically.
    ---        `echo g:syntax_on` = 1, 说明 syntax 是开启状态;
    ---        `set syntax?` 返回 'ON', 而不是 'go', 'lua' ..., 说明是 `syntax manual` 设置.
    --- true  - 同时使用 treesitter 和 vim 自带 syntax 颜色, 这时 vim syntax 和 treesitter 的颜色效果叠加.
    ---         eg: syntax 是 bold, 而 treesitter 是 blue, 则最终颜色效果为 blue + bold.
    ---         使用 vim 自带 syntax, 所以 `set syntax?` 返回 'ON'.
    --- false - 只使用 treesitter 颜色, 默认值.
    ---         不使用 vim 自带 syntax, 所以 `set syntax?` 返回 ''.
    additional_vim_regex_highlighting = false,
  },

  --- 作用不大.
  -- incremental_selection = {
  --   enable = true,
  --   keymaps = {
  --     init_selection = "gnn",
  --     node_incremental = "grn",
  --     scope_incremental = "grc",
  --     node_decremental = "grm",
  --   },
  -- },

  --- NOTE: This is an experimental feature. 使用 'indent_blankline' 代替.
  -- indent = {
  --   enable = true,
  --   disable = { "yaml" },  -- 不要自动给 yaml 进行 indent.
  -- },

  --- 启用第三方插件 modules 设置 ------------------------------------------------------------------
  --- "JoosepAlviste/nvim-ts-context-commentstring"
  context_commentstring = {
    enable = true,
    enable_autocmd = false,  -- VVI: trigger commentstring updating on CursorHold
  },

  --- "windwp/nvim-ts-autotag", auto close tag <div></div>
  autotag = {
    enable = true,
    filetypes = {
      'html', 'javascript', 'typescript',
      'javascriptreact', 'typescriptreact',
      'svelte', 'vue', 'tsx', 'jsx',
      'rescript', 'xml', 'markdown',
    },
  },

  --- "nvim-treesitter/playground"
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    --keybindings = {  -- {{{
    --  toggle_query_editor = 'o',
    --  toggle_hl_groups = 'i',
    --  toggle_injected_languages = 't',
    --  toggle_anonymous_nodes = 'a',
    --  toggle_language_display = 'I',
    --  focus_language = 'f',
    --  unfocus_language = 'F',
    --  update = 'R',
    --  goto_node = '<cr>',
    --  show_help = '?',
    --},
    -- -- }}}
  },

  --- "p00f/nvim-ts-rainbow"
  -- rainbow = {
  --   enable = false,  -- VVI: 严重拖慢文件打开速度, 不建议开启.
  --   disable = { "cpp", "go" },  -- list of languages you want to disable the plugin for
  --   extended_mode = false,  -- Also highlight non-bracket delimiters like html tags,
  --                           -- boolean or table: {lang = boolean}
  --   max_file_lines = 999, -- Do not enable for files with more than n lines, int
  -- },
}

--- fold 设置 -------------------------------------------------------------------------------------- {{{
--- 设置 nvim-treesitter 提供的 foldexpr.
--- VVI: 不要设置 foldmethod=syntax, 会严重拖慢文件切换速度. eg: jump to definition.
local function set_treesitter_fold_method_if_has_parser(foldlevel)
  --- treesitter 是否有对应的 parser for current buffer.
  local has_parser = nvim_ts_parsers.has_parser(nvim_ts_parsers.get_buf_lang())

  --- 如果当前 foldmethod 不是默认值 manual 说明已经被设置过了, 这里就不再设置 foldmethod.
  if vim.wo.foldmethod == 'manual' and has_parser then
    vim.opt_local.foldmethod='expr'
    vim.opt_local.foldexpr='nvim_treesitter#foldexpr()'
    vim.opt_local.foldlevel=foldlevel
  end
end

--- VVI: Lazyload nvim-treesitter 时, 必须对已经打开的文件设置 foldmethod, foldexpr ...
set_treesitter_fold_method_if_has_parser(999)

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    set_treesitter_fold_method_if_has_parser(999)
  end,
  desc = "treesitter: setlocal foldmethod = 'expr'",
})

--- Command 手动切换 foldmethod
vim.api.nvim_create_user_command('FoldmethodToggle', function()
  if vim.wo.foldmethod == 'expr' then
    vim.opt_local.foldmethod='marker'
    Notify(":setlocal foldmethod = marker", 'INFO')
  else
    vim.opt_local.foldmethod='expr'
    vim.opt_local.foldexpr='nvim_treesitter#foldexpr()'
    Notify(":setlocal foldmethod = expr", 'INFO')
  end
end, {bang=true, bar=true})

-- -- }}}

--- `nvim-ts-rainbow` color settings --------------------------------------------------------------- {{{
--vim.cmd [[hi rainbowcol1 ctermfg=220]]  -- yellow
--vim.cmd [[hi rainbowcol2 ctermfg=33]]   -- blue
--vim.cmd [[hi rainbowcol3 ctermfg=81]]   -- cyan
--vim.cmd [[hi rainbowcol4 ctermfg=206]]  -- magenta
--vim.cmd [[hi rainbowcol5 ctermfg=42]]   -- green
--vim.cmd [[hi rainbowcol6 ctermfg=167]]  -- red
--vim.cmd [[hi rainbowcol7 ctermfg=248]]  -- grey
-- -- }}}

--- prompt before install missing parser for languages --------------------------------------------- {{{
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    -- local lang = vim.treesitter.language.get_lang(params.match) or ''  -- Don't assign nil to lang
    local lang = nvim_ts_parsers.get_buf_lang(params.buf)

    --- Checks if treesitter parser for language is installed.
    if vim.tbl_contains(nvim_ts_parsers.available_parsers(), lang)  --- 如果 nvim-treesitter 中有该 parser
      and not nvim_ts_parsers.has_parser(lang)  --- 但是该 parser 没有被安装
    then
      --- treesitter lang is not installed.
      Notify("run `:TSInstall " .. lang .. "` to install parser", "INFO", {title = "treesitter install"})
    end
  end,
  desc = "treesitter: Check treesitter parser for filetypes"
})
-- -- }}}

--- HACK: autocmd lazy highlight, setup() 中的 highlight module 需要设为 false --------------------- {{{
--- NOTE: 使用 lazy 方式启动 highlight, 提前加载 treesitter 会严重拖慢文件打开速度.
--- 参考源代码: enable_module() 针对 buffer 设置 module; enable_all() 是针对全局.
--- https://github.com/nvim-treesitter/nvim-treesitter/ - > /lua/nvim-treesitter/configs.lua
-- local parsers = require("nvim-treesitter.parsers")
--
-- --- 针对 buffer 设置 module
-- local function enable_module(mod, bufnr, lang)
--   local module = ts_configs.get_module(mod)
--   if not module then
--     return
--   end
--
--   bufnr = bufnr or vim.api.nvim_get_current_buf()
--
--   --- VVI: 判断 bufnr 是否存在.
--   --- 遇到的问题: WhichKey window 打开后很快关闭, 造成 error.
--   --- 分析: 因为 defer_fn() 的原因, 指定的 buffer 有可能在打开后 N(ms) 内就被关闭了, 引起 error.
--   if not vim.api.nvim_buf_is_valid(bufnr) then
--     return
--   end
--
--   --- 通过 parser 获取指定 buffer 的 lang.
--   lang = lang or parsers.get_buf_lang(bufnr)
--
--   if not module.enable then
--     if module.enabled_buffers then
--       module.enabled_buffers[bufnr] = true
--     else
--       module.enabled_buffers = { [bufnr] = true }
--     end
--   end
--
--   ts_configs.attach_module(mod, bufnr, lang)
-- end
--
-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = {"*"},
--   callback = function(params)
--     --- 文件打开之后再 highlight 文本.
--     vim.schedule(function()
--       enable_module('highlight', params.buf)
--     end)
--     --- NOTE: 如果使用 vim.schedule() 无法获得想要的效果, 可以使用 vim.defer_fn().
--     --vim.defer_fn(function()
--     --  enable_module('highlight', params.buf)
--     --end, 200)  -- delay (N)ms, then run callback()
--   end,
--   desc = "treesitter highlight after FileType event",
-- })
-- -- }}}
