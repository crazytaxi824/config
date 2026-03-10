local M = {}

function M.git_branch()
  --- 异步函数, 不要同步阻塞等待刷新 statusline
  vim.system({"git", "branch", "--show-current"}, { text = true }, function(result)
    local git_branch
    if result.code ~= 0 then
      git_branch = ""
      return
    end
    --- git_branch 可能为 ""
    git_branch = result.stdout:gsub("\n", "")
    vim.schedule(function()
      --- TODO: 在 statusline 中插入 git_branch
      --set statusline = ...
      vim.cmd.redrawstatus()
    end)
  end)
end

return M
