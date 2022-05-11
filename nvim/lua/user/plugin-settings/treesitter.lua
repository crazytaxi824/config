local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

configs.setup {
  --ensure_installed = { "go", "lua", "javascript", "typescript", "tsx", "html", "css", "scss" ... },
  ensure_installed = "all",  -- 白名单, "all" OR a list of languages
  sync_install = false,      -- install languages synchronously (only applied to `ensure_installed`)
  ignore_install = {},  -- 黑名单, List of parsers to ignore installing
  highlight = {
    enable = true,     -- false will disable the whole extension
    disable = { "" },  -- list of language that will be disabled
    additional_vim_regex_highlighting = false,  -- NOTE: 同时使用 vim 自带 syntax,
                                                -- 使得 vim syntax 和 tree-sitter 的颜色效果(underine, bold...)同时生效
  },
  indent = { enable = true, disable = { "yaml" } },

  --- plugins settings -----------------------------
  --- "JoosepAlviste/nvim-ts-context-commentstring"
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },

  --- "windwp/nvim-autopairs", NOTE: 好像不需要设置了.
  autopairs = {
   enable = true,
  },

  --- "windwp/nvim-ts-autotag", NOTE: auto close tag <div></div>
  autotag = {
    enable = true,
  },

  --- "nvim-treesitter/playground"
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    --keybindings = {
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
  },

  --- "p00f/nvim-ts-rainbow"
  rainbow = {
    enable = true,
    --disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = false, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
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




