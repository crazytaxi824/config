local status_ok, term = pcall(require, "toggleterm.terminal")
if not status_ok then
  return
end

local Terminal = term.Terminal

local js_term_id = 1025   -- NOTE: toggleterm count id

--- Terminal options for js only ---
local js_opts = {
  hidden = true,          -- VVI: true - 不加入到 terminal list, 无法被 `:ToggleTerm` 找到.
                          -- 用 :q 只能隐藏, 用 :q! exit job.
  close_on_exit = false,  -- 运行完成之后不要关闭 terminal.
  count = js_term_id,     -- 这里是指定 id, 类似 `:100ToggleTerm`,
                          -- 就算是 hidden 状态也可以通过 `:100ToggleTerm` 重新打开.
                          -- 如果两个 Terminal 有相同的 ID, 则会出现错误.

  --- move to previous window when job ends.
  -- on_exit = function()
  --   vim.cmd('wincmd p')  -- move to previous window
  -- end
}

--- node file --------------------------------------------------------------------------------------
local function js_run(file)
  -- VVI: 删除之前的 terminal.
  vim.cmd('silent! bw! term://*toggleterm#'..js_term_id)
  local js = Terminal:new(vim.tbl_deep_extend('force', js_opts, { cmd = "node " .. file }))
  js:toggle()
end

--- jest file --------------------------------------------------------------------------------------
local function js_jest(file, coverage)
  -- check xxx.test.js file
  if not string.match(file, ".*%.test%.js$") then
    Notify("not a test file.", "ERROR")
    return
  end

  local cmd = ''
  if coverage then
    cmd = "jest --coverage " .. file
  else
    cmd = "jest " .. file
  end

  vim.cmd('silent! bw! term://*toggleterm#'..js_term_id)
  local js = Terminal:new(vim.tbl_deep_extend('force', js_opts, { cmd = cmd }))
  js:toggle()
end


--- keymap -----------------------------------------------------------------------------------------
local opt = {noremap = true, buffer = true}

--- run current_file ---
vim.keymap.set('n', '<F5>', function() js_run(vim.fn.expand('%')) end, opt)

vim.keymap.set('n', '<F6>', function() js_jest(vim.fn.expand('%'), false) end, opt)
vim.keymap.set('n', '<F18>', function() js_jest(vim.fn.expand('%'), true) end, opt)  -- <S-F6>



