local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

--- path to store parsers. VVI: directory must be writeable and must be explicitly added to the runtimepath.
--- 需要在 setup() 中设置 parsers_install_dir, 同时将 path 添加到 vim 的 runtimepath 中.
local treesitter_parsers_path = vim.fn.stdpath('data') .. '/site/treesitter-parser'
vim.opt.runtimepath:append(treesitter_parsers_path)

configs.setup {
  --- supported langs, https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  --ensure_installed = { "go", "lua", "javascript", "typescript", "tsx", "html", "css", "scss" ... },
  ensure_installed = "all",  -- 白名单, "all" OR a list of languages
  sync_install = false,  -- install languages synchronously (only applied to `ensure_installed`)
  ignore_install = {},  -- 黑名单, List of parsers to ignore installing
  parser_install_dir = treesitter_parsers_path,  -- path to store parsers.

  --- `:TSModuleInfo` 可以查看 module 设置.
  --- treesitter 自带 modules 设置 -----------------------------------------------------------------
  highlight = {
    enable = true,  -- VVI: highlight 是 treesitter 的主要功能.
    disable = { "" },  -- list of language that will be disabled

    --- NOTE: true - 同时使用 treesitter 和 vim 自带 syntax 颜色, vim syntax 和 treesitter 的颜色效果叠加.
    ---              eg: syntax 是 bold, 而 treesitter 是 blue, 则最终颜色效果为 blue + bold.
    ---       false - 只使用 treesitter 颜色.
    additional_vim_regex_highlighting = false,
  },

  --- BUG 每次打开文件都会添加一个 setlocal indentexpr=nvim_treesitter#indent()
  --- https://github.com/nvim-treesitter/nvim-treesitter/issues/3172
  --- 使用 'indent_blankline' 代替.
  -- indent = {
  --   enable = true,
  --   disable = { "yaml" },  -- 不要自动给 yaml 进行 indent.
  -- },

  --- 作用不大.
  --incremental_selection = {
  --  enable = true,
  --  keymaps = {
  --    init_selection = "gnn",
  --    node_incremental = "grn",
  --    scope_incremental = "grc",
  --    node_decremental = "grm",
  --  },
  --},

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
  rainbow = {
    enable = true,
    disable = { "cpp", "go" },  -- list of languages you want to disable the plugin for
    extended_mode = false, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = 999, -- Do not enable for files with more than n lines, int
  },
}

--- rainbow colors ---------------------------------------------------------------------------------
vim.cmd [[highlight rainbowcol1 ctermfg=220]]  -- yellow
vim.cmd [[highlight rainbowcol2 ctermfg=33]]   -- blue
vim.cmd [[highlight rainbowcol3 ctermfg=81]]   -- cyan
vim.cmd [[highlight rainbowcol4 ctermfg=206]]  -- magenta
vim.cmd [[highlight rainbowcol5 ctermfg=42]]   -- green
vim.cmd [[highlight rainbowcol6 ctermfg=167]]  -- red
vim.cmd [[highlight rainbowcol7 ctermfg=248]]  -- grey




