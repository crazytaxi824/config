[toc]

v0.10.0_beta for neovim v0.10.0

# neovim 配置

## References

- https://github.com/glepnir/nvim-lua-guide-zh
- https://github.com/LunarVim/Neovim-from-scratch
- https://github.com/LunarVim/LunarVim
- https://github.com/LazyVim/LazyVim
- https://github.com/AstroNvim/AstroNvim

<br />

## 配置文件结构

1. neovim 几个常用路径: `:help stdpath()`

- `vim.env.PATH` - vim 中的 `$PATH` 设置, 可以使用 `lua print(vim.env.PATH)` 查看. 默认和 shell 的 `echo $PATH` 相同. 也可以自行设置, eg: `mason.nvim` 插件就将自己的 tools_path 添加到 `vim.env.PATH` 的最前面.

- `stdpath("config")` = `~/.config/nvim/`, 配置文件主要路径.

- `stdpath("data")` = `~/.local/share/nvim/`, 插件安装路径.

- `stdpath("state")` = `~/.local/state/nvim/`, undo, shada, swap ...

- `stdpath("log")` = `~/.local/state/nvim/`, 目前只有 nvim-log. 目前和 `stdpath("state")` 路径相同.

- `stdpath("cache")` = `~/.cache/nvim/`, temporary storage for plugins. 目前 plugins 用于储存 log 文件, 以后可能会移到
  `stdpath("log")` 地址下.

2. neovim 启动时会首先执行 runtimepath (`:set runtimepath?`) 中的 `init.lua` 文件. 即 `~/.config/nvim/init.lua` 文件.
   然后根据 `init.lua` 文件中的 `require("xxx")` 在所有的 runtimepath 中查找对应的文件.

3. require 使用:

   - 加载 ~/.config/nvim/lua/user/options.lua 单个文件, `require("user.options")` OR `require("user/options")` 省略 `.lua`

   - 加载 ~/.config/nvim/lua/user/lsp/ 文件夹. 首先 lsp 文件夹中必须有 init.lua 文件, 然后使用 `require("user/lsp")` 直接加载整个 lsp 文件夹.

4. `after/ftplugin`, `after/syntax`, `ftplugin` 和 `syntax` 作用几乎一样, 却别在于:

   - `after/ftplugin` 是针对文件的 filetype, 而 `after/syntax` 是针对文件的 syntax. eg: json 文件 filetype 是 json, 而 syntax 可以为 jsonc.

   - `after/ftplugin` 在 `after/syntax` 之前加载.

```
~/.config/nvim/
├── after
│   ├── ftplugin  <- 根据 filetype 加载.
│   └── plugin
├── lua
│   └── user      <- 其他配置文件位置, settings, color, plugin.setup()
├── plugin
│   └── packer_compiled.lua  <- packer 插件管理自动生成的文件.
├── filetype.lua  <- filetype 设置文件, eg: json -> jsonc
├── init.lua      <- 主入口
...
```

<br />

## 优化 nvim 启动时间

`$ nvim --startuptime log src/main.go` 在 ./log 文件中打印 nvim 启动时间详情. 其中 `.../packer_compiled.lua` & `opening buffers`
耗时是最长的.

<br />

# VIM Mode

`:help vim-modes` & `:help mode()`

| Name                                  | keymap                                      |
| ------------------------------------- | ------------------------------------------- |
| Normal                                | `{i,v,c}_CTRL-C`, `{i,v,c,t}_CTRL-\_CTRL-N` |
| Normal using i_CTRL-O in Insert-mode  | `i_CTRL-O`, `i_CTRL-\_CTRL-O`               |
| Insert                                | `a`, `i`, `s`, `o`, `c` ...                 |
| Replace                               | `R`                                         |
| Command                               | `:`, `!!` ...                               |
| Visual by character                   | `v` (lower)                                 |
| Visual by line                        | `V` (upper)                                 |
| Visual by block                       | `CTRL-V`                                    |
| Select by character                   | `v(lower)_CTRL-G`, `gh`                     |
| Select by line                        | `V(upper)_CTRL-G`, `gH`                     |
| Select by block                       | `CTRL-V_CTRL-G`, `g<CTRL-H>`                |
| Terminal (insert) mode                | `t_CTRL-\_CTRL-N`, `t_CTRL-\_CTRL-O`        |

