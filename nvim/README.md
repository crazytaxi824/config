# README

## 教学

- https://github.com/glepnir/nvim-lua-guide-zh
- https://github.com/LunarVim/Neovim-from-scratch
- https://github.com/LunarVim/LunarVim

<br />

## 配置文件结构

1. neovim 三个常用路径:

   - `vim.fn.stdpath("config")` = `~/.config/nvim/`, 配置文件主要路径.

   - `vim.fn.stdpath("data")` = `~/.local/share/nvim/`, 插件安装路径.

   - `vim.fn.stdpath("cache")` = `~/.cache/nvim/`, 各种 log 文件储存路径.

2. neovim 启动时会首先执行 runtimepath (`:set runtimepath?`) 中的 `init.lua` 文件. 即 `~/.config/nvim/init.lua` 文件.
   然后根据 `init.lua` 文件中的 `require("xxx")` 在所有的 runtimepath 中查找对应的文件.

3. require 使用:

   - 加载 ~/.config/nvim/lua/user/options.lua 单个文件, `require("user.options")` OR `require("user/options")` 省略 .lua

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

## lua 全局变量 `_G`

lua 中有一个 `_G` 全局变量. 自定义的所有全局变量和函数都会被放在 `_G` 内.
例如:

- 自定义了 `__Proj_local_settings` 变量, 则可以使用 `__Proj_local_settings` 或者 `_G.__Proj_local_settings` 访问.

- 自定义全局函数 `Notify()`, 则可以使用 `Notify()`, 或者 `_G.Notify()` 调用函数.

<br />

## vim 内置属性设置

eg: `wrap` is local to window

| vim script        | neovim lua            | set to specific win_id        | set to specific winnr                     |
| ----------------- | --------------------- | ----------------------------- | ----------------------------------------- |
| `setlocal wrap`   | `vim.wo.wrap = true`  | `vim.wo[win_id].wrap = true`  | `vim.fn.setwinvar(winnr, '&wrap', 1)`     |
| `setlocal nowrap` | `vim.wo.wrap = false` | `vim.wo[win_id].wrap = false` | `vim.fn.setwinvar(winnr, '&wrap', 0)`     |
| `set wrap?`       | `print(vim.wo.wrap)`  | `print(vim.wo[win_id].wrap)`  | `print(vim.fn.getwinvar(winnr, '&wrap'))` |

如果不是 vim 内置 option 则使用 '&xxx' 变量名 set 时会报错.

eg: `:call setbufvar(5, '&foo', 'bar')`, 报错 `E355: Unknown option: foo`

<br />

## 常用函数

### lua 常用函数

- `pcall(vim.cmd, "normal! n")` -- 获取 command 返回信息

- `table.insert({list}, elem)` -- 向 list 中插入元素

- `table.concat({list}, "sep")` -- 类似 strings.Join()

- `string.gsub("a b c", " ", "\\%%")` -- 类似 strings.Replace()

### nvim 常用函数

- `vim.inspect(table)` -- 打印 table 中的内容, 类似 fmt.Printf("%+v", struct)

- `vim.list_extend({list1}, {list2})` -- 合并两个 list-like table

- `vim.tbl_deep_extend("force", {map1}, {map2}, {map3}...)` -- 合并多个 map-like table

- `vim.split({string}, {sep}, {kwargs})` -- strings.Split()

### vim 自带函数

- `vim.fn.feedkeys("\<CR>")` -- VVI: 模拟输入 <CR>. 注意单/双引号: `feedkeys("\<CR>")` simulates pressing of the <Enter> key. But `feedkeys('\<CR>')` pushes 5 characters.

- `vim.fn.json_encode(table)` / `vim.fn.json_decode(string)` -- json 处理.

- `vim.fn.split({string}, {pattern}, {keepempty})` -- 默认 keepempty=0(false)

- `vim.fn.join({list}, sep)`

- `vim.fn.trim()`

### window / tab / buffer 函数

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

### nvim async 函数

- `vim.schedule(callback)` -- async 执行 callback.

- `vim.defer_fn(callback, delay)` -- 延迟执行 callback. delay 单位是 ms.

### nvim 新线程函数

- `:help vim.loop`

- `vim.loop.new_thread(callback)` -- 新线程, VVI: 无法调用 main thread 中的任何数据, 相当于两个单独的程序.

- `print(vim.is_thread())` -- false: main thread; true: other threads

### lua 运行 shell cmd, 获取 output.

```lua
local handle = io.popen(cmd)
local result = handle:read("a")  -- "a" - read all output
handle:close()
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

2. filter command, `!!`, 不需要 `:`, 会在底部命令行区域出现 `:.!`, 进入 (filter) command 模式.

   - `.` 表示当前行.
   - `!` 表示后面是 shell command.

3. `!` 后输入 bash, cat, grep ... 等支持 pipe 的 shell command.

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

<br />

## 多行数字增加 `Ctrl-a` 和数字减少 `Ctrl-x`

- Normal, \<C-a\> 光标下数字+1, 6\<C-a\> 光标下数字+6; \<C-x\> 光标下数字-1, 6\<C-x\> 光标下数字-6...
- visual-block 选择多行数字, \<C-a\>, 每行数字+1, 3\<C-a\> 每行数字+3, g\<C-a\> (visual)第一行+1, 第二行+2, 第 n 行+n...
- visual-block 选择多行数字, \<C-x\>, 每行数字-1, 3\<C-x\> 每行数字-3, g\<C-x\> (visual)第一行-1, 第二行-2, 第 n 行-n...

<br />

# 其他

- 键位查看 `:help key-notation`
- floating window 设置: `:help nvim_open_win()`
- 正则: eg: `string.match()`, https://fhug.org.uk/kb/kb-article/understanding-lua-patterns/

## VVI: FileType vs BufEnter 区别:

'xxx.log' 文件不会触发 FileType, 因为没有该 filetype, 但是会触发 BufEnter.

<br />

# test function

## 测试 autocmd FileType 传入的 params.buf 和 bufnr() 得出的结果是否一样.

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    local bufinfo = vim.fn.getbufinfo(params.buf)[1]
    print('bufnr():', vim.fn.bufnr(), '| params.buf:', params.buf, '| bufname():', vim.fn.bufname(), "| getbufinfo(params.buf):", bufinfo.bufnr, bufinfo.name)
    print()
  end
})
```

<br />

# Note

- Feature/attach to unnamed buffer #1929, https://github.com/neovim/nvim-lspconfig/pull/1929. for now: add file in nvim-tree, eg: 'tmp.json', 'tmp.go', and remove it later.

- "Comment.nvim" plugin upgrade. new Feature.
