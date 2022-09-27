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
  {'n', '<F5>', '<cmd>lua require("user.ftplugin_deps.go").go_run()<CR>', opt, "code: Run"},

  {'n', '<F6>', '<cmd>lua require("user.ftplugin_deps.go").go_test_single_func()<CR>', opt, "code: Run Test/Bench (Single)"},
  {'n', '<F18>', '<cmd>lua require("user.ftplugin_deps.go").go_test_single_func(true)<CR>', opt, "code: Run Test (Package)"},   -- <S-F6>
}

Keymap_set_and_register(go_keymaps)

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
vim.api.nvim_buf_create_user_command(0, "GoTestRunPkg", 'lua require("user.ftplugin_deps.go").go_test_run_pkg()', {bang=true})
vim.api.nvim_buf_create_user_command(0, "GoTestRunProject", 'lua require("user.ftplugin_deps.go").go_test_run_proj()', {bang=true})
vim.api.nvim_buf_create_user_command(0, "GoTestBenchPkg", 'lua require("user.ftplugin_deps.go").go_test_bench_pkg()', {bang=true})
vim.api.nvim_buf_create_user_command(0, "GoTestBenchProject", 'lua require("user.ftplugin_deps.go").go_test_bench_proj()', {bang=true})



