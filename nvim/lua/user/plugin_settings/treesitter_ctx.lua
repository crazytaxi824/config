local ts_ctx_status_ok, ts_ctx = pcall(require, "treesitter-context")
if not ts_ctx_status_ok then
  return
end

--- https://github.com/nvim-treesitter/nvim-treesitter-context#configuration
ts_ctx.setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
                 -- VVI: 会受到 set scrolloff 影响.
  trim_scope = 'outer',  -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
    -- For all filetypes
    -- Note that setting an entry here replaces all other patterns for this entry.
    -- By setting the 'default' entry below, you can control which nodes you want to
    -- appear in the context window.
    default = {
      'class',
      'function',
      'method',
      'for',
      'while',
      'if',
      'switch',
      'case',
    },
    -- Example for a specific filetype.
    go = {
      'import',
      'type',
      'var',
      'const',
    },
  },
  exact_patterns = {
    -- Example for a specific filetype with Lua patterns
    -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
    -- exactly match "impl_item" only)
    -- rust = true,
  },

  -- VVI: The options below are exposed but shouldn't require your attention,
  --      you can safely ignore them.
  zindex = 20, -- The Z-index of the context window
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  separator = nil,  -- Separator between context and content. Should be a single character string, like '-'.
}

--- highlight --------------------------------------------------------------------------------------
--- NOTE: 需要设置和 BufferLineBufferSelected 的 bg 颜色一致.
vim.cmd [[hi TreesitterContext ctermbg=233]]  -- 默认 link to NormalFloat
vim.cmd [[hi TreesitterContextLineNumber ctermbg=233]]  -- 默认 link to LineNr, 最好和 TreesitterContext bg 颜色一致.



