[toc]

# neovim 配置

## 教学

- https://github.com/glepnir/nvim-lua-guide-zh
- https://github.com/LunarVim/Neovim-from-scratch
- https://github.com/LunarVim/LunarVim

<br />

## 配置文件结构

1. neovim 几个常用路径: `:help stdpath()`

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

查看 `.../packer_compiled.lua` 耗时详情可以使用:

- `:PackerCompile profile=true`
- `:PackerProfile`

造成 `opening buffers` 时间长的原因:

- `set undofile`, 占大概 32 ms
- `nvim-lspconfig` 加载 lsp (eg: gopls) 加载占大概 30ms, 有些 lsp 启动速度很快 (eg: tsserver) 大概只占 5ms. 可以使用
  `autocmd Filetype ... vim.schedule()` 方式 lazy load lsp, 降低 lspconfig 在 nvim 启动时的耗时.

<br />

# VIM Mode

| mode                    | Name                                  | tigger               |
| ----------------------- | ------------------------------------- | -------------------- |
| n                       | Normal                                |                      |
| no                      | Operator-pending                      | c,y,d ..., eg: ciw   |
| niI                     | Normal using i_CTRL-O in Insert-mode  | Insert 下 <C-o>      |
| niR                     | Normal using i_CTRL-O in Replace-mode | Replace 下 <C-o>     |
| i                       | Insert                                | a,i,s,o ...          |
| R                       | Replace                               | R                    |
| c                       | Command                               | :                    |
| v                       | Visual by character                   | v                    |
| vs                      | Visual by character                   | Select 下 <C-o>      |
| V                       | Visual by line                        | V                    |
| Vs                      | Visual by line                        | Select 下 <C-o>      |
| ^V - vim.fn.nr2char(22) | Visual by block                       | <C-v>                |
| s                       | Select by character                   | v<C-g>               |
| S                       | Select by line                        | V<C-g>               |
| ^S - vim.fn.nr2char(19) | Select by block                       | <C-v><C-g>           |
| t                       | Terminal mode                         | Terminal insert mode |
| r                       | Hit-enter prompt                      |                      |

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

- `pcall(vim.cmd, "normal! n")` -- 获取 command 返回信息

- `dofile(file/path)` -- lua execute file.

- `table.insert({list}, elem)` -- 向 list 中插入元素

- `table.concat({list}, "sep")` -- 类似 strings.Join()

- `string.gsub("a b c", " ", "\\%%")` -- 类似 strings.Replace()

### nvim 常用函数

- `vim.inspect(table)` -- 打印 table 中的内容, 类似 fmt.Printf("%+v", struct)

- `vim.list_extend({list1}, {list2})` -- 合并两个 list-like table

- `vim.tbl_deep_extend("force", {map1}, {map2}, {map3}...)` -- 合并多个 map-like table

- `vim.split({string}, {sep}, {trimempty})` -- strings.Split()

### vim 自带函数

- `vim.fn.feedkeys("\<CR>")` -- VVI: 模拟输入 <CR>. 注意单/双引号: `feedkeys("\<CR>")` simulates pressing of the <Enter> key. But `feedkeys('\<CR>')` pushes 5 characters.

- `vim.fn.json_encode(table)` / `vim.fn.json_decode(string)` -- json 处理.

- `vim.fn.split({string}, {pattern}, {keepempty})` -- 默认 keepempty=0(false)

- `vim.fn.join({list}, sep)`

- `vim.fn.trim()`

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

### nvim.api - win / tab / buffer 函数

- `vim.api.nvim_win_get_var()` / `vim.api.nvim_win_set_var()` / `vim.api.nvim_win_del_var()`
- `vim.api.nvim_buf_get_var()` / `vim.api.nvim_buf_set_var()` / `vim.api.nvim_buf_del_var()`
- `vim.api.nvim_tabpage_get_var()` / `vim.api.nvim_tabpage_set_var()` / `vim.api.nvim_tabpage_del_var()`

==还有很多 nvim.api 函数和 vim 的函数对应.==

### nvim async 函数

- `vim.schedule(callback)` -- async 执行 callback.

- `vim.defer_fn(callback, delay)` -- 延迟执行 callback. delay 单位是 ms.

### nvim 新线程函数

- `:help vim.loop`

- `vim.loop.new_thread(callback)` -- 新线程, VVI: 无法调用 main thread 中的任何数据, 相当于两个单独的程序.

- `print(vim.is_thread())` -- false: main thread; true: other threads

### lua 运行 shell cmd, 获取 output.

