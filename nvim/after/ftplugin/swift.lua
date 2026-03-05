local function swift_run_file()
  --- 先相对 HOME, 再相对 cwd. (absolut filepath)
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.')

  local t = require('utils.my_term').console()
  t:update({
    cmd = "swift -- " .. file
  })
  t:stop()
  t:run()
end

local function swift_run_proj()
  local t = require('utils.my_term').console()
  t:update({
    cmd = "swift run"
  })
  t:stop()
  t:run()
end

local function swift_test_all()
  local t = require('utils.my_term').console()
  t:update({
    cmd = "swift test"
  })
  t:stop()
  t:run()
end

local function swift_test_pkg()
  --- 是否在 Tests 文件夹中
  local dir = vim.fs.find({'Tests'}, {
    upward = true,
    stop = vim.uv.cwd(),
    type = 'directory',
  })

  if #dir < 1 then
    Notify('file is not in "Tests" dir', "ERROR")
    return
  end


  --- 判断 class 是否为 class .*: XCTestCase
  local lcontent = vim.api.nvim_get_current_line()  -- 获取当前行内容
  local test_class = lcontent:match("class%s+([%w_]+)%s*:%s*[%w_]+TestCase")
  if not test_class then
    Notify('not XCTestCase class', "ERROR")
    return
  end

  local t = require('utils.my_term').console()
  t:update({
    cmd = "swift test --filter " .. test_class
  })
  t:stop()
  t:run()
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
local opt = { buffer = 0 }

local swift_keymaps = {
  {'n', '<F17>',  function() swift_run_file() end, opt, "Fn 5: code: Swift Run File"},
  {'n', '<F5>',  function() swift_run_proj() end, opt, "Fn 5: code: Swift Run Project"},
  {'n', '<F6>', function() swift_test_pkg() end, opt, "Fn 6: code: Swift Test Package"},
  {'n', '<D-F6>', function() swift_test_all() end, opt, "Fn 6: code: Swift Test All"},
}

require('utils.keymaps').set(swift_keymaps)