<br />

# autocmd 无法链式反应

猜测是为了安全性, 防止 autocmd 无限循环造成内存泄漏.

在 autocmd 中执行的命令/函数无法触发另一个 autocmd. eg:

```vim
au BufDelete <buffer=1> :bdelete 2
au BufDelete <buffer=2> :lua print(2)
```

由于 `:bdelete 2` 是在 autocmd 中执行的, 所以无法触发第二个 autocmd. 造成 buffer 2 被删除, 但是 `print(2)` 却没有执行.

<br />

# neovim lua 使用

## lua 全局变量 `_G`

lua 中有一个 `_G` 全局变量. 自定义的所有全局变量和函数都会被放在 `_G` 内.
例如:

- 自定义了 `__Proj_local_settings` 变量, 则可以使用 `__Proj_local_settings` 或者 `_G.__Proj_local_settings` 访问.

- 自定义全局函数 `Notify()`, 则可以使用 `Notify()`, 或者 `_G.Notify()` 调用函数.

<br />

## 常用函数

### lua 常用函数

- `pcall(vim.api.nvim_exec2, "normal! n", {output=false})` -- 获取 command 返回信息, 相当于执行 pcall(vim.cmd, ...)

- `dofile(file/path)` -- lua execute file.

- `table.insert({list}, elem)` -- 向 list 中插入元素

- `table.concat({list}, "sep")` -- 类似 strings.Join()

- `string.gsub("a b c", " ", "\\%%")` -- 类似 strings.Replace()

### nvim 常用函数

- VVI: `vim.api.nvim_buf_call()` 在指定 buffer 中运行指令. eg: `vim.api.nvim_buf_call(bufnr, function() vim.cmd("normal! G") end)`
  如果 bufnr 被任意 window 显示, 则直接使用该 window 执行指令. 类似 win_gotoid() 执行完之后再跳回当前 window.
  如果 bufnr 是 hidden buffer 则运行前会创建一个临时 autocmd window 用于执行任务, 这时在 `nvim_buf_call()` 中无法获取到真实 window id.

- `vim.inspect(table)` & `vim.print(table)` -- 打印 table 中的内容, 类似 fmt.Printf("%+v", struct)

- `vim.list_extend({list1}, {list2})` -- 合并两个 list-like table

- `vim.tbl_deep_extend("force", {map1}, {map2}, {map3}...)` -- 合并多个 map-like table

- `vim.split({string}, {sep}, {trimempty})` -- strings.Split()

### vim 自带函数

- `vim.fn.feedkeys("\<CR>", 'nx')` -- VVI: 模拟输入 <CR>. 注意单/双引号: `feedkeys("\<CR>", 'nx')` simulates pressing of the <Enter> key. But `feedkeys('\<CR>')` pushes 5 characters.

- `vim.api.nvim_feedkeys()`  -- neovim API

```lua
-- vim.cmd('normal! G')
vim.keymap.set('i', '<M-b>', function()
  -- 使用 nvim_feedkeys(), NOTE: typehead 可以看作是一个 cache, 储存输入的内容. 等到输入全部完成之后再一起执行.
  -- 'n' - append input
  -- 'i' - insert (prepend) input
  -- 'x' - Execute until typeahead is empty. similar to using ":normal!"

  -- 向 cache 中 append 'hello' with 'noremap' opt.
  vim.api.nvim_feedkeys('hello', 'n', true)

  -- 向 cache 中 prepend 'a' (start INSERT mode) with 'noremap' opt.
  vim.api.nvim_feedkeys('a', 'in', true)

  -- lua way to enter <CR>
  -- in vim: call feedkeys("\<CR>", 'n'), needs to use double-quote.
  local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
  vim.api.nvim_feedkeys(cr, 'n', false)

  --- execute <ESC> after previous command is executed.
  local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(esc, 'x', false)
end,
{
  silent = true,
  desc = 'Test Options-B',
})
```

