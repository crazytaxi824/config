--- go test flags: pprof, cover, fuzz

--- @class GoTestFlag
---
--- 可选 flag description
--- @field desc string
---
--- 根据 GoTestOpts 生成 MyTermOpts 用于执行
--- @field term_opts fun(opts: GoTestOpts): MyTermOpts


--- @class GoTestFlagDict
---
--- 可选 flag 排序, elem 必须为 `GoTestFlagDict.flags` 中的 keys
--- @field list string[]
---
--- 所有的 GoTestFlag
--- @field flags table<string, GoTestFlag>
