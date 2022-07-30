--- typescript -------------------------------------------------------------------------------------
--- tsc ts_file && node js_file --------------------------------------------------------------------
--- tsc -p ./tsconfig.json   -- 将 ts 编译成 js 文件.
--- node ./dist/xxx.js       -- 使用 node 运行编译后的 js 文件.
--- NOTE: dist 文件夹是 tsconfig.json 中 "outDir" 定义的.
---       src/ 文件夹是 tsconfig.json 中 "include" 定义的.
---       所以运行时 pwd 必须是在 tsconfig 所在文件夹, 即 project root 文件夹.
local function ts_run(file)
  --- check tsconfig.json file
  local pwd = vim.fn.getcwd()
  if vim.fn.filereadable(pwd..'/tsconfig.json') == 0 then
    Notify("'tsconfig.json' is missing.", "ERROR")
    return
  end

  _Exec("tsc -p ./tsconfig.json && node dist/" .. file .. '.js')
end

--- jest js_file -----------------------------------------------------------------------------------
local function ts_jest(file, coverage)
  --- check xxx.test.js file
  if not string.match(file, ".*%.test$") then
    Notify("not a test file.", "ERROR")
    return
  end

  --- check tsconfig.json file
  local pwd = vim.fn.getcwd()
  if vim.fn.filereadable(pwd..'/tsconfig.json') == 0 then
    Notify("'tsconfig.json' is missing.", "ERROR")
    return
  end

  local cmd = ''
  if coverage then
    cmd = "tsc -p ./tsconfig.json && jest --coverage dist/" .. file ..'.js'
  else
    cmd = "tsc -p ./tsconfig.json && jest dist/" .. file ..'.js'
  end

  _Exec(cmd)
end

--- keymap -----------------------------------------------------------------------------------------
local opt = {noremap = true, buffer = true}

--- run dist/current_file ---
vim.keymap.set('n', '<F5>', function() ts_run(vim.fn.expand('%:.:r')) end, opt)

vim.keymap.set('n', '<F6>', function() ts_jest(vim.fn.expand('%:.:r'), false) end, opt)
vim.keymap.set('n', '<F18>', function() ts_jest(vim.fn.expand('%:.:r'), true) end, opt)  -- <S-F6>



