--- VVI: 这里不能直接使用 `require(xxx).gorun` 否则会报错.
--- 因为 require 的时候会需要 load tool_gotests. 而 gotests 中需要加载 require toggleterm.
--- 但是 toggleterm 是 lazyload, 所以加载 tool_gotests 的时候 toggleterm 还没加载, 造成报错.
--- NOTE: 可以使用 string `<cmd>lua require() ... <CR>` 或者 `function() require() ... end`.

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
local opt = {noremap = true, buffer = true}
local go_keymaps = {
  {'n', '<F5>',  function() require("user.ftplugin_deps.go").go_run() end, opt, "code: Go Run"},  -- go run
  {'n', '<F6>',  function() require("user.ftplugin_deps.go").go_test_single_func() end, opt, "code: Go Test Single"}, -- go test
  {'n', '<F18>', function() require("user.ftplugin_deps.go").go_test_single_func(true) end, opt, "code: Go Test Single Pprof"},  -- <S-F6>
}

require('user.utils.keymaps').set(go_keymaps)

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
vim.api.nvim_buf_create_user_command(0, "GoTestRunPkg",       function() require("user.ftplugin_deps.go").go_test_run_pkg() end, {bang=true})
vim.api.nvim_buf_create_user_command(0, "GoTestRunProject",   function() require("user.ftplugin_deps.go").go_test_run_proj() end, {bang=true})
vim.api.nvim_buf_create_user_command(0, "GoTestBenchPkg",     function() require("user.ftplugin_deps.go").go_test_bench_pkg() end, {bang=true})
vim.api.nvim_buf_create_user_command(0, "GoTestBenchProject", function() require("user.ftplugin_deps.go").go_test_bench_proj() end, {bang=true})



