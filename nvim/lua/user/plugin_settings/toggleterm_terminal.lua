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

  close_on_exit = true,      -- 执行完成之后退出 terminal. 输入 exit | <C-d> 之后关闭 terminal.
  start_in_insert = false,   -- VVI: 全局模式, 不好用. 打开 terminal 时进入 insert 模式.
  direction = "horizontal",  -- vertical | horizontal | tab | float

  hide_numbers = false,  -- 隐藏 teriminal 行号, 会影响后打开的 window 也没有 number.
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
  -- on_open  = fun(t: Terminal), -- TermOpen
  -- on_close = fun(t: Terminal), -- TermLeave, term 关闭
  -- on_exit  = fun(t: Terminal, job: number, exit_code: number, name: string) -- TermClose, job ends.
  -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
  -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
  -- -- }}}
})

--- terminal key mapping ---------------------------------------------------------------------------
--- VVI: <leader>t 打开指定 id=99 的 terminal.
vim.keymap.set('n', '<leader>t', ':99ToggleTerm<CR>', {noremap = true, silent = true})

--- VVI: toggleterm#60-99 自动进入 insert mode, 用于下面的 _NODE_TOGGLE() 和 _PYTHON_TOGGLE() 等.
vim.cmd [[au TermOpen term://*toggleterm#[6-9][0-9] :startinsert]]

--- 绑定 <ESC> 进入 terminal normal 模式, 只对本 buffer 有效.
vim.cmd [[au TermOpen term://* tnoremap <buffer> <ESC> <C-\><C-n>]]

--- 以下是通过 Terminal 运行 shell cmd --------------------------------------------------------------
--- NOTE: 可以参考 "~/.config/nvim/after/ftplugin/go/gorun_gotest.lua"

local Terminal = require("toggleterm.terminal").Terminal

local node = Terminal:new({ cmd = "node", hidden = true, direction = "float", count = 61 })
function _NODE_TOGGLE()
  node:toggle()
end

local python = Terminal:new({ cmd = "python3", hidden = true, direction = "float", count = 62 })
function _PYTHON_TOGGLE()
  python:toggle()
end

--- 使用 `:lua _LAZYGIT_TOGGLE()` 运行, 下同.
-- local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
-- function _LAZYGIT_TOGGLE()
--   lazygit:toggle()
-- end



