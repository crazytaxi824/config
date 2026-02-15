local M = {}

--- NOTE: vim.treesitter.foldexpr() 中 vim.v.foldend 是函数倒数第一行的 line nunmber
function M.foldtext()
  --- startline: VVI: replace '\t' with 'N-spaces'. 否则 \t 会被认为是一个 char, 导致 line 开头的内容部分被隐藏.
  --- N-spaces 根据 buffer 的 tabstop 决定.
  local fs = string.gsub(vim.fn.getline(vim.v.foldstart), '\t', string.rep(' ', vim.bo.tabstop))

  --- endline: trim foldend line
  local fe = vim.trim(vim.fn.getline(vim.v.foldend))

  if vim.wo.foldmethod == 'expr' then
    return fs .. ' ' .. Nerd_icons.ellipsis .. ' ' .. fe
  end
  return fs .. ' ' .. fe
end

--- NOTE: vim.lsp.foldexpr() 中 vim.v.foldend 是函数倒数第二行的 line nunmber, 所以 foldtext 需要不同设置.
function M.foldtext_lsp()
  --- VVI: replace '\t' with 'N-spaces'. 否则 \t 会被认为是一个 char, 导致 line 开头的内容部分被隐藏.
  --- N-spaces 根据 buffer 的 tabstop 决定.
  local fs = string.gsub(vim.fn.getline(vim.v.foldstart), '\t', string.rep(' ', vim.bo.tabstop))
  return fs .. ' ' .. Nerd_icons.ellipsis
end

return M
