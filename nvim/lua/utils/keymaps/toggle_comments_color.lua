local M = {}

local comment_hl_groups = {
  "@comment.todo",
  "@comment.note",
  "@comment.warning",
  "@comment.error",
  "@string.special.url.comment"
}

M.toggle_comment_color = function()
  local c = vim.api.nvim_get_hl(0, {name="Comment"})

  if c.ctermfg == Color.comment_green then
    vim.api.nvim_set_hl(0, "Comment", {ctermfg = 238})
    for _, hl in ipairs(comment_hl_groups) do
      vim.api.nvim_set_hl(0, hl, {}) -- {} 意思是 clear highlight
    end
  else
    vim.api.nvim_set_hl(0, "Comment", Highlights["Comment"])
    for _, hl in ipairs(comment_hl_groups) do
      vim.api.nvim_set_hl(0, hl, Highlights[hl])
    end
  end
end

return M

