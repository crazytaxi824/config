--- NOTE: fzf 中使用 {+f} placeholder 会将所有 selected 的结果写入一个临时文件, {+f} 则是这个临时文件的路径.
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
    fzf_item = vim.fn.trim(fzf_item)
    if fzf_item ~= '' then
      --- 按照 "filepath:lnum:col:content" split.
      local fp_item_split = vim.split(fzf_item, ":", {trimempty=false})

      --- concat content 内容, 如果 content 中本身含有 ':'
      --local text = {}
      --for i = 4, #fp_item_split, 1 do
      --  table.insert(text, fp_item_split[i])
      --end

      --- insert quickfix_list item
      local fp_qf_item = {
        filename = fp_item_split[1],
        lnum = fp_item_split[2] or '1',
        col  = fp_item_split[3] or '1',
        --text = table.concat(text, ":"),  -- 不在 quickfix_list 中显示 text.
      }
      table.insert(fp_qf_list, fp_qf_item)
    end
  end

  --- 一般不会出现传入 0 个 items 的情况.
  --- 就算在 fzf 中没有使用 <tab> 选择任何一个 item, fzf 会将当前 cursor 指向的 item 作为选中的 item.
  --- 所以一般情况下至少会有一个 item.
  if #fp_qf_list == 0 then
    Notify("fzf selected items is 0, please check fzf result.", "ERROR")
    return
  end

  --- VVI: 必须有 `:edit` 命令, 否则会打开一个 [No Name] file.
  --- VVI: 使用 vim cmd `:edit` 必须 escape filename.
  --- edit/open first item(file) in the list.
  local cmd = 'edit +lua\\ vim.fn.cursor("' .. fp_qf_list[1].lnum .. '","' .. fp_qf_list[1].col .. '") '
   .. vim.fn.fnameescape(fp_qf_list[1].filename)
  vim.cmd(cmd)

  --- put all items in quickfix_list.
  vim.fn.setqflist(fp_qf_list, 'r')  -- 'a' - append to quickfix_list; 'r' - replace quickfix_list with new items.

  --- 这里使用 cfirst 主要是为了让 cursor 跳回到文件窗口, 而不是留在 quickfix window 中.
  vim.cmd('copen | cfirst')
end



