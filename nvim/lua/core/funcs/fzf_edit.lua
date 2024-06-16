--- fzf 中使用 {+f} placeholder 会将所有 selected 的结果写入一个临时文件, {+f} 则是这个临时文件的路径.
--- {+f} 临时文件的路径通常是固定的, 不会无限创建新文件. 只是每次多选后 replace 该文件中的内容.
--- 如果是 fd 选择的结果, 则临时文件中记录的是 filepath/dir.
--- 如果是 rg 返回的结果, 则临时文件中记录的是 <filepath:line:col:content>
--- 结论: {+f} 临时文件中记录的是 fzf 中显示的结果.
function FZF_selected(fzf_tmp_file)
  if vim.fn.filereadable(fzf_tmp_file) == 0 then
    Notify({"fzf `{+f}` tmp file is NOT readable.", "path: `" .. fzf_tmp_file .. "`"}, "ERROR")
    return
  end

  --- 获取文件内容, readfile() 会按照 '\n' 返回一个 list.
  local fzf_selected_items = vim.fn.readfile(fzf_tmp_file)

  local fp_qf_list = {}
  for _, fzf_item in ipairs(fzf_selected_items) do
    fzf_item = vim.trim(fzf_item)
    if fzf_item ~= '' then
      --- 按照 "filepath:lnum:col:text" split.
      local fp_item_split = vim.split(fzf_item, ":", {trimempty=false})

      --- insert quickfix_list item
      local fp_qf_item = {
        filename = fp_item_split[1],
        lnum = tonumber(fp_item_split[2]) or 1,
        col  = tonumber(fp_item_split[3]) or 1,
        -- text = table.concat(vim.list_slice(fp_item_split, 4), ':'),  -- text 中本身含有 ':'
      }
      table.insert(fp_qf_list, fp_qf_item)
    end
  end

  --- 一般不会出现传入 0 个 item 的情况.
  --- 就算在 fzf 中没有使用 <tab> 选择任何一个 item, fzf 会将当前 cursor 指向的 item 作为选中的 item.
  --- 所以一般情况下至少会有一个 item.
  if #fp_qf_list == 0 then
    Notify("fzf selected items is 0, please check fzf result.", "ERROR")
    return
  end

  --- edit file
  vim.cmd.edit(fp_qf_list[1].filename)
  local win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_cursor(win_id, {fp_qf_list[1].lnum, fp_qf_list[1].col-1})  -- {1,0}-indexed

  --- 如果有多个 item, 则放入 quickfix list.
  if #fp_qf_list > 1 then
    --- put all items in quickfix_list.
    vim.fn.setqflist(fp_qf_list, 'r')  -- 'a' - append to quickfix_list; 'r' - replace quickfix_list with new items.
    vim.fn.setqflist({}, 'a', {title = 'fzf_selected'})  -- set quickfix title
    vim.cmd.copen()  -- open quickfix window.

    --- 返回之前的 window.
    vim.api.nvim_set_current_win(win_id)
  end
end



