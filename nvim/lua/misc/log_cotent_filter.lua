--- 离开 vim 时, 清理 log 文件

local mb = 1024 * 1024

local function get_oversized_log(size)
  --- log_files = [
  ---   {
  ---     filepath = filepath,
  ---     fsize = vim.fn.getfsize(filepath),
  ---   },
  ---   ...
  --- ]
  local log_files = {}

  size = size or 10
  size = size * mb

  --- read files from directory
  local logs = vim.split(vim.fn.glob(vim.fn.stdpath('log').."/*"), '\n', {trimempty=true})
  local caches = vim.split(vim.fn.glob(vim.fn.stdpath('cache').."/*"), '\n', {trimempty=true})

  for _, fp in ipairs(logs) do
    local finfo = vim.uv.fs_stat(fp)
    if finfo and finfo.type == 'file' and finfo.size > size then
      table.insert(log_files, { filepath = fp, fsize = finfo.size })
    end
  end

  for _, fp in ipairs(caches) do
    local finfo = vim.uv.fs_stat(fp)
    if finfo and finfo.type == 'file' and finfo.size > size then
      table.insert(log_files, { filepath = fp, fsize = finfo.size })
    end
  end

  return log_files
end

local function trim_empty_lines(lines)
  local index
  for i, line in ipairs(lines) do
    if line ~= '' then
      index = i
      break
    end
  end

  if index then
    return { unpack(lines, index) }
  end

  return lines
end

--- 删除文件中的旧内容以达到 reduce file size 的目的.
local function reduce_filesize(log, size)
  --- `wc -l filepath`: file line count.
  local result = vim.system({'wc', '-l', log.filepath}, { text = true }):wait()
  if result.code ~= 0 then
    --- 这里不能使用 error() 否则无法 sleep
    vim.notify(result.stderr, vim.log.levels.WARN)
    vim.cmd.sleep(3)
    return
  end

  local r_slice = vim.split(result.stdout, ' ', {trimempty=true})
  local lnum = tonumber(r_slice[1])
  if not lnum then
    --- 这里不能使用 error() 否则无法 sleep
    vim.notify("error: lnum can not be parsed", vim.log.levels.WARN)
    vim.cmd.sleep(3)
    return
  end

  --- 根据当前文件大小和限制大小截取数据.
  size = size or 6
  size = size * mb
  local trim_lnum = math.ceil(lnum * size / log.fsize)

  if trim_lnum == 0 then
    return
  end

  --- 只读取倒数 n 行数据.
  local max = trim_lnum * -1
  local remain_content = vim.fn.readfile(log.filepath, '', max)

  --- trim empty lines
  remain_content = trim_empty_lines(remain_content)

  --- 覆盖写入数据. flag: omit - 直接覆盖写入, 'a' - append 写入.
  vim.fn.writefile(remain_content, log.filepath)
end

local function trim_logs()
  local log_files = get_oversized_log(6)

  --- 如果 log 文件超过指定大小, 则删除文件前半部分的数据.
  for _, log in ipairs(log_files) do
    reduce_filesize(log, 4)
  end
end

--- 离开 vim 时, 清理 log 文件.
vim.api.nvim_create_autocmd("VimLeavePre", {
  pattern = {"*"},
  callback = function(params)
    trim_logs()
  end,
  desc = "clean log files when VimLeavePre",
})



