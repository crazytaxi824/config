local ts_ctx_status_ok, ts_ctx = pcall(require, "treesitter-context")
if not ts_ctx_status_ok then
  return
end

--- https://github.com/nvim-treesitter/nvim-treesitter-context#configuration
ts_ctx.setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
                 -- VVI: 会受到 set scrolloff 影响.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,   -- show line numbers.
  trim_scope = 'outer',  -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'

  -- VVI: The options below are exposed but shouldn't require your attention,
  --      you can safely ignore them.
  --mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  --zindex = 20, -- The Z-index of the context window
  --separator = nil,  -- Separator between context and content. Should be a single character string, like '-'.
}

--- highlight --------------------------------------------------------------------------------------
--- NOTE: 需要设置和 BufferLineBufferSelected 的 bg 颜色一致.
vim.api.nvim_set_hl(0, 'TreesitterContext', {ctermbg=Colors.black.c, bg=Colors.black.g})  -- 默认 link to NormalFloat
vim.api.nvim_set_hl(0, 'TreesitterContextLineNumber', {ctermbg=Colors.black.c, bg=Colors.black.g}) -- 默认 link to LineNr



