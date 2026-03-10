local M = {}

function M.git_branch()
  --- 异步函数, 不要同步阻塞等待刷新 statusline
  vim.system({"git", "branch", "--show-current"}, { text = true }, function(result)
    --- 如果 git 不存在时 exit_code 不为 0
    if result.code ~= 0 then
      return
    end

    --- git_branch 可能为 ""
    local git_branch = result.stdout:gsub("\n", "")
    vim.schedule(function()
      --- TODO: 在 statusline 中插入 git_branch
      --set statusline = ...
      print(git_branch)

      --- 刷新 statusline
      vim.cmd.redrawstatus()
    end)
  end)
end

-- TODO: 触发更新的时机
-- vim.api.nvim_create_autocmd({"BufEnter", "FocusGained"}, {
--     callback = M.git_branch()
-- })

return M
