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

  hide_numbers = false,  -- 隐藏 terminal 行号,
                         -- BUG: 会影响后打开的 window 也没有 number. 下面通过 autocmd 手动设置.
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

  --- terminal 输出时 highlight filepath.
  --- output 是一个 list, 按照行分隔.
  --- 这里不使用 autocmd TermClose 而是使用 on_stdout 主要是因为有些程序运行不会结束, eg: http 监听.
  on_stdout = function(_,_,output,_)
    Highlight_filepath(output)
  end,

  --- 其他设置, NOTE: 以下最好不要全局设置, 可以根据具体情况在 :open() 前设置 ---
  --on_open  = fun(t: Terminal), -- toggleterm win open.  NOTE: term:spawn() 无法触发.
  --on_close = fun(t: Terminal), -- toggleterm win close. NOTE: close_on_exit=true 的时候才能触发.
  --on_exit  = fun(t: Terminal, job: number, exit_code: number, name: string) -- TermClose, job ends
  --on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
  --on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr

  --- NOTE: nightly version 才有 winbar 可以用.
  --winbar = {
  --  enabled = false,
  --},
})

--- terminal 其他设置 ------------------------------------------------------------------------------
--- #toggleterm#1-9 自动进入 insert mode.
--- VVI: TermOpen 只在 job start 的时候启动一次, terminal-buffer 被隐藏后再次调出使用的是 BufWinEnter 事件.
--- 可以通过 `:au ToggleTermCommands` 查看.
--vim.cmd [[au TermOpen term://*#toggleterm#[1-9] :startinsert]]
--vim.cmd [[au BufWinEnter term://*#toggleterm#[1-9] :startinsert]]

--- <ESC> 进入 terminal Normal 模式,
--- VVI: 同时也 press <ESC>, 用于退出 fzf 等 terminal 中的操作. 只对本 buffer 有效.
vim.cmd [[au TermOpen term://* tnoremap <buffer> <ESC> <ESC><C-\><C-n>]]

--- 设置 terminal 不显示行号.
vim.cmd [[au TermOpen term://* :setlocal nonumber]]

--- TermClose 意思是 job ends.
--- BufWinEnter 当 terminal buffer 被隐藏后再次打开的时候 highlight filepath.
--- 这里不使用 TermClose 而是使用 on_stdout 主要是因为有些程序运行不会结束, eg: http 监听.
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  pattern = {"term://*"},
  callback = function()
    local output = vim.fn.getline(1, '$')
    Highlight_filepath(output)
  end,
})

--- Terminal 实例 ---------------------------------------------------------------------------------- {{{
---   term:clear()     清除 term 设置.
---   term:close()     关闭窗口, NOTE: 只能关闭 :open() 打开的窗口.
---   term:open()      打开窗口, 如果 term 不存在则运行 job.
---   term:toggle()    相当于 close() / open(), 如果 term 不存在则运行 job.
---   term:shutdown()  NOTE: exit terminal. 终止 terminal job, 然后关闭 term 窗口.
local Terminal = require("toggleterm.terminal").Terminal

--- VVI: execute: golang / javascript / typescript / python... -----------------
local exec_term_id = 1001
local exec_term = Terminal:new({
  --- NOTE: count 在 term job end 之后可以被新的 term 使用, :ls! 中可以看到两个相同 count 的 buffer.
  --- 但是如果有相同 count 的 term job 还未结束时, 新的 term 无法运行.
  count = exec_term_id,

  --- VVI: 必须要, 否则在 :shutdown() 的时候会因为 close_on_exit 开始退出,
  --- 导致 :open() 在执行下一个命令的过程中 terminal 退出.
  close_on_exit = false,
})
local cache_cmd     -- string, 缓存 _Exec() 中运行的 cmd.

--- cache 是一个标记, 如果为 true, 则在将 cmd 记录在 last_cmd 中.
--- callback 在 on_exit = func() 的时候执行.
function _Exec(cmd, cache, callback)
  --- 缓存 cmd
  if cache then
    cache_cmd = cmd
  end

  --- 删除之前的 terminal, 同时终止 job.
  exec_term:shutdown()

  --- 缓存执行 _Exec() 的 window id
  local exec_wid = vim.fn.win_getid(vim.fn.winnr())

  --- 该 terminal buffer wipeout 的时候回到之前的窗口.
  exec_term.on_open = function()
    vim.api.nvim_create_autocmd("BufWipeout", {
      buffer = 0,
      callback = function(params)
        --- 如果 goto 的 win_id 不存在, 则会自动跳到别的 window.
        vim.fn.win_gotoid(exec_wid)  -- 这里会返回 true | false.
      end,
      desc = 'go back to window which execute _Exec()',
    })
  end

  --- NOTE: callback 不存在的时候 on_exit 就会清除, 相当于: on_exit = nil
  exec_term.on_exit = callback

  --- 设置 cmd
  exec_term.cmd = 'echo -e "\\e[32m' .. vim.fn.escape(cmd,'"') .. ' \\e[0m" && ' .. cmd

  --- NOTE: 如果使用 :new() 生成了新的实例, 需要重新缓存新生成的实例, 否则无法 open() / close() ...
  --exec_term = exec_term:new(vim.tbl_deep_extend('error', exec_opts, {cmd = cmd}))
  --my_terminals[exec_term_id] = exec_term  -- VVI: 缓存新的 exec terminal

  --- run cmd
  exec_term:open()
end

--- 重新执行 cached cmd
local function exec_cached_cmd()
  if not cache_cmd then
    Notify("no Command has been Cached", "Info")
    return
  end

  --- 删除之前的 terminal, 同时终止 job.
  exec_term:shutdown()

  --- 设置 cmd
  exec_term.cmd = 'echo -e "\\e[32m' .. vim.fn.escape(cache_cmd,'"') .. ' \\e[0m" && ' .. cache_cmd

  --- run cmd
  exec_term:open()
end

--- 重新执行 last cmd
local function exec_last_cmd()
  if not exec_term.cmd then
    Notify("no Command has been Executed", "Info")
    return
  end

  --- 删除之前的 terminal, 同时终止 job.
  exec_term:shutdown()

  --- re-run last cmd.
  --- NOTE: 这里因为没有改变 exec_term 中的任何设置,
  --- 所以 open() 的时候, 会运行上一次记录在 cmd 中的命令.
  exec_term:open()
end

--- node -----------------------------------------------------------------------
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

--- python3 --------------------------------------------------------------------
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

--- normal terminals -----------------------------------------------------------
local n1_term = Terminal:new({count = 1, on_open = function() vim.cmd('startinsert') end})
local n2_term = Terminal:new({count = 2, on_open = function() vim.cmd('startinsert') end})
local n3_term = Terminal:new({count = 3, on_open = function() vim.cmd('startinsert') end})
local n4_term = Terminal:new({count = 4, on_open = function() vim.cmd('startinsert') end})
local n5_term = Terminal:new({count = 5, on_open = function() vim.cmd('startinsert') end})
local n6_term = Terminal:new({count = 6, on_open = function() vim.cmd('startinsert') end})
local n7_term = Terminal:new({count = 7, direction = "vertical", on_open = function() vim.cmd('startinsert') end})
local n8_term = Terminal:new({count = 8, direction = "vertical", on_open = function() vim.cmd('startinsert') end})
local n9_term = Terminal:new({count = 9, direction = "vertical", on_open = function() vim.cmd('startinsert') end})

-- -- }}}

--- 缓存所有自定义 terminal 实例.
local my_terminals = {
  --- normal terminal
  [1]=n1_term, [2]=n2_term, [3]=n3_term,
  [4]=n4_term, [5]=n5_term, [6]=n6_term,
  [7]=n7_term, [8]=n8_term, [9]=n9_term,

  --- special use terminal
  [exec_term_id]=exec_term,
  [node_term_id]=node_term,
  [py_term_id]=python_term,
}

--- terminal key mapping ---------------------------------------------------------------------------
--- terminal 实例内置方法: `:open() / :close() / :shutdown() / :clear() / :spawn() / :new()`
--- 常用 terminal.
local function toggle_normal_term()
  --- v:count1 默认值为1.
  my_terminals[vim.v.count1]:toggle()
end

--- open / close all terminals
local function toggle_all_terms()
  local active_terms_wins = {}
  local inactive_terms = {}

  --- 遍历所有 buffer, 筛选出 active_terms && inactive_terms
  for _, buf in ipairs(vim.fn.getbufinfo()) do
    if string.match(buf.name, '^term://') then
      if #buf.windows > 0 then  -- buf.windows 判断 buffer 是否 active.
        vim.list_extend(active_terms_wins, buf.windows)
      else
        --- NOTE: toggleterm 会在每个 toggleterm buffer 中 setbufvar('toggle_number'), 值是 terminal count/id
        --- 如果 table.insert(list, nil), 则 list 不会有任何影响.
        table.insert(inactive_terms, buf.variables["toggle_number"])
      end
    end
  end

  --- 如果有 active terminal 则全部关闭.
  if #active_terms_wins > 0 then
    for _, win_id in ipairs(active_terms_wins) do
      --- 关闭所有 active terminal 的窗口
      --- NOTE: 这里不使用 :close() 是因为 :close() 只能关闭 :open() 打开的窗口,
      --- 如果有多个窗口都显示同一个 terminal 则 :close() 无法关闭全部窗口.
      vim.api.nvim_win_close(win_id, false)
    end
    return
  end

  --- 如果没有 active terminal 则打开全部 inactive terminals.
  for _, term_id in ipairs(inactive_terms) do
    if my_terminals[term_id] then
      my_terminals[term_id]:open()
    end
  end
end

local opt = {noremap = true, silent = true}
local toggleterm_keymaps = {
  {'n', 'tt', toggle_normal_term, opt, "terminal: toggle Terminal #(1-9)"},
  {'n', '<leader>t', toggle_all_terms, opt, "terminal: toggle All Terminals"},

  {'n', '<F17>', exec_cached_cmd, opt, "code: Re-Run Cached cmd"},  -- <S-F5> run cache cmd.
  {'n', '<F29>', exec_last_cmd, opt, "code: Re-Run Last cmd"},    -- <C-F5> re-run last cmd.
}

Keymap_set_and_register(toggleterm_keymaps, {
  key_desc = {
    t = {name="Terminal"},
  },
  opts = {mode='n'},
})



