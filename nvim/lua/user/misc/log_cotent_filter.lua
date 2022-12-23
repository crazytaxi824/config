--- 离开 vim 时, 清理 log 文件 ---------------------------------------------------------------------
local file_list = {
  vim.fn.stdpath('log') .. '/log',
  vim.fn.stdpath('log') .. '/lsp.log',
  vim.fn.stdpath('log') .. '/mason.log',
  vim.fn.stdpath('log') .. '/luasnip.log',

  vim.fn.stdpath('cache') .. '/dap.log',
  vim.fn.stdpath('cache') .. '/null-ls.log',
  vim.fn.stdpath('cache') .. '/null-tree.log',
  vim.fn.stdpath('cache') .. '/packer.nvim.log',
  vim.fn.stdpath('cache') .. '/telescope.log',

  --- 以下是自定义 log 文件位置.
  vim.fn.stdpath('cache') .. '/custom_lsp_handler.log',
  vim.fn.stdpath('cache') .. '/packer.myupdate.log',
}

--- 判断文件大小是否超过 n(MB)
local function file_size_over_MB(fpath, size)
  --- 判断文件是否存在
  if vim.fn.filereadable(fpath) == 0 then
    return false
  end

  --- size 大小默认为 10
  size = size or 10

  --- 判断文件大小是否超过
  local fsize = vim.fn.getfsize(fpath)  -- 单位(B)
  if fsize > size*1024*1024 then
    return true
  end
end

--- 删除文件中的旧内容以达到 reduce file size 的目的.
local function reduce_filesize(fpath)
  --- Read File
  local content_list = vim.fn.readfile(fpath)

  --- 截取从 [1/4 ~ 最后] 行的数据.
  local remain_content = vim.list_slice(content_list, math.ceil(#content_list/4))

  --- 写入数据
  vim.fn.writefile(remain_content, fpath)  -- flag: omit - 直接覆盖写入, 'a' - append 写入.
  --- ":checktime" 在下面统一执行.
end

--- 根据 regexp 删除文件行内容.
local function trim_prefix_blankline(filepath, regexp)
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
  local line_num
  for i, content in ipairs(content_list) do
    if not string.match(content, regexp) then
      line_num = i
      break
    end
  end

  if not line_num then
    line_num = #content_list+1
  elseif line_num == 1 then
    return
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
  vim.fn.writefile(vim.list_slice(content_list, line_num), filepath)  -- flag: omit - 直接覆盖写入, 'a' - append 写入.
  --- ":checktime" 在下面统一执行.
end

--- 离开 vim 时, 清理 log 文件.
vim.api.nvim_create_autocmd("VimLeave", {
  pattern = {"*"},
  once = true,  -- VimLeave execute only once
  callback = function(params)
    --- 特殊处理 dap.log 文件中大量的空白行.
    local daplog = vim.fn.stdpath('cache') .. '/dap.log'
    if vim.fn.filereadable(daplog) == 1 then
      trim_prefix_blankline(daplog, "^$")
    end

    --- 如果 log 文件超过指定大小, 则删除文件前半部分的数据.
    for _, fpath in ipairs(file_list) do
      if file_size_over_MB(fpath, 6) then
        reduce_filesize(fpath)
      end
    end

    --- VVI: Check if any buffers were changed outside of Vim.
    vim.cmd('checktime')
  end
})



