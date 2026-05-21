local utils = require('myplugins.my_term.deps.utils')


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


--- @param bufnr integer
--- @param data string[]
--- @param hl string  -- highlight name `vim.hl.range()`
--- @param write_to_lastline? boolean  -- 从最后一行的最后一个 col 开始 write data, 否则 write to next line
local function buf_append_data(bufnr, data, hl, write_to_lastline)
  -- if #data == 0 then return end  --- 保险起见

  local last_lnum = vim.api.nvim_buf_line_count(bufnr)  -- 获取 buffer line count
  local last_line = vim.api.nvim_buf_get_lines(bufnr, -2, -1, true)[1]  -- 获取最后一行的内容
  local last_col = string.len(last_line) -- 获取最后一行内容的的长度, vim.hl.range() 0-based byte index

  if write_to_lastline then
    --- 从最后一行的最后一个 col 开始写
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_text(bufnr, -1, -1, -1, -1, data)
    vim.bo[bufnr].modifiable = false

    --- highlight
    local start_lnum = last_lnum - 1  -- 0-based index
    local end_lnum = start_lnum + #data - 1  -- 从第 2 行开始写, 写 3 行应该是到第 5 行最后结束
    vim.hl.range(bufnr, ns, hl, { start_lnum, last_col }, { end_lnum, -1 })
  else
    --- 从最后一行的下一行开始写
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
    vim.bo[bufnr].modifiable = false

    --- highlight
    local start_lnum = last_lnum  -- 从最后一行的下一行开始 highlight
    local end_lnum = start_lnum + #data - 1  -- 从第 2 行开始写, 写 3 行应该是到第 5 行最后结束
    vim.hl.range(bufnr, ns, hl, { start_lnum, 0 }, { end_lnum, -1 })
  end
end

