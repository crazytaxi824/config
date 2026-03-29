--- typescript -------------------------------------------------------------------------------------
--- tsc ts_file && node js_file --------------------------------------------------------------------

--- `tsc -p ./tsconfig.json`   -- 将 ts 编译成 js 文件.
--- `node ./dist/xxx.js`       -- 使用 node 运行编译后的 js 文件.
--- NOTE: dist 文件夹是 tsconfig.json 中 "outDir" 定义的.
---       src/ 文件夹是 tsconfig.json 中 "include" 定义的.
---       所以运行时 pwd 必须是在 tsconfig 所在文件夹, 即 project root 文件夹.
---
--- @param filename string
local function ts_run(filename)
  --- check tsconfig.json file
  local pwd = vim.uv.cwd()
  if not vim.uv.fs_stat(pwd..'/tsconfig.json') then
    Notify("'tsconfig.json' is missing.", "ERROR")
    return
  end

  local t = require('myplugins.my_term').console()
  t:stop()
  t:run("tsc -p ./tsconfig.json && node dist/" .. filename .. '.js')
end

--- jest js_file -----------------------------------------------------------------------------------

--- jest 进行 test
---
--- @param filename string
--- @param coverage string|boolean|nil  标记: 是否使用 `--coverage`
local function ts_jest(filename, coverage)
  --- check xxx.test.js file
  if not string.match(filename, ".*%.test$") then
    Notify("not a test file.", "ERROR")
    return
  end

  --- check tsconfig.json file
  local pwd = vim.uv.cwd()
  if not vim.uv.fs_stat(pwd..'/tsconfig.json') then
    Notify("'tsconfig.json' is missing.", "ERROR")
    return
  end

  local cmd = ''
  if coverage then
    cmd = "tsc -p ./tsconfig.json && jest --coverage dist/" .. filename ..'.js'
  else
    cmd = "tsc -p ./tsconfig.json && jest dist/" .. filename ..'.js'
  end

  local t = require('myplugins.my_term').console()
  t:stop()
  t:run(cmd)
end

--- keymap -----------------------------------------------------------------------------------------
local opt = { buffer = 0 }
local ts_keymaps = {
  --- run dist/current_file ---
  {'n', '<F5>', function() ts_run(vim.fn.expand('%:.:r')) end, opt, "Fn 5: code: Run File"},

  --- jest test ---
  {'n', '<F6>', function() ts_jest(vim.fn.expand('%:.:r'), false) end, opt, "Fn 6: code: Run Test"},
  {'n', '<D-F6>', function() ts_jest(vim.fn.expand('%:.:r'), true) end, opt, "Fn 6: code: Run Test --coverage"},
}

require('utils.keymaps').set(ts_keymaps)



