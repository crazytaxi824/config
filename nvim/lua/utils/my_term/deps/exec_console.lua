local utils = require('utils.my_term.deps.utils')

local M = {}

--- namespace
local ns = vim.api.nvim_create_namespace('my_term_output')

--- highlight
vim.api.nvim_set_hl(0, "my_output_sys", {ctermfg=Colors.orange.c, fg=Colors.orange.g})
vim.api.nvim_set_hl(0, "my_output_sys_error", {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.red.c, bg=Colors.red.g,
})
vim.api.nvim_set_hl(0, "my_output_stdout", {ctermfg=Colors.blue.c, fg=Colors.blue.g})
vim.api.nvim_set_hl(0, "my_output_stderr", {ctermfg=Colors.red.c, fg=Colors.red.g})
vim.api.nvim_set_hl(0, "my_output_eof", {ctermfg=Colors.g238.c, fg=Colors.g238.g})

--- 强制结束 job
---
--- @param term_bufnr integer
--- @param job_id integer
local function stop_job(term_bufnr, job_id)
  if vim.fn.jobstop(job_id) == 1 then
    vim.api.nvim_buf_set_lines(term_bufnr, -1, -1, true, {"^C"})
  end
end

--- CTRL-C send interrupt signal to output-buffer ONLY. terminal already has this.
---
--- @param term_bufnr integer
--- @param job_id integer
local function set_console_keymaps(term_bufnr, job_id)
  local opt = { buffer = term_bufnr, silent = true }
  local keys = {
    {'n', '<C-c>', function() stop_job(term_bufnr, job_id) end, opt, "my_term: jobstop()"},
    {'i', '<C-c>', function() stop_job(term_bufnr, job_id) end, opt, "my_term: jobstop()"},
  }
  require('utils.keymaps').set(keys)
end

--- nvim_buf_set_lines(0, 0) 在第一行前面写入.
--- nvim_buf_set_lines(0, 1) 在第一行写入.
--- nvim_buf_set_lines(0, -1) 删除所有, 然后在第一行写入.
--- nvim_buf_set_lines(-2, -2) 在最后一行前面写入, 即: 在倒数第二行后面写入.
--- nvim_buf_set_lines(-2, -1) 在最后一行写入.
--- nvim_buf_set_lines(-1, -1) 在最后一行后面写入, 相当于 append().
---
--- @param bufnr integer
--- @param data string[]
--- @param hl string  highlight name `vim.hl.range()`
local function set_buf_line_output(bufnr, data, hl)
  --- skip { "" } empty data.
  if #data == 1 and data[#data] == '' then
    return
  end

  --- cache 开始进行 highlight 的 lnum
  local hl_start_lnum = vim.api.nvim_buf_line_count(bufnr)

  --- VVI: 处理 EOF, data 最后会多一行 empty line.
  --- `:help channel-callback`, `:help channel-lines`, 中说明: EOF is a single-item list: `['']`.
  if data[#data] == '' then
    table.remove(data, #data)
  end

  --- VVI: deal with NUL bytes, replace 所有的 '\n'.
  --- print('\0', '\x00'), log.Println(string(byte(0))) 是 <null> bytes.
  --- byte(0) 本应该是 '\null' 但是只显示了第一个字符变成了 '\n', 导致 nvim_buf_set_lines() 以为是换行符而报错.
  for i, d in ipairs(data) do
    data[i] = string.gsub(d, '\n', '\0')  -- 打印为 ^@
  end

  --- append output {data} to buffer
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, data)

  --- highlight lines
  vim.hl.range(bufnr, ns, hl, {hl_start_lnum, 0}, {vim.api.nvim_buf_line_count(bufnr)-1, -1})
end

--- job done 后处理: 在最后一行显示 [Process exited 'exit_code']
---
--- @param bufnr integer
--- @param job_id integer
--- @param exit_code integer
local function set_buf_line_exit(bufnr, job_id, exit_code)
  local hl_start_lnum = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, {"[EOF]", "[Process (job: " .. job_id .. ") has exited: " .. exit_code .. "]"})

  --- highlight
  vim.hl.range(bufnr, ns, "my_output_eof", {hl_start_lnum, 0}, {hl_start_lnum, -1})
  if exit_code == 0 then
    vim.hl.range(bufnr, ns, "my_output_sys", {hl_start_lnum+1, 0}, {hl_start_lnum+1, -1})
  else
    vim.hl.range(bufnr, ns, "my_output_sys_error", {hl_start_lnum+1, 0}, {hl_start_lnum+1, -1})
  end
end