- `vim.fn.json_encode(table)` / `vim.fn.json_decode(string)` -- json 处理.

- `vim.fn.split()` -> `vim.split()`

- `vim.fn.join({list}, sep)` -> `vim.Iter():join()`

- `vim.fn.trim()`  -> `vim.trim()`

### vim - window / tab / buffer 函数

NOTE: 这些函数中没有 del() 方法. 原因是: 当 buffer/win/tab close 的时候, 所有的 var 都会被清空.

getXXXinfo()

- `vim.fn.getwininfo()`

- `vim.fn.gettabinfo()`

- `vim.fn.getbufinfo()` / `vim.fn.getbufinfo({buflisted = 1})`

getXXXvar() / setXXXvar()

- `vim.fn.getwinvar()` / `vim.fn.setwinvar()`

- `vim.fn.getbufvar()` / `vim.fn.setbufvar()`

- `vim.fn.gettabvar()` / `vim.fn.settabvar()`

XXX number

- `vim.fn.bufnr()` / `vim.fn.bufname()`

- `vim.fn.winnr()` / `vim.fn.win_getid()` / `vim.fn.win_gotoid()`

- `vim.fn.tabpagenr()` / `vim.fn.tabpagebuflist()` / `vim.fn.tabpagewinnr()`

### nvim.api - win / tab / buffer var

get var

| vimL                           | vimL variables (1) | lua vim api                        | lua vim variables        |
| ------------------------------ | ------------------ | ---------------------------------- | ------------------------ |
| getbufvar(bufnr, 'foo')        | echo b:foo         | nvim_buf_get_var(bufnr, 'foo')     | print(vim.b[bufnr].foo)  |
| getwinvar(winnr/win_id, 'foo') | echo w:foo         | nvim_win_get_var(win_id, 'foo')    | print(vim.w[win_id].foo) |
| gettabvar(tabnr, 'foo')        | echo t:foo         | nvim_tabpage_get_var(tabnr, 'foo') | print(vim.t[tabnr].foo)  |

set var

| vimL                                  | vimL variables (1) | lua vim api                               | lua vim variables       |
| ------------------------------------- | ------------------ | ----------------------------------------- | ----------------------- |
| setbufvar(bufnr, 'foo', 'bar')        | let b:foo='bar'    | nvim_buf_set_var(bufnr, 'foo', 'bar')     | vim.b[bufnr].foo='bar'  |
| setwinvar(winnr/win_id, 'foo', 'bar') | let w:foo='bar'    | nvim_win_set_var(win_id, 'foo', 'bar')    | vim.w[win_id].foo='bar' |
| settabvar(tabnr, 'foo', 'bar')        | let t:foo='bar'    | nvim_tabpage_set_var(tabnr, 'foo', 'bar') | vim.t[tabnr].foo='bar'  |

delete var

| lua vim api                        | lua vim variables     |
| ---------------------------------- | --------------------- |
| nvim_buf_del_var(bufnr, 'foo')     | vim.b[bufnr].foo=nil  |
| nvim_win_del_var(win_id, 'foo')    | vim.w[win_id].foo=nil |
| nvim_tabpage_del_var(tabnr, 'foo') | vim.t[tabnr].foo=nil  |

get option - 必须是 local to buffer 的属性.

| vimL                             | vimL variables (1) | lua vim api                            | lua vim variables             |
| -------------------------------- | ------------------ | -------------------------------------- | ----------------------------- |
| getbufvar(bufnr, '&filetype')    | set filetype?      | nvim_buf_get_option(bufnr, 'filetype') | print(vim.bo[bufnr].filetype) |
| getwinvar(winnr/win_id, '&wrap') | set wrap?          | nvim_win_get_var(win_id, 'wrap')       | print(vim.wo[win_id].wrap)    |

set option

| vimL                                     | vimL variables (1) | lua vim api                                   | lua vim variables            |
| ---------------------------------------- | ------------------ | --------------------------------------------- | ---------------------------- |
| setbufvar(bufnr, '&filetype', 'lua')     | set filetype=lua   | nvim_buf_set_option(bufnr, 'filetype', 'lua') | vim.bo[bufnr].filetype='lua' |
| setwinvar(winnr/win_id, '&wrap', v:true) | set wrap           | nvim_win_get_var(win_id, 'wrap', true)        | vim.wo[win_id].wrap=true     |

