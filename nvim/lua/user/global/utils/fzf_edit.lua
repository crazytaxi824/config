function FZF_multi_selected(content)
  local content_slice = vim.split(content, "'", {trimempty=true})

  local filepath_list = {}
  for _, fp in ipairs(content_slice) do
    if fp ~= ' ' then
      local fp_lnum_col = vim.split(vim.fn.trim(fp), ":")
      local fp_qf_list = {
        filename = fp_lnum_col[1],
        lnum = fp_lnum_col[2] or '1',
        col  = fp_lnum_col[3] or '1',
        text = fp_lnum_col[4] or '',
      }
      table.insert(filepath_list, fp_qf_list)
    end
  end

  if #filepath_list == 0 then
    return
  end

  --- edit/open first file in the list.
  local cmd = 'edit +lua\\ vim.fn.cursor("' .. filepath_list[1].lnum .. '","' .. filepath_list[1].col .. '") ' .. filepath_list[1].filename
  vim.cmd(cmd)

  --- put other files in quickfix_list.
  vim.fn.setqflist(filepath_list, 'r')  -- 'a' - append; 'r' - replace
  vim.cmd('copen')
end