--- print cmd, job info
---
--- @param term MyTerm
--- @param term_bufnr integer
--- @param job_id integer
local function print_job_info(term, term_bufnr, job_id)
  local lines = {}  ---@type string[]

  --- cmd string
  local cmd = term.cmd()
  if type(cmd) == "string" then
    table.insert(lines, cmd)
  elseif type(cmd) == "table" then
    table.insert(lines, table.concat(cmd, ' '))
  else
    error("term.cmd is not string|string[]")
  end

  --- process, job info
  local job_info = "[Process: " .. vim.fn.jobpid(job_id) .. " (job: " .. job_id .. ") starts]"
  table.insert(lines, job_info)

  --- highlight
  vim.api.nvim_buf_set_lines(term_bufnr, 0, -1, true, lines)  -- clear buffer text & print cmd
  vim.hl.range(term_bufnr, ns, "my_output_sys", {0, 0}, {#lines-1, -1}) -- highlight cmd
end

--- 后台执行 jobstart(cmd), 将 output 手动写入 buffer. (buftype = 'nofile')
--- 主要区别是 `:help jobstart-options` { term = nil|false } 在后台运行, 结果需要手动输出.
---
--- @param term MyTerm
--- @param term_bufnr integer
--- @param term_win_id integer
--- @return integer job_id
function M.console_exec(term, term_bufnr, term_win_id)
  if vim.api.nvim_win_get_buf(term_win_id) ~= term_bufnr then
    error("MyTerm win_id and bufnr do not match")
  end

  local cmd = term.cmd()
  if not cmd then
    error("MyTerm.cmd is missing")
  end

  --- set bufname
  vim.api.nvim_buf_set_name(term_bufnr, "term://#my_term#console#" .. term.id)

  --- setlocal opts
  vim.api.nvim_set_option_value('wrap', true, { scope='local', win=term_win_id })
  vim.api.nvim_set_option_value('relativenumber', false, { scope='local', win=term_win_id })
  vim.api.nvim_set_option_value('signcolumn', 'no', { scope='local', win=term_win_id })

  --- VVI: "prompt" 不能通过 insert mode 修改内容, 只能用 nvim_buf_set_lines() 修改内容.
  vim.api.nvim_set_option_value('buftype', 'prompt', { scope='local', buf=term_bufnr })

  --- 处理 prompt input
  vim.fn.prompt_setprompt(term_bufnr, "> ")
  vim.fn.prompt_setcallback(term_bufnr, function(input)
    if input == 'exit' then
      vim.api.nvim_buf_delete(term_bufnr, {force = true})  --- :bwipeout
    end
  end)

  local job_id = vim.fn.jobstart(cmd, {
    cwd = term.cwd(),
    env = term.env(),

    --- @param job_id integer
    --- @param data string[]  output
    --- @param event string  'stdout'
    on_stdout = function(job_id, data, event)  -- NOTE: for fmt.Println()
      set_buf_line_output(term_bufnr, data, "my_output_stdout")  --- write output to buffer
      utils.buf_scroll_bottom(term, term_bufnr)  --- auto_scroll option

      --- callback
      local callbacks = term.on_stdout()
      if callbacks then
        for _, on_stdout in ipairs(callbacks) do
          on_stdout(term, term_bufnr, job_id, data)
        end

        --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
        if not vim.api.nvim_buf_is_valid(term_bufnr) then
          error("should not delete terminal buffer")
        end
      end
    end,

    --- @param job_id integer
    --- @param data string[]  err_msg
    --- @param event string  'stderr'
    on_stderr = function(job_id, data, event)  -- NOTE: for log.Println()
      set_buf_line_output(term_bufnr, data, "my_output_stderr")  --- write output to buffer
      utils.buf_scroll_bottom(term, term_bufnr)  --- auto_scroll option

      --- callback
      local callbacks = term.on_stderr()
      if callbacks then
        for _, on_stderr in ipairs(callbacks) do
          on_stderr(term, term_bufnr, job_id, data)
        end

        --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
        if not vim.api.nvim_buf_is_valid(term_bufnr) then
          error("should not delete terminal buffer")
        end
      end
    end,

    --- @param job_id integer
    --- @param exit_code integer
    --- @param event string  'exit'
    on_exit = function(job_id, exit_code, event)
      set_buf_line_exit(term_bufnr, job_id, exit_code)   --- write [exit_code] to buffer
      utils.buf_scroll_bottom(term, term_bufnr)  --- auto_scroll option

      --- callback
      local callbacks = term.on_exit()
      if callbacks then
        for _, on_exit in ipairs(callbacks) do
          on_exit(term, term_bufnr, job_id, exit_code)
        end
      end
    end,
  })

  --- print cmd, job info
  --- vim.fn.jobstart() 是异步函数, 所以 print_job_info() 会在 on_stdout, on_stderr 之前执行.
  print_job_info(term, term_bufnr, job_id)

  --- keymap
  set_console_keymaps(term_bufnr, job_id)

  return job_id
end

return M
