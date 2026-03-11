local STL_act_A = "STL_act_A"
local STL_act_B = "STL_act_B"
local STL_act_C = "STL_act_C"
local STL_inact_A = "STL_inact_A"
local STL_inact_B = "STL_inact_B"
local STL_inact_C = "STL_inact_C"


--- init active highlights
vim.api.nvim_set_hl(0, STL_act_A, { fg = Colors.black.g, bg = Colors.yellow.g, bold = true })
vim.api.nvim_set_hl(0, STL_act_B, { fg = Colors.white.g, bg = Colors.g236.g })
vim.api.nvim_set_hl(0, STL_act_C, { fg = Colors.gold_fn.g, bg = Colors.black.g })


--- init inactive highlights
vim.api.nvim_set_hl(0, STL_inact_A, { fg = Colors.gold_fn.g, bg = Colors.g236.g })
vim.api.nvim_set_hl(0, STL_inact_B, { fg = Colors.white.g, bg = Colors.black.g })
vim.api.nvim_set_hl(0, STL_inact_C, { fg = Colors.g245.g, bg = Colors.black.g })


local M = {}

--- update active window statusline
--- set highlight 会马上生效, 不需要 statusline 刷新
---
--- @param hls StlHighlights
function M.update_act_hl(hls)
  if hls.a then
    vim.api.nvim_set_hl(0, STL_act_A, hls.a)
  end

  if hls.b then
    vim.api.nvim_set_hl(0, STL_act_B, hls.b)
  end

  if hls.c then
    vim.api.nvim_set_hl(0, STL_act_C, hls.c)
  end
end

--- update inactive window statusline
--- set highlight 会马上生效, 不需要 statusline 刷新
---
--- @param hls StlHighlights
function M.update_inact_hl(hls)
  if hls.a then
    vim.api.nvim_set_hl(0, STL_inact_A, hls.a)
  end

  if hls.b then
    vim.api.nvim_set_hl(0, STL_inact_B, hls.b)
  end

  if hls.c then
    vim.api.nvim_set_hl(0, STL_inact_C, hls.c)
  end
end

return M
