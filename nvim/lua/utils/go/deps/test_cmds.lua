local M = {}

--- 通过 my_term console 运行 `go test`
---
--- @param term_opts MyTermOpts
function M.go_test(term_opts)
  --- my_term 执行 command
  local t = require('utils.my_term').console()
  t.cmd = term_opts.cmd
  t.cwd = term_opts.cwd
  t.before_run = term_opts.before_run
  t.on_exit = term_opts.on_exit
  t:stop()
  t:run()
end

return M
