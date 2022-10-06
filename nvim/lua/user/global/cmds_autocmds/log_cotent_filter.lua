--- 离开 vim 时, 清理 log 文件 ---------------------------------------------------------------------
local function clean_log_file(filepath, regexp)
  --- lua read file --- {{{
  -- local f, err = io.open(filepath, 'r')  -- read mode
  -- if err then
  --   Notify(err, "ERROR")
  --   return
  -- end
  --
  -- if not f then
  --   Notify("lsp.log file handler is nil", "ERROR")
  --   return
  -- end
  --
  -- --- 过滤 [START]xxx 内容.
  -- local new_content = {}
  -- local content = f:read("l")
  -- while content do
  --   -- print(content)
  --   if not string.match(content, regexp) then
  --     table.insert(new_content, content)
  --   end
  --   content = f:read("l") -- 重新赋值, 否则无限循环
  -- end
  -- f:close()
  -- --print(vim.inspect(new_content))
  -- -- }}}
  --- Read File
  local content_list = vim.fn.readfile(filepath)

  --- filter content
  local new_content = {}
  for _, content in ipairs(content_list) do
    if not string.match(content, regexp) then
      table.insert(new_content, content)
    end
  end

  --- Write File
  --- lua write file --- {{{
  -- f, err = io.open(filepath, 'w+')  -- write mode, truncate content.
  -- if err then
  --   Notify(err, "ERROR")
  --   return
  -- end
  --
  -- if not f then
  --   Notify("lsp.log file handler is nil", "ERROR")
  --   return
  -- end
  --
  -- --- 写入文件
  -- _, err = f:write(table.concat(new_content, '\n'))
  -- if err then
  --   Notify(err, "ERROR")
  --   return
  -- end
  --
  -- --f:flush()  --- save to file
  -- f:close()
  -- -- }}}
  vim.fn.writefile(new_content, filepath)  -- flag: omit - 直接覆盖写入, 'a' - append 写入.
end

--- 离开 vim 时, 清理 log 文件.
vim.api.nvim_create_autocmd("VimLeave", {
  pattern = {"*"},
  once = true,  -- VimLeave execute only once
  callback = function(params)
    --- DEBUG: 退出 vim 时打印时间到指定文件.
    --local time_now = vim.fn.strftime('%Y-%m-%d %H:%M:%S')
    --vim.fn.writefile(
    --  {'[' .. time_now .. '] ' .. vim.fn.getcwd()},
    --  vim.fn.stdpath('cache') .. '/log', 'a'
    --)

    --- FIXED: log [START] nvim v0.8
    -- local lsplog = vim.fn.fnamemodify(vim.fn.stdpath('cache') .. '/lsp.log', ':p')
    -- if vim.fn.filereadable(lsplog) then
    --   clean_log_file(lsplog, "^%[START%]%[.*%] LSP logging initiated$")
    -- end

    local daplog = vim.fn.fnamemodify(vim.fn.stdpath('cache') .. '/dap.log', ':p')
    if vim.fn.filereadable(daplog) then
      clean_log_file(daplog, "^$")
    end

    -- VVI: Check if any buffers were changed outside of Vim.
    vim.cmd('checktime')
  end
})



