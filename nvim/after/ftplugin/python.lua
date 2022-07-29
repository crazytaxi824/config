local status_ok, term = pcall(require, "toggleterm.terminal")
if not status_ok then
  return
end

local Terminal = term.Terminal

local py_term_id = 1027   -- NOTE: toggleterm count id

--- Terminal options for ts only ---
local py_opts = {
  hidden = true,          -- VVI: true - 不加入到 terminal list, 无法被 `:ToggleTerm` 找到.
                          -- 用 :q 只能隐藏, 用 :q! exit job.
  close_on_exit = false,  -- 运行完成之后不要关闭 terminal.
  count = py_term_id,     -- 这里是指定 id, 类似 `:100ToggleTerm`,
                          -- 就算是 hidden 状态也可以通过 `:100ToggleTerm` 重新打开.
                          -- 如果两个 Terminal 有相同的 ID, 则会出现错误.

  --- move to previous window when job ends.
  -- on_exit = function()
  --   vim.cmd('wincmd p')  -- move to previous window
  -- end
}

local function py_run(file)
  -- VVI: 删除之前的 terminal.
  vim.cmd('silent! bw! term://*toggleterm#'..py_term_id)
  local py = Terminal:new(vim.tbl_deep_extend('force', py_opts,
    { cmd = "python3 -- " .. file })
  )
  py:toggle()
end

--- key mapping ------------------------------------------------------------------------------------
local opt = {noremap = true, buffer = true}

--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.fn.expand('%')) end, opt)



