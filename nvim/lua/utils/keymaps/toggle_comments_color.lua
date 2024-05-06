local M = {}

local dim_color = { ctermfg=238 }

local comment_hl_groups = {
  "Comment",
  "Todo",

  "@comment.todo",
  "@comment.note",
  "@comment.warning",
  "@comment.error",
}

M.toggle_comment_color = function()
  local comm = vim.api.nvim_get_hl(0, {name="Comment"})

  if comm.ctermfg == Highlights["Comment"].ctermfg then
    for _, hl in ipairs(comment_hl_groups) do
      vim.api.nvim_set_hl(0, hl, dim_color)
    end
  else
    for _, hl in ipairs(comment_hl_groups) do
      vim.api.nvim_set_hl(0, hl, Highlights[hl])
    end
  end
end

return M

