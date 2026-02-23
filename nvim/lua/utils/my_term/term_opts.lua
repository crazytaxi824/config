---@alias MyTermOptsCB fun(term_opts: MyTermOpts)
---@alias MyTermOptsCBWithBufnr fun(term_opts: MyTermOpts, bufnr: integer)
---@alias MyTermOptsOnOutput fun(term_opts: MyTermOpts, bufnr: integer, job_id: integer, data: string[])
---@alias MyTermOptsOnExit fun(term_opts: MyTermOpts, bufnr: integer, job_id: integer, exit_code: integer)


--- MyTermOpts
---@class MyTermOpts
---@field id integer @readonly    VVI: 保证每个 id 只和一个 bufnr 对应. id 一旦设置应该无法改变.
---@field cmd? string|string[]    `:help jobstart()` cmd
---@field cwd? string             `:help jobstart-options` cwd
---@field env? string             `:help jobstart-options` env
---@field auto_scroll? boolean    goto bottom of the terminal. 在 on_stdout & on_stderr 中触发.
---@field console_output? boolean true: 在 console 中执行; false: 在 terminal 中执行.
---
---以下是 callback functions
---@field before_run? MyTermOptsCB           term:run() 时触发. before jobstart().
---@field after_run?  MyTermOptsCBWithBufnr  term:run() 时触发. 在 jobstart() 之后马上执行, 和 on_exit 的区别是不用等到 jobdone.
---@field on_open?    MyTermOptsCBWithBufnr  BufWinEnter. NOTE: 每次 term:// buffer 被 win 显示的时候都会触发, 同一个 buffer 被多个窗口显示时也会触发.
---@field on_close?   MyTermOptsCBWithBufnr  BufWinLeave. NOTE: BufWinLeave 只会在 buffer 离开最后一个 win 的时候触发.
---
---@field on_stdout? MyTermOptsOnOutput
---@field on_stderr? MyTermOptsOnOutput
---@field on_exit?   MyTermOptsOnExit

