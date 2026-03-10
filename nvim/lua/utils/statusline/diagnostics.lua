--- @alias DiagnosticCount { hint: integer, info: integer, warn: integer, error: integer }


local M = {}

--- @return DiagnosticCount
function M.diagnostics()
  --- @type DiagnosticCount
  local result = {
    hint = 0,
    info = 0,
    warn = 0,
    error = 0,
  }

  local diags = vim.diagnostic.get(0)
  for _, diag in ipairs(diags) do
    if diag.severity == vim.diagnostic.severity.HINT then
      result.hint = result.hint + 1
    elseif diag.severity == vim.diagnostic.severity.INFO then
      result.info = result.info + 1
    elseif diag.severity == vim.diagnostic.severity.WARN then
      result.warn = result.warn + 1
    elseif diag.severity == vim.diagnostic.severity.ERROR then
      result.error = result.error + 1
    end
  end

  return result
end

-- TODO: 触发更新的时机
-- vim.api.nvim_create_autocmd("DiagnosticChanged", {
--     callback = function()
--         -- 更新 diagnostic counts
--         vim.schedule(function()
--             vim.cmd("redrawstatus")
--         end)
--     end
-- })

return M
