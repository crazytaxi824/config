local M = {}

--- 通过 my_term console 运行 `go test`
---
--- @param cmd? string|string[]
--- @param term_opts MyTermOpts
function M.go_test(cmd, term_opts)
  if not cmd then
    return
  end

  --- my_term 执行 command
  local t = require('myplugins.my_term').console()
  t:update(term_opts)
  t:stop()
  t:run(cmd)
end

return M
