function FZF_selected(fzf_tmp_file)
  local fzf_contents = vim.fn.readfile(fzf_tmp_file)

  local fp_qf_list = {}
  for _, content in ipairs(fzf_contents) do
    content = vim.fn.trim(content)
    if content ~= '' then
      local fp_lnum_col = vim.split(content, ":")
      local fp_qf_item = {
        filename = fp_lnum_col[1],
        lnum = fp_lnum_col[2] or '1',
        col  = fp_lnum_col[3] or '1',
        text = fp_lnum_col[4] or '',
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