> (1) vimL variables 需在对应的 buffer/window/tab 中使用.

==还有很多 nvim.api 函数和 vim 的函数对应.==

### nvim async 函数

- `vim.schedule(callback)` -- async 执行 callback.

- `vim.defer_fn(callback, delay)` -- 延迟执行 callback. delay 单位是 ms.

### lua 运行 shell cmd, 获取 output.

```lua
local result = vim.fn.system(cmd)
if vim.v.shell_error ~= 0 then
  print(vim.trim(result))
  return
end

local handle = io.popen(cmd)
local result = handle:read("a")  -- "a" - read all output
handle:close()

--- 运行多个 join cmd
cmd = {'sh','-c', 'cd src; ls'}

--- sync run
local result = vim.system({cmd}, {text=true}):wait()
if result.code ~= 0 then
  error(result.stderr)
end

--- async run
vim.system({cmd}, {text=true}, function(result)
  vim.print(result)
  print(result.code)
  print(result.stdout)
  print(result.stderr)
end)
```

### lua 运行 shell cmd, 获取 exit code.

`local exit_code = os.execute(cmd)`

<br />

## lua 转义符 %

```lua
local matches = {
  ["^"] = "%^";
  ["$"] = "%$";
  ["("] = "%(";
  [")"] = "%)";
  ["%"] = "%%";
  ["."] = "%.";
  ["["] = "%[";
  ["]"] = "%]";
  ["*"] = "%*";
  ["+"] = "%+";
  ["-"] = "%-";
  ["?"] = "%?";
}
```

其他转义: `\n`, `\t`, `\r` ...

<br />

## filter 操作

using filter, `:help filter` 使用方法:

### Normal mode

1. 在行内写入 shell 代码. `cal -h -3`

2. filter command, `!!` == `:.!`, 进入 (filter) command 模式.

   - `.` 表示当前行.
   - `!` 表示后面是 shell command.

3. `:.!` 后输入 bash, cat, grep ... 等支持 pipe 的 shell command.

4. 如果不支持 pipe 的命令需要使用 `xargs` 来传递参数. 例如 `echo`, 需要使用 `echo "omg" | xargs echo`

### Visual mode

也可以在 visual select 之后, 按 `!`, 进入 (filter) command 模式 `:'<,'>!`

### 其他例子:

| line                         | cmd                                     | output                |
| ---------------------------- | --------------------------------------- | --------------------- |
| line: './src/main.go'        | cmd: `:.!cat`                           | 输出 './src/main.go'  |
| line: './src/main.go'        | cmd: `:.!xargs echo`                    | 输出 './src/main.go'  |
| line: './src/main.go',       | cmd: `:.!xargs cat`                     | 输出文件内容          |
| line: 'cat ./src/main.go',   | cmd: `:.!bash`                          | 输出文件内容          |
| line: 'cal -h -3',           | cmd: `:.!bash`                          | 输出日历              |
| line: 'a/b/c',               | cmd: `:.!awk -F/ '{print $1}'`          | 输出 'a'.             |
| 3-line: 'abc', 'ccc', 'ddd', | visual select 之后 cmd: `:'<,'>!grep c` | 输出两行 'abc', 'ccc' |

```
cal -h -3

!!bash

      May 2022             June 2022             July 2022
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
 1  2  3  4  5  6  7            1  2  3  4                  1  2
 8  9 10 11 12 13 14   5  6  7  8  9 10 11   3  4  5  6  7  8  9
15 16 17 18 19 20 21  12 13 14 15 16 17 18  10 11 12 13 14 15 16
22 23 24 25 26 27 28  19 20 21 22 23 24 25  17 18 19 20 21 22 23
29 30 31              26 27 28 29 30        24 25 26 27 28 29 30
                                            31
```

<br />

## 多行数字增加 `Ctrl-a` 和数字减少 `Ctrl-x`

Normal Mode

