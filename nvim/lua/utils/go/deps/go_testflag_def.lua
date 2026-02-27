--- go test flags: pprof, cover, fuzz

--- @class GoTestFlag
--- @field flags fun(): string[]
--- @field contains fun(flag: string): boolean|nil
--- @field get_description fun(flag: string): string
--- @field term_opts fun(opts: GoTestOpts): MyTermOpts

