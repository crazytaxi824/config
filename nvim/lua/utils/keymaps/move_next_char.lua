local M = {}

M.move_next_char = function(m)
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local next_char = line:sub(col + 1, col + 1)

  if next_char == ')' or next_char == ']' or next_char == '}' then
    --- x: cut, h: left, p: paste
    --- args could be: $: end of line, e: end of word, E: end of WORD
    vim.cmd.normal({args={"xh".. m .."p"}, bang=true})
  end
end

return M