- `<C-a>` 光标下数字+1, `6<C-a>` 光标下数字+6;
- `<C-x>` 光标下数字-1, `6<C-x>` 光标下数字-6...

Visual-Block 选择多行数字

增加

- `<C-a>`, 每行数字+1;
- `3<C-a>` 每行数字+3;
- `g<C-a>` 第一行+1, 第二行+2, 第 n 行+n...
- `3g<C-a>` 第一行+3, 第二行+6, 第 n 行+3n...

减少

- `<C-x>`, 每行数字-1;
- `3<C-x>` 每行数字-3;
- `g<C-x>` 第一行-1, 第二行-2, 第 n 行-n...
- `3g<C-x>` 第一行-3, 第二行-6, 第 n 行-3n...

<br />

# 其他

- 键位查看 `:help key-notation`
- floating window 设置: `:help nvim_open_win()`
- lua pattern: eg: `string.match()`, https://fhug.org.uk/kb/kb-article/understanding-lua-patterns/
- vim pattern: `:help pattern-overview`

## FileType vs BufEnter 区别

- 'xxx.log' 文件不会触发 `FileType`, 因为没有该 filetype, 但是会触发 `BufEnter`.

- 每次切换 buffer 时 (hide -> display) 时, 会触发 `BufEnter` 但不会触发 `FileType`.

<br />

## 打开 terminal 的几种方法

`:help terminal-start`

### open term://cmd file

最简单的方法, 主要用于打开 terminal emulator.

- `:edit term://ls`, `new term://ls`, `split term://ls`, `vsplit term://ls` - 直接执行 `ls` 命令.

- `:edit term:///bin/zsh` - 打开 zsh terminal emulator.

### jobstart(cmd) and jobstop(job_id)

静默执行命令, 不会打开 terminal. 推荐使用 `system(cmd)` 替代.

`jobstart()` 主要用于静默开启 http 服务等需要长时间执行的命令.

- `echo jobstart('ls')` - 执行命令同时返回 job_id.

- `call jobstop(job_id)` - 强制终止 job.

## nvim_cmd(), nvim_command(), nvim_exec2() 区别

`vim.cmd()` If a string, it is an alias to `nvim_exec2()` where `opts.output = false`.
`vim.cmd()` If a table, it is an alias to `nvim_cmd()` where `opts` is empty.
VVI: `nvim_parse_cmd('leftabove split foo',{}))` 可以将 cmd string 分析成 nvim_cmd({cmd=..., args=..., mods=...})

首选 nvim_exec2(), 然后是 nvim_cmd(), 不推荐 nvim_command().

```lua
foo = vim.api.nvim_cmd({cmd='echo', args={'"ok"'}}, {output=true})
vim.print(foo)
-- 如果 {output = true} 则 foo 为 "ok";
-- 如果 {output = false} 则运行时直接打印 ok, foo 为空 string "", 而不是 nil.
```

```lua
lua foo = vim.api.nvim_exec2('echo "ok"', {output = true})
lua vim.print(foo)
-- 如果 {output = true} 则 foo 为 table: { output = "ok" };
-- 如果 {output = false} 则直接打印 ok, foo 为 vim.empty_dict()
```

```lua
-- 类似于 vim.cmd(), 不推荐使用.
vim.api.nvim_command('echo "ok"')
```

<br />

## 针对单个 window 有效的 highlight

```lua
--- 创建一个 highlight namespace
local ns = vim.api.nvim_create_namespace('my_term_list')

--- 给指定的 namespace 设置 highlight.
vim.api.nvim_set_hl(ns, 'CursorLine', {ctermbg=24})
vim.api.nvim_set_hl(ns, 'NormalFloat', {ctermbg=233, ctermfg=190})
vim.api.nvim_set_hl(ns, 'FloatBorder', {ctermbg=233, ctermfg=251})

--- 将 namespace 加载到指定 window 中. 只在该 window 中生效.
vim.api.nvim_win_set_hl_ns(float_win_id, ns)
```

<br />

## :help watch-file

