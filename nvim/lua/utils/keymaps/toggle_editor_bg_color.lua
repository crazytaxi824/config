--- toggle editor background color by setting 'Normal' & 'NormalNC'

local M = {}

M.toggle_background_color = function()
  local c = vim.api.nvim_get_hl(0, {name="Normal"})
  if c.ctermbg == Colors.g234.c then
    c.ctermbg, c.bg = nil, nil
    vim.api.nvim_set_hl(0, "Normal", c)
    vim.api.nvim_set_hl(0, "NormalNC", {link="Normal"})
    vim.api.nvim_set_hl(0, "VertSplit", {ctermfg=236, fg='#303030'})
  else
    c.ctermbg, c.bg = Colors.g234.c, Colors.g234.g
    vim.api.nvim_set_hl(0, "Normal", c)
    vim.api.nvim_set_hl(0, "NormalNC", {ctermbg=235, bg='#262626'})
    vim.api.nvim_set_hl(0, "VertSplit", {
      ctermfg=237, fg='#3a3a3a',
      ctermbg=235, bg='#262626',
    })
  end
end

return M
