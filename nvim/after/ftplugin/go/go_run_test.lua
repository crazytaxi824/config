--- key mapping ------------------------------------------------------------------------------------ {{{
--- <F6> go test Run/Benchmark/Fuzz single function, No Prompt.
--- <S-F6> run test single function with options/flags
--   - go test Run Single function
--      - pprof
--      - trace
--      - coverage
--   - go test Benchmark Single function -benchtime (默认 1s)
--      - pprof
--      - trace
--      - coverage
--   - go test Fuzz Single function, -fuzztime
--      - FuzzTime 30s
--      - FuzzTime 60s
--      - FuzzTime 3m
--      - FuzzTime 6m
--      - FuzzTime 10m
--      - FuzzTime ?
-- -- }}}
local opt = { buffer = 0 }
local go_keymaps = {
  {'n', '<F5>',  function() require("utils.go").run() end, opt, "Fn 5: code: Go Run"},  -- go run
  {'n', '<F6>',  function() require("utils.go").test.single_func() end, opt, "Fn 6: code: Go Test Single"}, -- go test
  {'n', '<D-F6>', function() require("utils.go").test.single_func('pprof') end, opt, "Fn 6: code: Go Test Single Pprof"},
}

require('utils.keymaps').set(go_keymaps)

--- commands --------------------------------------------------------------------------------------- {{{
-- - go test Run current Package
--     - pprof
--     - trace
--     - coverage
-- - go test Benchmark current Package
--     - pprof
--     - trace
--     - coverage
-- - go test Run multiple packages (Project)
--     - coverage
-- - go test Benchmark multiple packages (Project)
--     - coverage
-- -- }}}
--- NOTE: 不能同时运行多个 fuzz test. Error: will not fuzz, -fuzz matches more than one fuzz test.
--- 所以这里没有设置 GoTestFuzzPackage / GoTestFuzzPorject, 使用 go_test_single_func() 来运行 Fuzz test.
vim.api.nvim_buf_create_user_command(0, "GoTestRunPkg",       function() require("utils.go").test.pkg('run') end, {bang=true})
vim.api.nvim_buf_create_user_command(0, "GoTestRunProject",   function() require("utils.go").test.proj('run') end, {bang=true})
vim.api.nvim_buf_create_user_command(0, "GoTestBenchPkg",     function() require("utils.go").test.pkg('bench') end, {bang=true})
vim.api.nvim_buf_create_user_command(0, "GoTestBenchProject", function() require("utils.go").test.proj('bench') end, {bang=true})