```lua
--- vim.loop Use vim.uv instead.
--- `:help vim.loop`, `:help vim.uv`
local watch = vim.uv.new_fs_event()

--- Watch file/dir 时, file/dir 必须存在. 否则 watch:start() 无效.
--- watch file 时, 监控单个 file 的情况.
---   如果 file 被删除, 则 watch 失效, 但是并没有 watch:stop(), 需要手动 watch:stop(), 否则无法再次 watch:start().
---   如果 file 被删除, 然后又创建一个相同的 file 则同上.
---   如果 file 被 mv, 则自动监测新的 file. NOTE: 这里可能是因为 watch 的是 file discriptor, file rename 并不修改 file discriptor.
--- watch dir  时, 监控 dir 下所有 file & dir 的情况. 但只 watch 当前级, 不会自动 watch 子文件夹中的文件.
---   eg: Watch_file('./'), Watch_file('src/')
---   watch dir 时, 不是 watch file discriptor, 而是一个固定的路径. 但是 watch:start() 时该 dir 必须存在.
---   一旦 watch 成功, 就算删除 dir 再重新创建同名 dir 也是在 watch 状态.
---   如果 watch:start() 时 dir 不存在, 则没有效果.
function Watch_file(fname)
  local fullpath = vim.api.nvim_call_function(
    'fnamemodify', {fname, ':p'})
  -- print(fullpath)

  --- NOTE: 如果 file 不存在则 watch:start() 无效, 且不会报错, 也不会执行 callback.
  watch:start(fullpath, {}, vim.schedule_wrap(function(err, changed_fname, status)
    if err then
      Notify(err, "ERROR")
      return
    end

    --- Do work...
    vim.print(changed_fname, 'on_change', status)

    vim.api.nvim_command('checktime')

    --- Debounce: stop/start.
    --- watch a new file.
    --watch:stop()
    --Watch_file(fname)
  end))
end
```

<br />

## file 相关函数

fs_stat() 返回的 'type' 属性可以判断 'file' | 'directory', 但是不能判断 'executable'. 文件权限使用 'mode' 属性判断.

- vim.fn.filereadable() -> vim.uv.fs_stat()

- vim.fn.isdirectory() -> vim.uv.fs_stat()

- vim.fn.executable() 使用 mode 属性(文件权限, eg:0600)判断是否可执行, 但是更麻烦.

<br />

# FIXME

## which-key 有时候报错.

- ERROR Failed to run healthcheck for "which-key" plugin. Exception:
  function health#check, line 25
  Vim(eval):E5108: Error executing lua ...al/share/nvim/lazy/which-key.nvim/lua/which-key/keys.lua:405: Invalid buffer id: 2
  stack traceback:
  [C]: in function 'nvim_buf_get_keymap'
  ...al/share/nvim/lazy/which-key.nvim/lua/which-key/keys.lua:405: in function 'update_keymaps'
  .../share/nvim/lazy/which-key.nvim/lua/which-key/health.lua:15: in function 'check'
  [string "luaeval()"]:1: in main chunk

E5108: Error executing lua ...al/share/nvim/lazy/which-key.nvim/lua/which-key/view.lua:137: Expected Lua number
stack traceback:
        [C]: in function 'nvim_win_get_height'
        ...al/share/nvim/lazy/which-key.nvim/lua/which-key/view.lua:137: in function 'scroll'
        ...al/share/nvim/lazy/which-key.nvim/lua/which-key/view.lua:324: in function 'on_keys'
        ...al/share/nvim/lazy/which-key.nvim/lua/which-key/view.lua:254: in function 'open'
        ...al/share/nvim/lazy/which-key.nvim/lua/which-key/init.lua:49: in function 'show'
        [string ":lua"]:1: in main chunk

## https://github.com/golang/go/issues/50750, gopls, workspace `go.work` lsp.log 中报错:

- stderr: go: finding module for package github.com/my/foo\nbar/src imports\n\tgithub.com/my/foo: cannot find module providing package github.com/my/foo: module lookup disabled by GOPROXY=off\n\n"

## LspRestart -> :bdelete -> error

- https://github.com/neovim/neovim/issues/28987

## lsp Error

https://github.com/neovim/neovim/issues/28058, planned to be fixed at neovim v0.11.1

<br />
