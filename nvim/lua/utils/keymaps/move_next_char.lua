local M = {}

-- insert mode 下将光标后 ')' 移动到 line / word 后面
---@param m '$'|'e'|'E'
M.forward = function(m)
  local chars = { ')', ']', '}', '>', '"', "'", '`' }

  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- local curr_char = line:sub(col, col)
  local next_char = line:sub(col + 1, col + 1)

  if vim.tbl_contains(chars, next_char) then
    -- x: cut,
    -- h: left,
    -- args: $: end of line, e: end of <word>, E: end of <WORD>
    -- p: paste after cursor,
    local arg = string.format('xh%sp', m)
    vim.cmd.normal({ args={arg}, bang=true })
  end
end


-- insert mode 下将光标后 ')' 移动到 line / word 后面
---@param m '0'|'^'|'b'|'B'
M.backward = function(m)
  local chars = { '(', '[', '{', '<', '"', "'", '`' }

  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local curr_char = line:sub(col, col)
  -- local next_char = line:sub(col + 1, col + 1)

  if vim.tbl_contains(chars, curr_char) then
    -- h: left,
    -- x: cut,
    -- args: 0: begin of line, ^: begin of line, b: begin of <word>, B: begin of <WORD>
    -- P: paste before cursor,
    -- l: right
    local arg = string.format('hx%sPl', m)
    vim.cmd.normal({ args={arg}, bang=true })
  end
end

return M
