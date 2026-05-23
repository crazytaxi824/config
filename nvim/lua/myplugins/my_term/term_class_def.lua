---@alias MyTermCallback fun(term: MyTerm, bufnr: integer)
---@alias MyTermCBwithJob fun(term: MyTerm, bufnr: integer, job_id: integer)
---@alias MyTermOnOutput fun(term: MyTerm, bufnr: integer, job_id: integer, data: string[])
---@alias MyTermOnExit fun(term: MyTerm, bufnr: integer, job_id: integer, exit_code: integer)



---@class MyTermOptsProps
--
-- `:help jobstart-options` cwd
---@field cwd? string
--
-- `:help jobstart-options` env
---@field env? string
--
-- goto bottom of the terminal. 在 on_stdout & on_stderr 中触发.
---@field auto_scroll? boolean
--
-- true: 在 console 中执行; false: 在 terminal 中执行.
---@field console_output? boolean



---@class MyTermOptsCallbacks
--
-- BufWinEnter. NOTE: 每次 term:// buffer 被 win 显示的时候都会触发, 同一个 buffer 被多个窗口显示时也会触发.
---@field on_open?    MyTermCallback
--
-- BufWinLeave. NOTE: BufWinLeave 只会在 buffer 离开最后一个 win 的时候触发.
---@field on_close?   MyTermCallback
--
-- before jobstart(), term:run() 时触发
---@field on_init? MyTermCallback
--
-- after jobstart() is running successfully, doesn't matter job finishes or not
---@field on_start? MyTermCBwithJob
--
-- jobstart() 中 callback 函数
---@field on_stdout? MyTermOnOutput
--
-- jobstart() 中 callback 函数
---@field on_stderr? MyTermOnOutput
--
-- jobstart() 中 callback 函数
---@field on_exit?   MyTermOnExit



---@class MyTermOptsCallbackList
--
-- BufWinEnter. NOTE: 每次 term:// buffer 被 win 显示的时候都会触发, 同一个 buffer 被多个窗口显示时也会触发.
---@field on_open?    MyTermCallback[]
--
-- BufWinLeave. NOTE: BufWinLeave 只会在 buffer 离开最后一个 win 的时候触发.
---@field on_close?   MyTermCallback[]
--
-- before jobstart(), term:run() 时触发
---@field on_init? MyTermCallback[]
--
-- after jobstart() is running successfully, doesn't matter job finishes or not
---@field on_start? MyTermCBwithJob[]
--
-- jobstart() 中 callback 函数
---@field on_stdout? MyTermOnOutput[]
--
-- jobstart() 中 callback 函数
---@field on_stderr? MyTermOnOutput[]
--
-- jobstart() 中 callback 函数
---@field on_exit?   MyTermOnExit[]



---@class MyTermOpts: MyTermOptsProps, MyTermOptsCallbacks

-- NOTE: for MyTerm internal use only
---@class MyTermInternalOpts: MyTermOptsProps, MyTermOptsCallbackList

