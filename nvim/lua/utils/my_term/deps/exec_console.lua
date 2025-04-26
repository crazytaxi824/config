local g = require('utils.my_term.deps.global')
local auto_scroll = require('utils.my_term.deps.auto_scroll')

local M = {}

--- namespace
local ns = vim.api.nvim_create_namespace('my_term_output')

--- highlight
vim.api.nvim_set_hl(0, "my_output_sys", {ctermfg=Colors.orange.c, fg=Colors.orange.g})
vim.api.nvim_set_hl(0, "my_output_sys_error", {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.orange.c, bg=Colors.orange.g,
})
vim.api.nvim_set_hl(0, "my_output_stdout", {ctermfg=Colors.blue.c, fg=Colors.blue.g})
vim.api.nvim_set_hl(0, "my_output_stderr", {ctermfg=Colors.red.c, fg=Colors.red.g})

local function stop_job(term_obj)
  if term_obj.job_id and vim.fn.jobstop(term_obj.job_id) == 1 then
    vim.bo[term_obj.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(term_obj.bufnr, -1, -1, true, {"signal: interrupt"})
    vim.bo[term_obj.bufnr].modifiable = false
  end
end

--- CTRL-C send interrupt signal to output-buffer ONLY. terminal already has this.
local function set_console_keymaps(term_obj)
  local opt = { buffer = term_obj.bufnr, silent = true }
  local keys = {
    {'n', '<C-c>', function() stop_job(term_obj) end, opt, "my_term: jobstop()"},
    {'i', '<C-c>', function() stop_job(term_obj) end, opt, "my_term: jobstop()"},
  }
  require('utils.keymaps').set(keys)
end

--- nvim_buf_set_lines(0, 0) 在第一行前面写入.
--- nvim_buf_set_lines(0, 1) 在第一行写入.
--- nvim_buf_set_lines(0, -1) 删除所有, 然后在第一行写入.
--- nvim_buf_set_lines(-2, -2) 在最后一行前面写入, 即: 在倒数第二行后面写入.
--- nvim_buf_set_lines(-2, -1) 在最后一行写入.
--- nvim_buf_set_lines(-1, -1) 在最后一行后面写入, 相当于 append().
local function set_buf_line_output(bufnr, data, hl)
  --- skip { "" } empty data.
  if #data == 1 and data[#data] == '' then
    return
  end

  local last_line_before_write = vim.api.nvim_buf_line_count(bufnr)

  --- 开启 modifiable 准备写入数据.
  vim.bo[bufnr].modifiable = true

  --- VVI: 处理 EOF, data 最后会多一行 empty line.
  --- `:help channel-callback`, `:help channel-lines`, 中说明: EOF is a single-item list: `['']`.
  if data[#data] == '' then
    table.remove(data, #data)
  end

  --- VVI: HACK: deal with NUL bytes, replace 所有的 '\n'.
  --- print('\0', '\x00'), log.Println(string(byte(0))) 是 <null> bytes.
  --- byte(0) 本应该是 '\null' 但是只显示了第一个字符变成了 '\n', 导致 nvim_buf_set_lines() 以为是换行符而报错.
  --vim.print(data)
  for i, d in ipairs(data) do
    -- data[i] = string.gsub(d, '\n', '\0')  -- 打印为 ^@, 同时会造成 filepath parse panic.
    data[i] = string.gsub(d, '\n', '󰟢')  -- nerdfont null
  end

  --- write output to buffer
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, data)
  vim.bo[bufnr].modifiable = false

  --- highlight lines
  for i = last_line_before_write, vim.api.nvim_buf_line_count(bufnr)-1, 1 do
    vim.hl.range(bufnr, ns, hl, {i, 0}, {i, -1})
  end
  --- BUG: vim.api.nvim_buf_clear_namespace() will clear vim.hl.range() multi-line highlight.
  -- vim.hl.range(bufnr, ns, hl, {last_line_before_write, 0}, {vim.api.nvim_buf_line_count(bufnr)-1, -1})
end

local function set_buf_line_exit(bufnr, exit_code)
  local last_line_before_write = vim.api.nvim_buf_line_count(bufnr)
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, {"", "[Process exited " .. exit_code .. "]"})

  --- highlight
  if exit_code == 0 then
    vim.hl.range(bufnr, ns, "my_output_sys", {last_line_before_write+1, 0}, {last_line_before_write+1, -1})
  else
    vim.hl.range(bufnr, ns, "my_output_sys_error", {last_line_before_write+1, 0}, {last_line_before_write+1, -1})
  end
  vim.bo[bufnr].modifiable = false
end

--- NOTE: neovim 是单线程, jobstart() 是异步函数.
M.console_exec = function(term_obj, term_win_id)
  if vim.api.nvim_win_get_buf(term_win_id) ~= term_obj.bufnr then
    return
  end

  --- set bufname
  vim.api.nvim_buf_set_name(term_obj.bufnr, "term://#my_term#console#" .. term_obj.id)

  vim.api.nvim_buf_call(term_obj.bufnr, function()
    vim.api.nvim_set_option_value('wrap', true, { scope='local', win=term_win_id })
    vim.api.nvim_set_option_value('relativenumber', false, { scope='local', win=term_win_id })
    vim.api.nvim_set_option_value('signcolumn', 'no', { scope='local', win=term_win_id })

    --- listchars 添加空格标记
    local listchars = vim.wo[term_win_id].listchars .. ',space:·'
    vim.api.nvim_set_option_value('listchars', listchars, { scope='local', win=term_win_id })
  end)

  --- print cmd
  local print_cmd
  local cmd_typ = type(term_obj.cmd)
  if cmd_typ == "string" then
    print_cmd = term_obj.cmd
  elseif cmd_typ == "table" then
    print_cmd = table.concat(term_obj.cmd, ' ')
  end

  vim.api.nvim_buf_set_lines(term_obj.bufnr, 0, -1, true, {print_cmd})  -- clear buffer text & print cmd
  vim.hl.range(term_obj.bufnr, ns, "my_output_sys", {0, 0}, {0, -1}) -- highlight cmd
  vim.bo[term_obj.bufnr].modifiable = false

  --- keymap
  set_console_keymaps(term_obj)

  term_obj.job_id = vim.fn.jobstart(term_obj.cmd, {
    cwd = term_obj.cwd,
    env = term_obj.env,

    on_stdout = function(job_id, data, event)  -- NOTE: fmt.Print()
      --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
      if not g.term_buf_exist(term_obj.bufnr) then
        return
      end

      --- write output to buffer
      set_buf_line_output(term_obj.bufnr, data, "my_output_stdout")

      --- auto_scroll option
      auto_scroll.buf_scroll_bottom(term_obj)

      --- callback
      g.exec_callbacks(term_obj.on_stdout, term_obj, job_id, data, event)
    end,

    on_stderr = function(job_id, data, event)  -- NOTE: log.Print()
      --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
      if not g.term_buf_exist(term_obj.bufnr) then
        return
      end

      --- write output to buffer
      set_buf_line_output(term_obj.bufnr, data, "my_output_stderr")

      --- auto_scroll option
      auto_scroll.buf_scroll_bottom(term_obj)

      --- callback
      g.exec_callbacks(term_obj.on_stderr, term_obj, job_id, data, event)
    end,

    on_exit = function(job_id, exit_code, event)
      --- callback
      g.exec_callbacks(term_obj.on_exit, term_obj, job_id, exit_code, event)

      --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
      if not g.term_buf_exist(term_obj.bufnr) then
        return
      end

      --- write exit to buffer
      set_buf_line_exit(term_obj.bufnr, exit_code)

      --- auto_scroll option
      auto_scroll.buf_scroll_bottom(term_obj)
    end,
  })
end

return M
