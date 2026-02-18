local M = {}

M.lsp_file = ".nvim/lsp.json"
M.linter_file = ".nvim/linter.json"

M.find_local_settings_file = function(json_file)
  local local_settings_filepaths = vim.fs.find(json_file, {
    upward = true, -- 从 pwd 向上寻找 .nvim/settings.lua 文件.
    stop = vim.env.HOME,  -- 直到 $HOME 为止.
    type = "file",
    limit = 1, -- NOTE: 只找最近的一个文件.
  })

  if #local_settings_filepaths < 1 then
    return nil -- json 为空, 或被删除, 需要 reload lsp settings
  end

  return vim.fs.abspath(local_settings_filepaths[1])
end

return M
