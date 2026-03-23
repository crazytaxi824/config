--- @class WinbarLineBuffer
--- @field bufnr integer
--- @field private win_dict table<integer, boolean>
--- @field diagnostic? {count: integer, severity: integer}
local M = {}
M.__index = M

---@param bufnr integer
---@param win_id integer
---@return WinbarLineBuffer
function M.new(bufnr, win_id)
  local self = setmetatable({
    bufnr = bufnr,
    wins = { [win_id] = true },
  }, M)
  return self
end

---@param win_id integer
function M:append_win(win_id)
  self.win_dict[win_id] = true
end

---@param win_id integer
function M:remove_win(win_id)
  self.win_dict[win_id] = nil
end

--- @return integer[]  win_ids
function M:list_wins()
  return vim.tbl_keys(self.win_dict)
end

--- @return string  bufname
function M:name()
  local bufname = vim.api.nvim_buf_get_name(self.bufnr)
  if bufname ~= '' then
    return bufname
  end

  --- 以下是特殊情况
  if vim.fn.getcmdwintype() ~= '' then
    return "[Command Line]"
  end

  local bt = vim.bo[self.bufnr].buftype
  if bt == "quickfix" then
    return "[List]"
  elseif bt == "nofile" then
    return "[Scratch]"
  elseif bt == "terminal" then
    return "[Terminal]"
  elseif bt == "prompt" then
    return "[Prompt]"
  elseif bt == "help" then
    return "[Help]"
  else
    return "[No Name]"  -- buftype == ''
  end
end

--- 更新 diagnostic info
function M:update_diagnostic()
  local diagnostics = vim.diagnostic.count(self.bufnr) or {}
  local diag_count = 0
  local severity = 9
  for s, c in pairs(diagnostics) do
    diag_count = diag_count + c

    if s < severity then
      severity = s
    end
  end

  if diag_count > 0 then
    self.diagnostic = { count = diag_count, severity = severity }
  else
    self.diagnostic = nil
  end
end

return M