```lua
local result = vim.fn.system(cmd)
if vim.v.shell_error ~= 0 then
  print(result)
  return
end

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

## VVI: FileType vs BufEnter 区别

- 'xxx.log' 文件不会触发 `FileType`, 因为没有该 filetype, 但是会触发 `BufEnter`.

- 每次切换 buffer 时 (hide -> display) 时, 会触发 `BufEnter` 但不会触发 `FileType`.

<br />

# test function

## 测试 autocmd FileType 传入的 params.buf 和 bufnr() 得出的结果是否一样.

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    local bufinfo = vim.fn.getbufinfo(params.buf)[1]
    print('bufnr():', vim.fn.bufnr(), '| params.buf:', params.buf, '| bufname():', vim.fn.bufname(), "| getbufinfo(params.buf):", bufinfo.bufnr, bufinfo.name)
  end
})
```

<br />

# neovim v0.8 release date: 30/9/2022

- `:help deprecated.txt`

- https://github.com/neovim/neovim/releases/tag/v0.8.0

## Important changes

- DO NOT use `vim.g.do_filetype_lua` and `vim.g.did_load_filetypes` settings in neovim v0.8

- LSP: Add logging level "OFF", eg: `vim.lsp.set_log_level("OFF")`

- LSP: Option to reuse_win for jump actions ([#18577](https://github.com/neovim/neovim/pull/18577))

- `vim.lsp.buf.formatting_sync()` => `vim.lsp.buf.format({ async = false })`

```lua
--- `:help vim.lsp.buf.format()`
vim.lsp.buf.format({
  async = false,
  timeout_ms = 3000,
  bufnr = bufnr,
  filter = function(client)
    -- format 时过滤 tsserver
    return client.name ~= 'tsserver'
  end
  name = '',  -- Restrict formatting to the client with client.name
})
```

- LSP NEW api: `vim.lsp.start()` 可能可以用于 `au FileType *.go lua vim.lsp.start({cmd=,root=...})`

- LSP: Add `:LspAttach` and `:LspDetach` lsp-events, `au LspAttach * ...`

- `:help winbar`, `:hi WinBar`

- ADD: `vim.fs.dirname(vim.fn.bufname('%'))` == `vim.fn.expand('%:h')`

- [LSP] Accessing client.resolved_capabilities => client.server_capabilities instead.

<br />

# Note

## Pull request

### nvim-treesitter

- golang (placeholder | format verbs %v %d), https://github.com/tree-sitter/tree-sitter-go/pull/88

<br />

## FIXME

### which-key 有时候报错.

- ERROR: Failed to run healthcheck for "which_key" plugin. Exception:
  function health#check[20]..health#which_key#check, line 1
  Vim(lua):E5108: Error executing lua .../pack/packer/start/which-key.nvim/lua/which-key/keys.lua:426: Invalid buffer id: 3
  stack traceback:
  [C]: in function 'nvim_buf_get_keymap'
  .../pack/packer/start/which-key.nvim/lua/which-key/keys.lua:426: in function 'update_keymaps'
  .../pack/packer/start/which-key.nvim/lua/which-key/keys.lua:363: in function 'check_health'
  [string ":lua"]:1: in main chunk

### LSP documentHighlight 有时候报错.

- Error detected while processing CursorHold Autocommands for "<buffer=4>":
  method textDocument/documentHighlight is not supported by any of the servers registered for the current buffer

### https://github.com/golang/go/issues/50750, gopls, workspace `go.work` lsp.log 中报错:

- stderr: go: finding module for package github.com/my/foo\nbar/src imports\n\tgithub.com/my/foo: cannot find module providing package github.com/my/foo: module lookup disabled by GOPROXY=off\n\n"

<br />

## TODO

动态加载 lsp 本地 config.

- `:help watch-file`, when `.nvim/settings.lua` changed OR added.

- `:LspRestart` - lspconfig command

- LSP `client.notify("workspace/didChangeConfiguration")`

```lua
function TestLSP(id)
  --- get client
  local client = vim.lsp.get_client_by_id(id)
  -- print(vim.inspect(client.config.settings))

  if client.name == 'gopls' then
    client.config.settings.gopls["ui.completion.usePlaceholders"] = false
    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  end

  if client.name == 'null-ls' then
    client.stop() -- remove null-ls lsp
  end
end

function TestNull()
  local golangci = require("null-ls").get_source({name="golangci_lint"})[1]
  print(vim.inspect(golangci))
  -- print(vim.inspect(golangci.generator))
end
```

- chore: highlight filepath / jump to file
- chore: global -> utils (module)
