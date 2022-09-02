local function clean_log_file(filepath, regexp)
  --- Read File
  local f, err = io.open(filepath, 'r')  -- read mode
  if err then
    Notify(err, "ERROR")
    return
  end

  if not f then
    Notify("lsp.log file handler is nil", "ERROR")
    return
  end

  --- 过滤 [START]xxx 内容.
  local new_content = {}
  local content = f:read("l")
  while content do
    -- print(content)
    if not string.match(content, regexp) then
      table.insert(new_content, content)
    end
    content = f:read("l") -- 重新赋值, 否则无限循环
  end
  f:close()
  --print(vim.inspect(new_content))

  --- Write File
  f, err = io.open(filepath, 'w+')  -- write mode, truncate content.
  if err then
    Notify(err, "ERROR")
    return
  end

  if not f then
    Notify("lsp.log file handler is nil", "ERROR")
    return
  end

  --- 写入文件
  _, err = f:write(vim.fn.join(new_content, '\n'))
  if err then
    Notify(err, "ERROR")
    return
  end

  --f:flush()  --- save to file
  f:close()
end

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = {"*"},
  once = true,
  callback = function()
    vim.schedule(function()
      local lsplog = vim.fn.fnamemodify(vim.fn.stdpath('cache') .. '/lsp.log', ':p')
      if vim.fn.filereadable(lsplog) then
        clean_log_file(lsplog, "^%[START%]%[.*%] LSP logging initiated$")
      end

      local daplog = vim.fn.fnamemodify(vim.fn.stdpath('cache') .. '/dap.log', ':p')
      if vim.fn.filereadable(daplog) then
        clean_log_file(daplog, "^$")
      end

      vim.cmd('checktime')
    end)
  end
})



