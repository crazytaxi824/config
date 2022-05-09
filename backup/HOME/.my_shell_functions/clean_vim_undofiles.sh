#!/bin/zsh

# NOTE 设置定时任务 `crontab -e` `30 11 * * * zsh ~/.my_shell_functions/clean_vim_undofiles.sh`

# `date -r file` 显示 date and time of the last modification of the file.
# `date -r file +"%s"` 显示 last modification in Unix Time Stamp.
# `date +"%s"` 显示 NOW in Unix Time Stamp.

# check ~/.vim/undo 中已经被删除了的文件, 然后删除对应的 undo file `*.un~`
function cleanVimUndoFiles() {
	# vim `set undodir?` for Filetype go,python,js,ts...
	local undodir=~/.vim/undo

	local undo_files_list=()
	undo_files_list+=( $(ls $undodir | cat ) )

	# time now
	local now=$(date +"%s")

	for undo_file in $undo_files_list
	do
		# replace all '%' with '/'  - `ls | sed 's/%/\//g'`
		local orig_file=$(echo $undo_file | sed 's/%/\//g')

		# 如果 original_file 不存在了, 或者 undo_file's last modification time 是 28 天以前, 则删除 undo_file
		if [[ ! -f $orig_file ]] || (( $now - $(date -r "$undodir/$undo_file" +"%s") > 28*24*3600 )); then
			rm "$undodir/$undo_file" && echo -e "$undodir/$undo_file - removed" || echo -e "rm $undodir/$undo_file - \e[31mfailed\e[0m"
		fi
	done

	echo "cleanup undo files in '$undodir' - DONE"
}

# 运行程序
cleanVimUndoFiles
