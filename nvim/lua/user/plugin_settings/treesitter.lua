local nv_ts_status_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
if not nv_ts_status_ok then
  return
end

--- path to store parsers. VVI: directory must be writeable and must be explicitly added to the runtimepath.
--- 需要在 setup() 中设置 parsers_install_dir, 同时将 path 添加到 vim 的 runtimepath 中.
local treesitter_parsers_path = vim.fn.stdpath('data') .. '/treesitter_parser'
vim.opt.runtimepath:append(treesitter_parsers_path)

ts_configs.setup {
  --- supported langs, https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  --ensure_installed = { "go", "lua", "javascript", "typescript", "tsx", "html", "css", "scss" ... },
  ensure_installed = "all",  -- 白名单, "all" OR a list of languages
  sync_install = false,  -- install languages synchronously (only applied to `ensure_installed`)
  ignore_install = {},  -- 黑名单, 不安装.
  parser_install_dir = treesitter_parsers_path,  -- path to store parsers.

  --- `:TSModuleInfo` 可以查看 module 设置.
  --- treesitter 自带 modules 设置 -----------------------------------------------------------------
  highlight = {
    enable = true,  -- VVI: 如果使用 lazy 方式启动 highlight, 需要设置为 false,
                    -- 提前加载会严重拖慢 nvim 启动/文件打开速度.

    disable = { "" },  -- list of language that will be disabled.

    --- NOTE: true - 同时使用 treesitter 和 vim 自带 syntax 颜色, vim syntax 和 treesitter 的颜色效果叠加.
    ---              eg: syntax 是 bold, 而 treesitter 是 blue, 则最终颜色效果为 blue + bold.
    ---       false - 只使用 treesitter 颜色.
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
    filetypes = {'html', 'javascript', 'typescript',
      'javascriptreact', 'typescriptreact',
      'svelte', 'vue', 'tsx', 'jsx',
      'rescript', 'xml', 'markdown'},
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
  --   extended_mode = false, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
  --   max_file_lines = 999, -- Do not enable for files with more than n lines, int
  -- },
}

--- rainbow colors ---------------------------------------------------------------------------------
--vim.cmd [[hi rainbowcol1 ctermfg=220]]  -- yellow
--vim.cmd [[hi rainbowcol2 ctermfg=33]]   -- blue
--vim.cmd [[hi rainbowcol3 ctermfg=81]]   -- cyan
--vim.cmd [[hi rainbowcol4 ctermfg=206]]  -- magenta
--vim.cmd [[hi rainbowcol5 ctermfg=42]]   -- green
--vim.cmd [[hi rainbowcol6 ctermfg=167]]  -- red
--vim.cmd [[hi rainbowcol7 ctermfg=248]]  -- grey

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
--   if vim.fn.bufexists(bufnr) == 0 then
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
--   end
-- })
-- -- }}}


