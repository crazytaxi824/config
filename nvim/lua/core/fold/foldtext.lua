local M = {}

function M.foldtext()
  --- startline: VVI: replace '\t' with 'N-spaces'. 否则 \t 会被认为是一个 char, 导致 line 开头的内容部分被隐藏.
  --- N-spaces 根据 buffer 的 tabstop 决定.
  local fs = string.gsub(vim.fn.getline(vim.v.foldstart), '\t', string.rep(' ', vim.bo.tabstop))

  --- endline: trim foldend line
  local fe = vim.trim(vim.fn.getline(vim.v.foldend))

  --- 这里主要是使用 setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr() 功能.
  if vim.wo.foldmethod == 'expr' then
    return fs .. ' ' .. Nerd_icons.ellipsis .. ' ' .. fe
  end
  return fs .. ' ' .. fe
end

function M.foldtext_lsp()
  --- VVI: replace '\t' with 'N-spaces'. 否则 \t 会被认为是一个 char, 导致 line 开头的内容部分被隐藏.
  --- N-spaces 根据 buffer 的 tabstop 决定.
  local fs = string.gsub(vim.fn.getline(vim.v.foldstart), '\t', string.rep(' ', vim.bo.tabstop))
  return fs .. ' ' .. Nerd_icons.ellipsis
end

return M
