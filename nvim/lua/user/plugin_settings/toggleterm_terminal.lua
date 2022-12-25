--- README: `:help toggleterm`
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

  close_on_exit = true,    -- job 执行完成之后退出 terminal. 输入 `$ exit` 之后自动关闭 terminal.
  start_in_insert = true,  -- 打开 terminal 时进入 insert 模式.
                           -- 类似 `au TermOpen|BufWinEnter term://*#toggleterm#* :startinsert`
                           -- NOTE: 全局设置, 不可对 terminal 进行单独设置.

  direction = "horizontal",  -- vertical | horizontal | tab | float

  hide_numbers = false,  -- 隐藏 terminal 行号,
                         -- BUG: 会影响后打开的 window 也没有 number. 下面通过 autocmd 手动设置.
  persist_size = true,   -- 保持 window size
  persist_mode = true,   -- if set to true (default) the previous terminal mode will be remembered

  auto_scroll = true,  -- automatically scroll to the bottom on terminal output

  shade_terminals = false,  -- `set termguicolors` 用
  --shade_filetypes = {},
  --shading_factor = 2,     -- the degree by which to darken to terminal colour, 1 | 2 | 3

  shell = vim.o.shell,  -- system shell

  --- This field is only relevant if direction is set to 'float'.
  float_opts = {
    border = "single",  -- `:help nvim_open_win()`
    winblend = 0,  -- NOTE: 除非使用 termguicolors, 否则设置为 0.
  },

  --- 其他设置, NOTE: 以下除 on_create 之外最好不要全局设置, 可以根据具体情况在 :open() 前设置 ---
  --on_create = fun(t: Terminal), -- function to run when the terminal is first created.
  --on_open  = fun(t: Terminal), -- toggleterm win open.  NOTE: term:spawn() 无法触发.
  --on_close = fun(t: Terminal), -- toggleterm win close. NOTE: close_on_exit=true 的时候才能触发.
  --on_exit  = fun(t: Terminal, job: number, exit_code: number, name: string) -- TermClose, job ends
  --on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
  --on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr

  --- NOTE: nvim v0.8+ 才有 winbar 可以用.
  --- 会添加 highlight WinBarActive & WinBarInactive 两个颜色.
  winbar = {
    enabled = false,  -- BUG: background spawn terminal 会引起 error. in function 'nvim_win_is_valid'
  },
})

--- toggleterm winbar 颜色
vim.api.nvim_set_hl(0, 'WinBarActive', {bold = true, underline = true})
vim.api.nvim_set_hl(0, 'WinBarInactive', {ctermfg=246})

--- terminal autocmd 设置 -------------------------------------------------------------------------- {{{
--- #toggleterm#1-9 自动进入 insert mode.
--- VVI: TermOpen 只在 job start 的时候启动一次, terminal-buffer 被隐藏后再次调出使用的是 BufWinEnter 事件.
--- 可以通过 `:au ToggleTermCommands` 查看.
--vim.cmd [[au TermOpen term://*#toggleterm#[1-9] :startinsert]]
--vim.cmd [[au BufWinEnter term://*#toggleterm#[1-9] :startinsert]]

-- -- }}}

local my_term = require("user.utils.term")

local opt = {noremap = true, silent = true}
local toggleterm_keymaps = {
  {'n', 'tt', function() my_term.toggle.my_term() end, opt, "terminal: toggle Terminal #(1-9)"},
  {'n', '<leader>t', function() my_term.toggle.all_terms() end, opt, "terminal: toggle All Terminals"},

  {'n', '<F17>', function() my_term.bottom.run_last() end, opt, "code: Re-Run Last cmd"},    -- <S-F5> re-run last cmd.
}

require('user.utils.keymaps').set(toggleterm_keymaps, {
  key_desc = {
    t = {name="Terminal"},
  },
  opts = {mode='n'},
})



