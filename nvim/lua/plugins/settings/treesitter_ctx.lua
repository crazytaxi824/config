local ts_ctx_status_ok, ts_ctx = pcall(require, "treesitter-context")
if not ts_ctx_status_ok then
  return
end

-- local max_ln = (vim.wo.scrolloff >= 6) and vim.wo.scrolloff or 6
local max_ln = 3

-- https://github.com/nvim-treesitter/nvim-treesitter-context#configuration
ts_ctx.setup{
  enable = true,

  -- How many lines the window should span. Values <= 0 mean no limit.
  -- Can be '<int>%' like '30%' - to specify percentage of win.height
  -- VVI: 会受到 set scrolloff 影响.
  max_lines = max_ln,

  -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  min_window_height = 0,

  line_numbers = true,   -- show line numbers.
  trim_scope = 'outer',  -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
}

-- highlight --------------------------------------------------------------------------------------
-- 默认 link to NormalFloat
vim.api.nvim_set_hl(0, 'TreesitterContext', { ctermbg=Colors.black.c, bg=Colors.black.g })
vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { underline=true, sp=Colors.g243.g })

-- 默认 link to LineNr
vim.api.nvim_set_hl(0, 'TreesitterContextLineNumber', {
  ctermfg=Colors.magenta_keywd.c, fg=Colors.magenta_keywd.g,
  ctermbg=Colors.black.c, bg=Colors.black.g,
})



