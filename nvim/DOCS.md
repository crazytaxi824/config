[toc]

v0.10.0_beta for neovim v0.10.0

# neovim 配置

## 配置文件结构

1. neovim 几个常用路径: `:help stdpath()`

- `vim.env.PATH` - vim 中的 `$PATH` 设置, 可以使用 `lua print(vim.env.PATH)` 查看. 默认和 shell 的 `echo $PATH` 相同. 也可以自行设置, eg: `mason.nvim` 插件就将自己的 tools_path 添加到 `vim.env.PATH` 的最前面.

- `stdpath("config")` = `~/.config/nvim/`, 配置文件主要路径.

- `stdpath("data")` = `~/.local/share/nvim/`, 插件安装路径.

- `stdpath("state")` = `~/.local/state/nvim/`, undo, shada, swap ...

- `stdpath("log")` = `~/.local/state/nvim/`, 目前只有 nvim-log. 目前和 `stdpath("state")` 路径相同.

- `stdpath("cache")` = `~/.cache/nvim/`, temporary storage for plugins. 目前 plugins 用于储存 log 文件, 以后可能会移到
  `stdpath("log")` 地址下.


2. `after/ftplugin`, `after/syntax`, `ftplugin` 和 `syntax` 作用几乎一样, 却别在于:

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

# set options

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

VVI:
> `local to window` 的属性有些特别, eg:
>
> `setlocal wrap` 相当于 `vim.api.nvim_set_option_value('wrap', true, { scope='local', win=win_id })` 但是和
> `vim.wo[win_id].wrap = true` 却不一样.
>
> 如果设置 `vim.wo[win_id].wrap=true` 后续打开的 window 全都是 wrap 的.
> 需要使用 `vim.wo[win_id][0].wrap = true` 才行. 这里的 `[0]` 意思是 `bufnr=0` 即 current buffer.

<br/>

# filter 操作

using filter, `:help filter` 使用方法:

## Normal mode

1. 在行内写入 shell 代码. `cal -h -3`

2. filter command, `!!` == `:.!`, 进入 (filter) command 模式.

   - `.` 表示当前行.
   - `!` 表示后面是 shell command.

3. `:.!` 后输入 bash, cat, grep ... 等支持 pipe 的 shell command.

4. 如果不支持 pipe 的命令需要使用 `xargs` 来传递参数. 例如 `echo`, 需要使用 `echo "omg" | xargs echo`

## Visual mode

也可以在 visual select 之后, 按 `!`, 进入 (filter) command 模式 `:'<,'>!`

## 其他例子:

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



