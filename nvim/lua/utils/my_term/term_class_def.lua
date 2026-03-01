--- @alias MyTermCallback fun(term: MyTerm, bufnr: integer)
--- @alias MyTermCBWithJob fun(term: MyTerm, bufnr: integer, job_id: integer)
--- @alias MyTermOnOutput fun(term: MyTerm, bufnr: integer, job_id: integer, data: string[])
--- @alias MyTermOnExit fun(term: MyTerm, bufnr: integer, job_id: integer, exit_code: integer)


--- MyTermOpts
--- @class MyTermOpts
---
--- `:help jobstart()` cmd
--- @field cmd? string|string[]
---
--- `:help jobstart-options` cwd
--- @field cwd? string
---
--- `:help jobstart-options` env
--- @field env? string
---
--- goto bottom of the terminal. 在 on_stdout & on_stderr 中触发.
--- @field auto_scroll? boolean
---
--- true: 在 console 中执行; false: 在 terminal 中执行.
--- @field console_output? boolean
---
--- term:run() 时触发. before jobstart().
--- @field before_run? MyTermCallback
---
--- term:run() 时触发. 在 jobstart() 之后马上执行, 和 on_exit 的区别是不用等到 jobdone.
--- @field after_run?  MyTermCBWithJob
---
--- BufWinEnter. NOTE: 每次 term:// buffer 被 win 显示的时候都会触发, 同一个 buffer 被多个窗口显示时也会触发.
--- @field on_open?    MyTermCallback
---
--- BufWinLeave. NOTE: BufWinLeave 只会在 buffer 离开最后一个 win 的时候触发.
--- @field on_close?   MyTermCallback
---
--- jobstart() 中 callback 函数
--- @field on_stdout? MyTermOnOutput
---
--- jobstart() 中 callback 函数
--- @field on_stderr? MyTermOnOutput
---
--- jobstart() 中 callback 函数
--- @field on_exit?   MyTermOnExit



--- MyTerm 继承 MyTermOpts
---
--- @class MyTerm: MyTermOpts
---
--- VVI: 保证每个 id 只和一个 bufnr 对应. id 一旦设置应该无法改变.
--- @field id integer @readonly
---
--- jobstart(cmd, { env, cwd, on_stdout, on_stderr, on_exit, ... })
--- @field run fun(self: MyTerm) @readonly
---
--- jobstop(job_id)
--- @field stop fun(self: MyTerm) @readonly



--- MyTermPost 继承自 MyTerm
--- @class MyTermPost: MyTerm  继承 MyTerm
---
--- MyTerm jobstart() 时使用的 buffer
--- @field bufnr integer
---
--- MyTerm jobstart() 的 job_id
--- @field job_id integer
