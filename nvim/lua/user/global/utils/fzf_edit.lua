function FZF_selected(fzf_tmp_file)
  --- 获取文件内容, readfile() 会按照 '\n' 返回一个 list.
  local fzf_lines = vim.fn.readfile(fzf_tmp_file)

  local fp_qf_list = {}
  for _, line in ipairs(fzf_lines) do
    line = vim.fn.trim(line)
    if line ~= '' then
      --- 按照 "filepath:lnum:col:content" split line.
      local fp_line_split = vim.split(line, ":")

      --- concat content 内容, 如果 content 中本身含有 ':'
      local text = {}
      for i = 4, #fp_line_split, 1 do
        table.insert(text, fp_line_split[i])
      end

      --- insert quickfix_list item
      local fp_qf_item = {
        filename = fp_line_split[1],
        lnum = fp_line_split[2] or '1',
        col  = fp_line_split[3] or '1',
        text = table.concat(text, ":"),
      }
      table.insert(fp_qf_list, fp_qf_item)
    end
  end

  if #fp_qf_list == 0 then
    return
  end

  --- edit/open first file in the list.
  local cmd = 'edit +lua\\ vim.fn.cursor("' .. fp_qf_list[1].lnum .. '","' .. fp_qf_list[1].col .. '") '
    .. vim.fn.fnameescape(fp_qf_list[1].filename)  -- NOTE: 使用 vim cmd `:edit` 必须 escape filename.
  vim.cmd(cmd)

  --- put other files in quickfix_list.
  vim.fn.setqflist(fp_qf_list, 'r')  -- 'a' - append to quickfix_list; 'r' - replace quickfix_list with new items.
  vim.cmd('copen')
end



