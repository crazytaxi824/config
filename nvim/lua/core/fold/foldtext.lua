local M = {}

-- `:help fold-foldtext`
-- 设置位置在 `core/options.lua`
--
---@return string
function M.foldtext()
  -- startline: VVI: replace '\t' with 'N-spaces'. 否则 \t 会被认为是一个 char, 导致 line 开头的内容部分被隐藏.
  -- N-spaces 根据 buffer 的 tabstop 决定.
  local fs = string.gsub(vim.fn.getline(vim.v.foldstart), '\t', string.rep(' ', vim.bo.tabstop))

  if vim.wo.foldmethod == 'marker' then
    -- 'foldmarker' There must be one comma, which separates the start and end marker.
    local sp = vim.split(vim.wo.foldmarker, ",", {trimempty=true})
    return fs .. ' ' .. Nerd_icons.ellipsis .. ' ' .. sp[2]
  elseif vim.wo.foldmethod == 'expr' then
    -- vim.treesitter.foldexpr() 中 vim.v.foldend 是函数倒数第一行的 line nunmber
    -- vim.lsp.foldexpr() 中 vim.v.foldend 是函数倒数第二行的 line nunmber
    return fs .. ' ' .. Nerd_icons.ellipsis
  elseif vim.wo.foldmethod == 'diff' then
    return fs .. ' ' .. Nerd_icons.ellipsis
  end

  -- default setting, for 'fold-syntax', 'fold-indent'
  local fe = vim.trim(vim.fn.getline(vim.v.foldend))  -- endline: trim foldend line
  return fs .. ' ' .. Nerd_icons.ellipsis .. ' ' .. fe
end

return M
