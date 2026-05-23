-- go test flags: pprof, cover, fuzz

---@class GoTestFlag
--
-- 可选 flag description
---@field desc string
--
-- 根据 GoTestOpts 生成 MyTermOpts 用于执行
-- 如果 cmd = nil 则不运行
---@field term_opts fun(opts: GoTestOpts): string[]|nil, MyTermOpts



---@class GoTestFlagDict
--
-- 可选 flag 排序, elem 必须为 `GoTestFlagDict.flags` 中的 keys
---@field list string[]
--
-- 所有的 GoTestFlag
---@field flags table<string, GoTestFlag>



---@class GoTestOpts
--
-- 函数名 `^Test.*`, `^Benchmark.*` ...
---@field testfn_name string
--
-- go test -run | -bench | -fuzz
---@field mode 'run' | 'bench' | 'fuzz'
--
-- 'none' | 'cpu' | 'mem' | ...
---@field flag string
--
-- `go list -json`
---@field go_list table
--
-- 标记是否运行整个 project 所有 test
---@field project? string|boolean


