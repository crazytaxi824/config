--- go test flags: pprof, cover, fuzz

--- @class GoTestFlag
---
--- 可选 flag description
--- @field desc string
---
--- 根据 GoTestOpts 生成 MyTermOpts 用于执行
--- @field term_opts fun(opts: GoTestOpts): MyTermOpts

