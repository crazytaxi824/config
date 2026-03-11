--- @alias StlSections {a?: string, b?: string, c?: string, x?: string, y?: string, z?: string}
--- @alias StlHighlights {a?: vim.api.keyset.highlight, b?: vim.api.keyset.highlight, c?: vim.api.keyset.highlight}


--- active window
local stl_fmt_active = "%%#STL_act_A#%s%%#STL_act_B#%s%%#STL_act_C#%s%%=%s%%#STL_act_B#%s%%#STL_act_A#%s"

--- inactive window
local stl_fmt_inact = "%%#STL_inact_A#%s%%#STL_inact_B#%s%%#STL_inact_C#%s%%=%s%%#STL_inact_B#%s%%#STL_inact_A#%s"


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


--- cache statusline section content
--- @type StlSections
local sections = {}


--- format to statusling string
--- @param stl_fmt string
--- @param sec StlSections
--- @return string
local function stl_format(stl_fmt, sec)
  return string.format(stl_fmt, sec.a or '', sec.b or '', sec.c or '',
    sec.x or '', sec.y or '', sec.z or '')
end


local M = {}

--- 更新某个 section 内容
---
--- @param sec StlSections
--- @param replace? 'replace'
function M.update_act_stl(sec, replace)
  if replace then
    sections = sec
  else
    sections = vim.tbl_deep_extend('force', sections, sec)
  end

  vim.wo.statusline = stl_format(stl_fmt_active, sections)
end

--- 更新 inactive window statusline
---
--- @param sec StlSections
function M.update_inact_stl(sec)
  vim.wo.statusline = stl_format(stl_fmt_inact, sec)
end

--- set highlight 会马上生效, 不需要 statusline 刷新
---
--- @param hls StlHighlights
--- @param active? 'active'|'inactive'
function M.update_hl(hls, active)
  active = active or 'active'

  if active then
    if hls.a then
      vim.api.nvim_set_hl(0, STL_act_A, hls.a)
    end

    if hls.b then
      vim.api.nvim_set_hl(0, STL_act_B, hls.b)
    end

    if hls.c then
      vim.api.nvim_set_hl(0, STL_act_C, hls.c)
    end
  else
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
end

return M
