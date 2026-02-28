--- go test flags: pprof, cover, fuzz

--- @class GoTestFlag
---
--- 可选 flags 和 description
--- @field flag_desc table<string, table>
---
--- 根据 GoTestOpts 生成 MyTermOpts 用于执行
--- @field term_opts fun(self: GoTestFlag, opts: GoTestOpts): MyTermOpts

