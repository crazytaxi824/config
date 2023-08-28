--- toggle editor background color by setting 'Normal' & 'NormalNC'

local M = {}

M.toggle_background_color = function()
  local c = vim.api.nvim_get_hl(0, {name="Normal"})
  if c.ctermbg == 234 then
    c.ctermbg = nil
    vim.api.nvim_set_hl(0, "Normal", c)
    vim.api.nvim_set_hl(0, "NormalNC", {link="Normal"})
    vim.api.nvim_set_hl(0, "VertSplit", {ctermfg=236})
  else
    c.ctermbg = 234
    vim.api.nvim_set_hl(0, "Normal", c)
    vim.api.nvim_set_hl(0, "NormalNC", {ctermbg=235})
    vim.api.nvim_set_hl(0, "VertSplit", {ctermfg=237, ctermbg=235})
  end
end

return M
