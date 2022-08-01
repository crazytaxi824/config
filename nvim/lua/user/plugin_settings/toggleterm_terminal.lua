--- README: `:h toggleterm`
--- 常用命令:
---    `:ToggleTerm` - toggle terminal 列表中最后一个 terminal.
---    `:<ID>ToggleTerm` - toggle 一个指定 id 的 terminal. eg: `:16ToggleTerm`, `:100ToggleTerm`
---    `:ToggleTermToggleAll` - toggle 所有 terminal.
---    `:ToggleTerm size=40 dir=~/Desktop direction=horizontal` - 定义 size, dir 和 direction.
---
--- NOTE: toggleterm 缓存了一个 terminal list,
---      `:ToggleTerm` 并没有结束 session, 只是 hide 了. 可以重新用 `:ToggleTerm` 打开.
---
--- VVI: :q 只是 hide terminal, 只有 :q! 才会真正结束 terminal session.
---      <C-d> 结束 job, 相当于 exit.

local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
  return
end

toggleterm.setup({
  size = function(term)
    if term.direction == "horizontal" then
      return 16
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,

  --open_mapping = [[<leader>t]],  -- VVI: 不好用. 打开/关闭 terminal, 相当于 `:ToggleTerm`
  insert_mappings = false,       -- 是否在 insert 模式下使用 open_mapping 快捷键.
  terminal_mappings = false,     -- 是否在 terminal insert && normal 模式下使用 open_mapping 快捷键.

  close_on_exit = true,     -- job 执行完成之后退出 terminal. 输入 `$ exit` 之后自动关闭 terminal.
  start_in_insert = false,  -- VVI: 打开 terminal 时进入 insert 模式.
                            -- 类似 `au TermOpen|BufWinEnter term://*#toggleterm#* :startinsert`
                            -- 全局设置, 不好用. 可以单独设置.

  direction = "horizontal",  -- vertical | horizontal | tab | float

  hide_numbers = false,  -- 隐藏 terminal 行号, BUG: 会影响后打开的 window 也没有 number. 下面通过 au 设置.
  persist_size = true,   -- 保持 window size
  persist_mode = true,   -- if set to true (default) the previous terminal mode will be remembered

  shade_terminals = false,  -- `set termguicolors` 用
  --shade_filetypes = {},
  --shading_factor = 2,     -- the degree by which to darken to terminal colour, 1 | 2 | 3
  shell = vim.o.shell,
  float_opts = {
    border = "single",  -- `:help nvim_open_win()`
    winblend = 0,
  },

  --- highlight <file:line:col>
  on_stdout = function(_,_,data,_)
    --- file:// pattern match
    --- '\f' - isfname, 可用于 filename 的字符/数字/符号...
    --- '\<' - start of a word
    vim.fn.matchadd('Underlined', '\\<file://\\f*\\(:[0-9]\\+\\)\\{0,2}')  -- highlight filepath

    for _, lcontent in ipairs(data) do
      for _, content in ipairs(vim.split(lcontent, " ")) do
        --- VVI: 这里必须 trim(), 可以去掉 \r \n ...
        local fp = vim.split(vim.fn.trim(content), ":")
        if vim.fn.filereadable(vim.fn.expand(fp[1])) == 1 then
          --- \@<! - eg: \(foo\)\@<!bar  - any "bar" that's not in "foobar"
          --- \@!  - eg: foo\(bar\)\@!   - any "foo" not followed by "bar"
          vim.fn.matchadd('Underlined', '\\(\\S\\)\\@<!'..vim.fn.escape(fp[1], '~') .. '\\(:[0-9]\\+\\)\\{0,2}')  -- highlight filepath
        end
      end
    end
  end,
  --- 其他设置 --- {{{
  -- on_open  = fun(t: Terminal), -- TermOpen, 打开新 terminal 时才会生效.
  -- on_close = fun(t: Terminal), -- NOTE: autoclose=true 的时候才能触发.
  -- on_exit  = fun(t: Terminal, job: number, exit_code: number, name: string) -- TermClose, job ends.
  -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
  -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr

  --- NOTE: nightly version 才有 winbar 可以用.
  -- winbar = {
  --   enabled = false,
  -- },
  -- -- }}}
})