--- @param bufnr integer
--- @param data string[]
--- @param hl string  -- highlight name `vim.hl.range()`
--- @param write_to_lastline? boolean  -- 从最后一行的最后一个 col 开始 write data, 否则 write to next line
--- @return boolean  -- incomplete data
local function set_buf_line_output(bufnr, data, hl, write_to_lastline)
  --- 检查 buffer 是否存在, 避免 on_stdout, on_stderr, on_exit 异步执行完成后, buffer 已被销毁
  if not vim.api.nvim_buf_is_valid(bufnr) or not data then
    return false
  end

  --- VVI: `:help channel-callback`, `:help channel-lines`, 中说明: EOF is a single-item list: `['']`.
  --- 如果 data 为: { "foo", "bar" }, 说明本行未结束, 需要在本行后面继续写入以后的内容. eg: fmt.Print()
  --- 如果 data 为: { "foo", "bar", "" }, 说明本行已结束, 需要换行写入以后的内容.  eg: fmt.Println()
  --- 如果 data 为: { "" }, 说明整个输出结束. stdout, stderr 会分别输出一个 {""} 表示结束.
  ---
  --- @type boolean
  local next_incomplete

  if data[#data] == "" then
    table.remove(data, #data)  -- 处理 EOF
    next_incomplete = false
  else
    next_incomplete = true
  end

  --- 如果这里的 data 为 {} 空 list, 说明 stdout/stderr 已经完全结束了
  if #data > 0 then
    --- VVI: deal with NUL bytes, replace 所有的 '\n'.
    --- lua print('\0', '\x00', string.char(0)), log.Println(string(byte(0))) 是 <null> bytes.
    --- byte(0) 本应该是 '\null' 但是只显示了第一个字符变成了 '\n', 导致 nvim_buf_set_lines() 以为是换行符而报错.
    for i = 1, #data do
      data[i] = data[i]:gsub('\n', string.char(0))
    end

    buf_append_data(bufnr, data, hl, write_to_lastline)
  end

  return next_incomplete
end

--- job done 后处理: 在最后一行显示 [Process exited 'exit_code']
---
--- @param bufnr integer
--- @param job_id integer
--- @param exit_code integer
local function set_buf_line_exit(bufnr, job_id, exit_code)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local data = { "[Process exited " .. exit_code .. "]" }
  if exit_code == 0 then
    buf_append_data(bufnr, data, "my_output_sys")
  else
    buf_append_data(bufnr, data, "my_output_sys_error")
  end
end

--- print cmd, job info
---
--- @param cmd string|string[]
--- @param term_bufnr integer
--- @param job_id integer
local function print_job_info(cmd, term_bufnr, job_id)
  local data = {}  ---@type string[]

  if type(cmd) == "string" then
    table.insert(data, cmd)
    table.insert(data, "[type(cmd) is string, may need to vim.fn.shellescape(filepath)]")
  elseif type(cmd) == "table" then
    table.insert(data, table.concat(cmd, ' '))
  else
    error("term.cmd is not string|string[]")
  end

  --- process, job info
  local job_info = "[Process: " .. vim.fn.jobpid(job_id) .. " (job: " .. job_id .. ") starts]"
  table.insert(data, job_info)

  --- highlight
  buf_append_data(term_bufnr, data, "my_output_sys", true)
end

--- 强制结束 job
---
--- @param bufnr integer
--- @param job_id integer
local function stop_job(bufnr, job_id)
  if vim.fn.jobstop(job_id) == 1 then
    buf_append_data(bufnr, { "^C signal: interrupt" }, "my_output_sys" )
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
    {'n', '<C-l>', function()
      local win_id = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_get_buf(win_id) == term_bufnr then
        vim.api.nvim_set_option_value('wrap', not vim.wo[win_id].wrap, { scope='local', win=win_id })
      end
    end, opt, "my_term: toggle wrap" },
  }
  require('utils.keymaps').set(keys)
end

--- 后台执行 jobstart(cmd), 将 output 手动写入 buffer. (buftype = 'nofile')
--- 主要区别是 `:help jobstart-options` { term = nil|false } 在后台运行, 结果需要手动输出.
---
--- @param cmd string|string[]
--- @param term MyTerm
--- @param term_bufnr integer
--- @param term_win_id integer
--- @return integer job_id
function M.console_exec(cmd, term, term_bufnr, term_win_id)
  if vim.api.nvim_win_get_buf(term_win_id) ~= term_bufnr then
    error("MyTerm win_id and bufnr do not match")
  end

  --- set bufname
  --- VVI: bufname 如果是 term://xxx 则在 bdelete 之后会被锁定为 nomodifiable
  vim.api.nvim_buf_set_name(term_bufnr, "console://console#" .. term.id)

  --- setlocal opts
  vim.bo[term_bufnr].undolevels = -1  -- disable undo
  vim.bo[term_bufnr].modifiable = false

  local opts = { scope='local', win=term_win_id }
  vim.api.nvim_set_option_value('wrap', true, opts)
  vim.api.nvim_set_option_value('relativenumber', false, opts)
  vim.api.nvim_set_option_value('signcolumn', 'no', opts)

  --- on_stderr, on_stdout 中的 data line 是否完整
  local incomplete = false

  --- jobstart()
  local job_id = vim.fn.jobstart(cmd, {
    cwd = term:cwd(),
    env = term:env(),

    --- @param job_id integer
    --- @param data string[]  output
    --- @param event string  'stdout'
    on_stdout = function(job_id, data, event)  -- NOTE: for fmt.Println()
      --- write output to buffer
      incomplete = set_buf_line_output(term_bufnr, data, "my_output_stdout", incomplete)

      --- auto_scroll option
      utils.buf_scroll_bottom(term, term_bufnr)

      --- callback
      local callbacks = term:on_stdout()
      if callbacks then
        for _, on_stdout in ipairs(callbacks) do
          on_stdout(term, term_bufnr, job_id, data)
        end
      end
    end,

    --- @param job_id integer
    --- @param data string[]  err_msg
    --- @param event string  'stderr'
    on_stderr = function(job_id, data, event)  -- NOTE: for log.Println()
      --- write error to buffer
      incomplete = set_buf_line_output(term_bufnr, data, "my_output_stderr", incomplete)

      --- auto_scroll option
      utils.buf_scroll_bottom(term, term_bufnr)

      --- callback
      local callbacks = term:on_stderr()
      if callbacks then
        for _, on_stderr in ipairs(callbacks) do
          on_stderr(term, term_bufnr, job_id, data)
        end
      end
    end,

    --- @param job_id integer
    --- @param exit_code integer
    --- @param event string  'exit'
    on_exit = function(job_id, exit_code, event)
      --- write [exit_code] to buffer
      set_buf_line_exit(term_bufnr, job_id, exit_code)

      --- auto_scroll option
      utils.buf_scroll_bottom(term, term_bufnr)

      --- callback
      local callbacks = term:on_exit()
      if callbacks then
        for _, on_exit in ipairs(callbacks) do
          on_exit(term, term_bufnr, job_id, exit_code)
        end
      end
    end,
  })

  if job_id <= 0 then
    error("jobstart failed: " .. vim.inspect(cmd))
  end

  --- print cmd, job info
  --- vim.fn.jobstart() 是异步函数, 所以 print_job_info() 会在 on_stdout, on_stderr 之前执行.
  print_job_info(cmd, term_bufnr, job_id)

  --- keymap
  set_console_keymaps(term_bufnr, job_id)

  return job_id
end

return M
