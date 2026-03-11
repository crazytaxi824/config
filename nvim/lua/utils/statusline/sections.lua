--- @alias StlSections {a?: string, b?: string, c?: string, x?: string, y?: string, z?: string}
--- @alias StlHighlights {a?: vim.api.keyset.highlight, b?: vim.api.keyset.highlight, c?: vim.api.keyset.highlight}


--- active window
local stl_fmt_active = "%%#STL_act_A#%s%%#STL_act_B#%s%%#STL_act_C#%s%%=%s%%#STL_act_B#%s%%#STL_act_A#%s"

--- inactive window
local stl_fmt_inact = "%%#STL_inact_A#%s%%#STL_inact_B#%s%%#STL_inact_C#%s%%=%s%%#STL_inact_B#%s%%#STL_inact_A#%s"


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

return M