--- 其他 terminal 设置 -----------------------------------------------------------------------------
--- #toggleterm#1-9 自动进入 insert mode.
--- VVI: TermOpen 只在 job start 的时候启动一次, buffer 被隐藏后再次调出使用的是 BufWinEnter 事件.
--- 可以通过 `:au ToggleTermCommands` 查看.
--vim.cmd [[au TermOpen term://*#toggleterm#[1-9] :startinsert]]
--vim.cmd [[au BufWinEnter term://*#toggleterm#[1-9] :startinsert]]

--- <ESC> 进入 terminal Normal 模式, VVI: 同时也 press <ESC>, 用于退出 fzf 等 terminal 中的操作. 只对本 buffer 有效.
vim.cmd [[au TermOpen term://* tnoremap <buffer> <ESC> <ESC><C-\><C-n>]]

--- 设置 terminal 不显示行号.
vim.cmd [[au TermOpen term://* :setlocal nonumber]]

--- Terminal 实例 ----------------------------------------------------------------------------------
local Terminal = require("toggleterm.terminal").Terminal

--- 缓存所有自定义 terminal 实例. cache terminal instance.
local my_terminals = {}

--- VVI: execute: golang / javascript / typescript / python...
local exec_term_id = 1001
local exec_term = Terminal:new({count = exec_term_id})
function _Exec(cmd)
  --- 删除之前的 terminal, 同时终止 job.
  exec_term:shutdown()

  --- 生成新的 exec_term, 不同的 cmd.
  --- 生成了新的实例, 需要重新缓存新生成的实例, 否则无法 open() / close() ...
  --- 也可以使用 Terminal:new({...})
  exec_term = exec_term:new({count = exec_term_id, close_on_exit = false, cmd = cmd})
  my_terminals[exec_term_id] = exec_term  -- VVI: 缓存新的 exec terminal

  --- run cmd
  exec_term:open()
end

--- node ---
local node_term_id = 201
local node_term = Terminal:new({
  cmd = "node",
  hidden = true,  -- true: 该 term 不受 :ToggleTerm :ToggleTermToggleAll ... 命令影响.
  direction = "float",  -- horizontal(*) | vertical | float | tab
  count = node_term_id,
  on_open = function(term)
    vim.cmd('startinsert')  -- 使用 on_open 相当于启动了 TermOpen && BufWinEnter 事件.
  end
})
function _NODE_TOGGLE()
  node_term:toggle()
end

--- python3 ---
local py_term_id = 202
local python_term = Terminal:new({
  cmd = "python3",
  hidden = true,
  direction = "float",
  count = py_term_id,
  on_open = function(term)
    vim.cmd('startinsert')
  end
})
function _PYTHON_TOGGLE()
  python_term:toggle()
end

--- normal terminals ---
local n1_term = Terminal:new({count = 1, on_open = function() vim.cmd('startinsert') end}) -- open()|close()|send(cmd)|shutdown()
local n2_term = Terminal:new({count = 2, on_open = function() vim.cmd('startinsert') end})
local n3_term = Terminal:new({count = 3, on_open = function() vim.cmd('startinsert') end})
local n4_term = Terminal:new({count = 4, on_open = function() vim.cmd('startinsert') end})
local n5_term = Terminal:new({count = 5, on_open = function() vim.cmd('startinsert') end})
local n6_term = Terminal:new({count = 6, on_open = function() vim.cmd('startinsert') end})
local n7_term = Terminal:new({count = 7, direction = "vertical", on_open = function() vim.cmd('startinsert') end})
local n8_term = Terminal:new({count = 8, direction = "vertical", on_open = function() vim.cmd('startinsert') end})
local n9_term = Terminal:new({count = 9, direction = "vertical", on_open = function() vim.cmd('startinsert') end})

--- 缓存所有自定义 terminal 实例.
my_terminals = {
  --- normal terminal
  [1]=n1_term, [2]=n2_term, [3]=n3_term,
  [4]=n4_term, [5]=n5_term, [6]=n6_term,
  [7]=n7_term, [8]=n8_term, [9]=n9_term,

  --- special use terminal
  [exec_term_id]=exec_term,
  [node_term_id]=node_term,
  [py_term_id]=python_term
}

--- terminal key mapping ---------------------------------------------------------------------------
--- terminal 实例内置方法: `:open() / :close() / :shutdown() / :clear() / :spawn() / :new()`
--- 常用 terminal.
local function toggle_normal_term()
  --- v:count1 默认值为1.
  my_terminals[vim.v.count1]:toggle()
end

--- 通过 bufname 获取 terminal id.
local function get_term_id(bufname)
  local tmp = vim.split(bufname, '#')
  return tonumber(tmp[#tmp])  -- tonumber('')=nil; tonumber('a')=nil; tonumber('12a')=nil; tonumber('a12')=nil;
end

--- open / close all terminals
local function toggle_all_terms()
  local active_terms = {}
  local inactive_terms = {}

  --- 遍历所有 buffer, 筛选出 active_terms && inactive_terms
  for _, buf in ipairs(vim.fn.getbufinfo()) do
    if string.match(buf.name, '^term://') then
      if #buf.windows > 0 then  -- buf.windows 判断 buffer 是否 active.
        table.insert(active_terms, get_term_id(buf.name))
      else
        table.insert(inactive_terms, get_term_id(buf.name))
      end
    end
  end

  --- 如果有 active terminal 则全部关闭.
  if #active_terms > 0 then
    for _, term_id in ipairs(active_terms) do
      my_terminals[term_id]:close()
    end
    return
  end

  --- 如果没有 active terminal 则打开全部 inactive terminals.
  for _, term_id in ipairs(inactive_terms) do
    my_terminals[term_id]:open()
  end
end

local opt = {noremap = true, silent = true}
local toggleterm_keymaps = {
  {'n', 'tt', toggle_normal_term, opt, "[1-9]Toggle Terminals"},
  {'n', '<leader>t', toggle_all_terms, opt, "Toggle All Terminals"},
}

Keymap_set_and_register(toggleterm_keymaps)



