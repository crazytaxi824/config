local M = {}


local fill_bg = { underline = true, sp=Colors.g242.g }
local fill_fg = vim.tbl_extend('force', { fg=Colors.g242.g }, fill_bg)
local sel_bg = vim.tbl_extend('force', { bg=Colors.g238.g }, fill_bg)
local sel_fg = vim.tbl_extend('force', { fg=Colors.cyan.g, bold=true }, sel_bg)
local sep = vim.tbl_extend('force', { fg=Colors.g240.g }, fill_bg)

vim.api.nvim_set_hl(0, "TabLine", fill_fg)
vim.api.nvim_set_hl(0, "TabLineFill", fill_bg)
vim.api.nvim_set_hl(0, "TabLineSel", sel_fg)
vim.api.nvim_set_hl(0, "TabLineSelFill", sel_bg)
vim.api.nvim_set_hl(0, "TabLineSeparator", sep)


function M.custom_tabline()
  local total = vim.fn.tabpagenr("$")
  local current = vim.fn.tabpagenr()
  local result = {}

  for i = 1, total do
    local fg_hl = i == current and "%#TabLineSel#" or "%#TabLine#"
    local bg_hl = i == current and "%#TabLineSelFill#" or "%#TabLineFill#"

    result[i] = bg_hl .. "%="
      .. fg_hl
      .. "%" .. i .. "T  "   -- 开始 Tab N 的可点击区域
      .. i                   -- 显示文本
      .. "  %T"              -- 结束可点击区域
      .. bg_hl
      .. "%="

    if i < total then
      if i+1 ~= current and i~=current then
        result[i] = result[i] .. "%#TabLineSeparator#│"
      else
        result[i] = result[i] .. "%#TabLineSeparator# "
      end
    end
  end

  return table.concat(result) .. "%#TabLineFill#"
end


return M
