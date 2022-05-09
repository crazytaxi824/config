local status_ok, term = pcall(require, "toggleterm.terminal")
if not status_ok then
	return
end

local Terminal = term.Terminal

local ts_term_id = 1026   -- VVI: toggleterm count id

--- Terminal options for ts only ---
local ts_opts = {
  hidden = true,          -- VVI: true - 不加入到 terminal list, 无法被 `:ToggleTerm` 找到.
                          -- 用 :q 只能隐藏, 用 :q! exit job.
  close_on_exit = false,  -- NOTE: 运行完成之后不要关闭 terminal.
  count = ts_term_id,     -- NOTE: 这里是指定 id, 类似 `:100ToggleTerm`,
                          -- 就算是 hidden 状态也可以通过 `:100ToggleTerm` 重新打开.
                          -- 如果两个 Terminal 有相同的 ID, 则会出现错误.
  on_open = function()
    vim.cmd('wincmd p')  -- move to previous window
  end
}

--- node file --------------------------------------------------------------------------------------
--- tsc -p ./tsconfig.json   -- 将 ts 编译成 js 文件.
--- node ./dist/xxx.js       -- 使用 node 运行编译后的 js 文件.
--- VVI: dist 文件夹是 tsconfig.json 中 "outDir" 定义的.
---      src/ 文件夹是 tsconfig.json 中 "include" 定义的.
---      所以运行时 pwd 必须是在 tsconfig 所在文件夹, 即 project root 文件夹.
local function tsRun(file)
  -- check tsconfig.json file
  local pwd = vim.fn.getcwd()
  if vim.fn.filereadable(pwd..'/tsconfig.json') == 0 then
    vim.api.nvim_echo({{' tsconfig is missing, please check your pwd. ', "ErrorMsg"}}, false, {})
    return
  end

  -- NOTE: 删除之前的 terminal.
  vim.cmd('silent! bw! term://*toggleterm#'..ts_term_id)
  local ts = Terminal:new(vim.tbl_deep_extend('force', ts_opts, { cmd = "tsc -p ./tsconfig.json && node dist/" .. file ..'.js' }))
  ts:toggle()
end

--- jest file --------------------------------------------------------------------------------------
local function tsJest(file, coverage)
  -- check xxx.test.js file
  if not string.match(file, ".*%.test$") then
    vim.api.nvim_echo({{' not a test file. ', "ErrorMsg"}}, false, {})
    return
  end

  -- check tsconfig.json file
  local pwd = vim.fn.getcwd()
  if vim.fn.filereadable(pwd..'/tsconfig.json') == 0 then
    vim.api.nvim_echo({{' tsconfig is missing, please check your pwd. ', "ErrorMsg"}}, false, {})
    return
  end

  local cmd = ''
  if coverage then
    cmd = "tsc -p ./tsconfig.json && jest --coverage dist/" .. file ..'.js'
  else
    cmd = "tsc -p ./tsconfig.json && jest dist/" .. file ..'.js'
  end

  -- NOTE: 删除之前的 terminal.
  vim.cmd('silent! bw! term://*toggleterm#'..ts_term_id)
  local ts = Terminal:new(vim.tbl_deep_extend('force', ts_opts, { cmd = cmd }))
  ts:toggle()
end

--- keymap -----------------------------------------------------------------------------------------
local opt = {noremap = true, buffer = true}

--- run dist/current_file ---
vim.keymap.set('n', '<F5>', function() tsRun(vim.fn.expand('%:.:r')) end, opt)

vim.keymap.set('n', '<F6>', function() tsJest(vim.fn.expand('%:.:r'), false) end, opt)
vim.keymap.set('n', '<F18>', function() tsJest(vim.fn.expand('%:.:r'), true) end, opt)  -- <S-F6>


