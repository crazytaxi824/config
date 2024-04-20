local M = {}

M.toggle_comment_color = function()
  local hl_group = "Comment"
  local c = vim.api.nvim_get_hl(0, {name=hl_group})

  if c.ctermfg == Color.comment_green then
    c.ctermfg = 240
  else
    c.ctermfg = Color.comment_green
  end

  vim.api.nvim_set_hl(0, hl_group, c)
end

return M

